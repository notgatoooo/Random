export default function handler(req, res) {
  const protocol = req.headers["x-forwarded-proto"] || "https";
  const host = req.headers.host;

  const url = new URL(req.url, `${protocol}://${host}`);

  res.status(200).json({
    args: req.query,
    headers: req.headers,
    origin:
      req.headers["x-forwarded-for"]?.split(",")[0] ||
      req.socket?.remoteAddress ||
      null,
    url: url.toString(),
  });
}
