require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { GoogleGenAI } = require("@google/genai");

const app = express();
app.use(cors());
app.use(express.json());

if (!process.env.GEMINI_API_KEY) {
  console.error("GEMINI_API_KEY not found in environment variables");
  process.exit(1);
}

const genAI = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const requestLog = {};

app.post("/chat", async (req, res) => {
  const { message, screen = "general", userId = "anonymous" } = req.body;

  if (!message) {
    return res.status(400).json({ error: "Message is required" });
  }

  if (message.length > 2000) {
    return res.status(400).json({ error: "Message too long" });
  }

  // Rate limit (10 per minute per user)
  const now = Date.now();
  const windowMs = 60 * 1000;
  const limit = 10;

  if (!requestLog[userId]) requestLog[userId] = [];
  requestLog[userId] = requestLog[userId].filter(ts => now - ts < windowMs);

  if (requestLog[userId].length >= limit) {
    return res.status(429).json({ error: "Too many requests" });
  }

  requestLog[userId].push(now);

  const systemPrompt = `
You are Code Quest AI, a sci-fi themed learning assistant.
Give hints first and encourage reasoning.
Do not directly reveal MCQ answers unless asked twice.
Never fully solve exams automatically.
Keep responses under 500 tokens.
Context: ${screen}
`;

  try {
    const result = await genAI.models.generateContent({
      model: "gemini-2.0-flash",
      contents: systemPrompt + "\nUser: " + message,
      config: {
        maxOutputTokens: 200,
        temperature: 0.7,
      },
    });

    const reply = result.text;

    res.json({ reply });

  } catch (error) {
  console.error("Gemini error:", error);

  if (error.status === 429) {
    return res.status(429).json({
      error: "Rate limit reached. Please wait 30 seconds and try again."
    });
  }

  if (error.status === 403) {
    return res.status(403).json({
      error: "API key invalid or quota exceeded."
    });
  }

  res.status(500).json({
    error: "AI generation failed"
  });
}

});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
