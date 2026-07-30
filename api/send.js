import Pusher from "pusher";

const pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID,
  key: process.env.PUSHER_KEY,
  secret: process.env.PUSHER_SECRET,
  cluster: process.env.PUSHER_CLUSTER,
  useTLS: true,
});

// apikey ehhehshshhehehehe :)
const API_KEY = process.env.API_KEY; 

const rateLimitMap = new Map();
const LIMIT_MS = 1000; 

export default async function handler(req, res) {
  if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });
  const incomingKey = req.headers["x-api-key"];
  if (!incomingKey || incomingKey !== API_KEY) {
    return res.status(403).json({ error: "Forbidden: Invalid or missing API Key" });
  }

  const ip = req.headers["x-forwarded-for"]?.split(",")[0]?.trim() || req.socket?.remoteAddress || "unknown";
  const now = Date.now();
  const last = rateLimitMap.get(ip) || 0;

  if (now - last < LIMIT_MS) {
    return res.status(429).json({ error: "Slow down! Wait 1s between requests." });
  }
  rateLimitMap.set(ip, now);

  try {
    const { user, msg } = req.body || {};
    const cleanMsg = String(msg || "").trim().slice(0, 15000);

    if (!cleanMsg) return res.status(400).json({ error: "Script content required" });

    await pusher.trigger("my-channel", "my-event", {
      user: String(user || "Admin").slice(0, 20),
      msg: cleanMsg,
    });

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error("Pusher Trigger Error:", err);
    return res.status(500).json({ error: "Internal Server Error" });
  }
}
