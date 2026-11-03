export default {
  async fetch(request, env) {
    if (!env.ORIGIN_BASE_URL || !env.ORIGIN_AUTH_TOKEN) {
      return new Response("Origin is not configured", { status: 503 });
    }

    const incoming = new URL(request.url);
    const origin = new URL(env.ORIGIN_BASE_URL);

    // Keep the origin fixed in configuration; never derive it from user input.
    const target = new URL(incoming.pathname + incoming.search, origin);
    const headers = new Headers(request.headers);
    headers.set("X-SpringNexa-Origin-Token", env.ORIGIN_AUTH_TOKEN);
    headers.set("X-Forwarded-Host", incoming.host);
    headers.set("X-Forwarded-Proto", "https");
    headers.set("X-Forwarded-For", request.headers.get("CF-Connecting-IP") || "");

    // Avoid forwarding hop-by-hop and Cloudflare-specific transport headers.
    for (const name of [
      "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
      "te", "trailer", "transfer-encoding", "upgrade"
    ]) headers.delete(name);

    const upstreamRequest = new Request(target, {
      method: request.method,
      headers,
      body: ["GET", "HEAD"].includes(request.method) ? undefined : request.body,
      redirect: "manual"
    });

    try {
      const upstream = await fetch(upstreamRequest);
      const responseHeaders = new Headers(upstream.headers);
      responseHeaders.set("X-Content-Type-Options", "nosniff");
      responseHeaders.delete("server");
      return new Response(upstream.body, {
        status: upstream.status,
        statusText: upstream.statusText,
        headers: responseHeaders
      });
    } catch {
      return new Response("ERPNext origin unavailable", { status: 502 });
    }
  }
};
