export default {
	async fetch(request, env, ctx) {
		return new Response('Hello From Terraform!');
	},
};