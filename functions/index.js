const functions = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { defineSecret } = require("firebase-functions/params");

// ✅ Define secret properly for Functions v2
const GROQ_API_KEY = defineSecret("AI_API_KEY");

// Simple safe fallback if AI fails
function fallbackCase({ category, difficulty }) {
    const isFake = Math.random() < 0.55;
    const tags = isFake
        ? ["clickbait", "missing-source", category]
        : ["credible-tone", "specific-details", category];

    return {
        title: isFake
            ? `BREAKING: ${category} scandal “exposed” overnight (people shocked!)`
            : `Community update: new ${category} program announced`,
        snippet: isFake
            ? "A viral post claims major changes with no sources. It urges you to share immediately."
            : "An announcement shares practical details and a clear timeline for implementation.",
        sourceName: isFake ? "ViralDaily" : "Community Bulletin",
        isFake,
        explanation: isFake
            ? "Red flags: emotional language, vague claims, and no credible sources. Verify before sharing."
            : "This reads like a normal announcement: specific details, calm tone, and plausible scope.",
        tags,
        domainHint: isFake ? "viral.example" : "news.example",
    };
}

async function callGroqAI({ category, difficulty, avoidTitles }) {
    // ✅ Get secret value and trim whitespace/newlines
    const apiKey = (GROQ_API_KEY.value() || "").trim();

    if (!apiKey) {
        logger.warn("AI_API_KEY is empty -> using fallback.");
        return fallbackCase({ category, difficulty });
    }

    // ✅ Safe debug: length only (doesn't leak key)
    logger.info(`Groq key length: ${apiKey.length}`);

    const avoidText =
        avoidTitles && avoidTitles.length
            ? `Avoid generating titles that match or closely resemble any of these recent titles:\n- ${avoidTitles.join(
                "\n- "
            )}\n`
            : "";

    const prompt = `
You generate SAFE, educational training cases for a teen media-literacy app.
Return ONLY valid JSON (no markdown, no commentary).

Create ONE case in category "${category}" with difficulty ${difficulty} (1 easy, 2 medium, 3 hard).
The case must be either fake/misleading or real/credible.

Output JSON with exactly these keys:
- title (string)
- snippet (string, 1-2 sentences)
- sourceName (string)
- isFake (boolean)
- explanation (string, 2-3 sentences explaining the reasoning/red flags)
- tags (array of 2-6 strings; include one of: clickbait, missing-source, fearbait, context-missing, absurd-claim; and include "${category}")
- domainHint (string, looks like a domain; can be fictional)

Rules:
- Appropriate for teens.
- Non-graphic, non-hateful, non-political.
- Do not mention real people.
${avoidText}
`;

    const body = {
        model: "llama-3.1-8b-instant",
        messages: [
            { role: "system", content: "You output ONLY JSON. No extra text." },
            { role: "user", content: prompt },
        ],
        temperature: 0.9,
        max_tokens: 450,
    };

    const resp = await fetch("https://api.groq.com/openai/v1/chat/completions", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
    });

    if (!resp.ok) {
        const txt = await resp.text();
        throw new Error(`Groq error ${resp.status}: ${txt}`);
    }

    const json = await resp.json();
    const content = json.choices?.[0]?.message?.content ?? "";

    return JSON.parse(content);
}

exports.generateCase = functions.onRequest(
    {
        region: "europe-west1",
        secrets: [GROQ_API_KEY], // ✅ use the defined secret object
    },
    async (req, res) => {
        try {
            res.set("Access-Control-Allow-Origin", "*");
            res.set("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
            res.set("Access-Control-Allow-Headers", "Content-Type");

            if (req.method === "OPTIONS") {
                res.status(204).send("");
                return;
            }

            const difficulty = Math.min(3, Math.max(1, Number(req.query.difficulty || 1)));
            const category = String(req.query.category || req.query.topic || "technology");

            const avoidTitlesRaw = String(req.query.avoidTitles || "");
            const avoidTitles = avoidTitlesRaw
                ? avoidTitlesRaw
                    .split("|")
                    .map((s) => s.trim())
                    .filter(Boolean)
                    .slice(0, 10)
                : [];

            let data;
            try {
                data = await callGroqAI({ category, difficulty, avoidTitles });
            } catch (e) {
                logger.warn("AI call failed, using fallback", e);
                data = fallbackCase({ category, difficulty });
            }

            const tags = Array.isArray(data.tags) ? data.tags.map(String) : [];
            if (!tags.includes(category)) tags.push(category);

            const payload = {
                id: `ai_${Date.now()}`,
                title: String(data.title ?? ""),
                snippet: String(data.snippet ?? ""),
                sourceName: String(data.sourceName ?? "AI Generator"),
                isFake: Boolean(data.isFake),
                explanation: String(data.explanation ?? ""),
                tags,
                difficulty,
                domainHint: data.domainHint ? String(data.domainHint) : null,
            };

            if (!payload.title || !payload.snippet || !payload.explanation) {
                throw new Error("Invalid AI payload (missing title/snippet/explanation)");
            }

            res.status(200).json(payload);
        } catch (e) {
            logger.error(e);
            res.status(500).json({ error: "generateCase failed" });
        }
    }
);
