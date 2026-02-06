const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ======== Helpers ========
async function isTeacherUid(uid) {
    const doc = await db.collection("users").doc(uid).get();
    return doc.exists && doc.data()?.role === "teacher";
}

function sha1Hex(input) {
    const crypto = require("crypto");
    return crypto.createHash("sha1").update(input).digest("hex");
}

// ======== Groq AI ========
async function callGroqAI({ apiKey, category, difficulty, avoidTitles }) {
    const avoidText =
        avoidTitles && avoidTitles.length
            ? `Avoid titles similar to:\n- ${avoidTitles.join("\n- ")}\n`
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
- tags (array of 2-6 strings, include one of: clickbait, missing-source, fearbait, context-missing, absurd-claim, and include "${category}")
- domainHint (string, looks like a domain; can be fictional)

Rules:
- Keep content appropriate for teens.
- Non-graphic, non-hateful, non-political.
- Do not mention real people.
${avoidText}
`;

    const body = {
        // IMPORTANT: pick a currently supported Groq model from your console
        model: "llama-3.3-70b-versatile",
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

// ======== Callable: claimUserCase ========
exports.claimUserCase = onCall(async (req) => {
    if (!req.auth) throw new HttpsError("unauthenticated", "Login required.");
    const uid = req.auth.uid;
    if (!(await isTeacherUid(uid)))
        throw new HttpsError("permission-denied", "Teacher only.");

    const caseId = String(req.data?.caseId ?? "");
    if (!caseId) throw new HttpsError("invalid-argument", "Missing caseId.");

    const ref = db.collection("user_cases").doc(caseId);

    await db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) throw new HttpsError("not-found", "Case not found.");

        const data = snap.data();
        if (data.status !== "pending") {
            throw new HttpsError("failed-precondition", "Case is not pending.");
        }

        if (data.assignedTo && data.assignedTo !== uid) {
            throw new HttpsError("already-exists", "Already claimed by another teacher.");
        }

        if (!data.assignedTo) {
            tx.update(ref, {
                assignedTo: uid,
                assignedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
    });

    return { ok: true };
});

// ======== Callable: reviewUserCase ========
exports.reviewUserCase = onCall(async (req) => {
    if (!req.auth) throw new HttpsError("unauthenticated", "Login required.");
    const uid = req.auth.uid;
    if (!(await isTeacherUid(uid)))
        throw new HttpsError("permission-denied", "Teacher only.");

    const caseId = String(req.data?.caseId ?? "");
    const decision = String(req.data?.decision ?? ""); // "approved" | "rejected"
    if (!caseId) throw new HttpsError("invalid-argument", "Missing caseId.");
    if (!(decision === "approved" || decision === "rejected")) {
        throw new HttpsError("invalid-argument", "Decision must be approved/rejected.");
    }

    const ref = db.collection("user_cases").doc(caseId);

    await db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists) throw new HttpsError("not-found", "Case not found.");

        const data = snap.data();
        if (data.status !== "pending") {
            throw new HttpsError("failed-precondition", "Case already reviewed.");
        }
        if (data.assignedTo !== uid) {
            throw new HttpsError("permission-denied", "You must claim this case first.");
        }

        tx.update(ref, {
            status: decision,
            reviewedBy: uid,
            reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
            reviewDecision: decision,
        });
    });

    return { ok: true };
});

// ======== Callable: generateAIBatch ========
exports.generateAIBatch = onCall({ secrets: ["AI_API_KEY"] }, async (req) => {
    if (!req.auth) throw new HttpsError("unauthenticated", "Login required.");
    const uid = req.auth.uid;
    if (!(await isTeacherUid(uid)))
        throw new HttpsError("permission-denied", "Teacher only.");

    const apiKey = process.env.AI_API_KEY;
    if (!apiKey) throw new HttpsError("failed-precondition", "Missing AI_API_KEY secret.");

    const count = Math.min(200, Math.max(1, Number(req.data?.count ?? 100)));
    const category = String(req.data?.category ?? "technology");
    const difficulty = Math.min(3, Math.max(1, Number(req.data?.difficulty ?? 2)));

    const avoidTitles = [];

    // Get last ~20 titles to reduce duplicates (optional)
    const recent = await db.collection("ai_cases").orderBy("createdAt", "desc").limit(20).get();
    recent.docs.forEach((d) => {
        const t = d.data()?.title;
        if (typeof t === "string") avoidTitles.push(t);
    });

    let created = 0;

    for (let i = 0; i < count; i++) {
        const data = await callGroqAI({
            apiKey,
            category,
            difficulty,
            avoidTitles,
        });

        const title = String(data.title ?? "").trim();
        const snippet = String(data.snippet ?? "").trim();
        const explanation = String(data.explanation ?? "").trim();

        if (!title || !snippet || !explanation) continue;

        const fp = sha1Hex((title + "|" + snippet).toLowerCase());

        // Skip duplicates by fingerprint
        const existing = await db
            .collection("ai_cases")
            .where("fingerprint", "==", fp)
            .limit(1)
            .get();

        if (!existing.empty) continue;

        const tags = Array.isArray(data.tags) ? data.tags.map(String) : [];
        if (!tags.includes(category)) tags.push(category);

        await db.collection("ai_cases").add({
            title,
            snippet,
            sourceName: String(data.sourceName ?? "AI Generator"),
            isFake: Boolean(data.isFake),
            explanation,
            tags,
            difficulty,
            domainHint: data.domainHint ? String(data.domainHint) : null,
            fingerprint: fp,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        created++;
    }

    return { ok: true, created };
});
