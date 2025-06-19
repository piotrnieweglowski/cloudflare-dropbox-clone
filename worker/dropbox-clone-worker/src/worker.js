export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const { pathname } = url;

    const pattern = new URLPattern({ pathname: "/files/:id" });
    const match = pattern.exec(url);
    if (request.method === 'GET' && match) {
      const id = match.pathname.groups.id;
      return handleDownload(id, env);
    }

    if (request.method === 'GET' && pathname === '/files') {
      return handleListFiles(env);
    }

    if (request.method === 'POST' && pathname === '/files') {
      return handleUpload(request, env);
    }

    return new Response('Not Found', { status: 404 });
  }
};

async function handleListFiles(env) {
  const { results } = await env.DB.prepare(
        "SELECT id, name, type, size, uploaded_at FROM files ORDER BY uploaded_at DESC"
      ).all();

  return Response.json(results);
}

async function handleUpload(request, env) {
  const ip = request.headers.get("CF-Connecting-IP") || "anonymous";
  const limitKey = `rate:${ip}`;

  const current = await env.RATE_LIMIT.get(limitKey);
  if (current && parseInt(current) >= 5) {
    return new Response("Rate limit exceeded", { status: 429 });
  }

  const formData = await request.formData();
  const file = formData.get("file");
  if (!file || !(file instanceof File)) {
    return new Response("Missing file", { status: 400 });
  }

  const id = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.FILES.put(id, file.stream(), {
    httpMetadata: {
      contentType: file.type || 'application/octet-stream',
      contentDisposition: `inline; filename=\"${file.name}\"`
    },
    customMetadata: {
      uploaded_at: now
    }
  });

  await env.DB.prepare(`
    INSERT INTO files (id, name, type, size, uploaded_at)
    VALUES (?, ?, ?, ?, ?)
  `).bind(id, file.name, file.type, file.size, now).run();

  const newCount = current ? parseInt(current) + 1 : 1;
  await env.RATE_LIMIT.put(limitKey, newCount.toString(), { expirationTtl: 3600 });

  return Response.json({ id, uploaded_at: now });
}

async function handleDownload(id, env) {
  const row = await env.DB.prepare(`
    SELECT name FROM files WHERE id = ?
  `).bind(id).first();

  if (!row) return new Response("Metadata not found", { status: 404 });

  const object = await env.FILES.get(id);
  if (!object) return new Response("File not found", { status: 404 });

  return new Response(object.body, {
    headers: {
      "Content-Type": object.httpMetadata?.contentType || 'application/octet-stream',
      "Content-Disposition": object.httpMetadata?.contentDisposition || `inline; filename=\"${row.name}\"`
    }
  });
}