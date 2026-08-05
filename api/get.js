export default function handler(req, res) {
  const headers = {};

  const hidden = new Set([
    "x-vercel-id",
    "x-vercel-forwarded-for",
    "x-vercel-proxy-signature",
    "x-vercel-proxy-signature-ts",
    "x-forwarded-for",
    "x-forwarded-host",
    "x-forwarded-port",
    "x-forwarded-proto",
    "x-real-ip",
    "connection",
  ]);

  for (const [key, value] of Object.entries(req.headers)) {
    if (!hidden.has(key.toLowerCase())) {
      headers[key] = value;
    }
  }

  const protocol = "https";
  const host = req.headers.host;
  const url = new URL(req.url, `${protocol}://${host}`);

  res.json({
    args: req.query,
    headers,
    origin:
      req.headers["x-forwarded-for"]?.split(",")[0] ??
      req.socket.remoteAddress,
    url: url.toString(),
  });
}
