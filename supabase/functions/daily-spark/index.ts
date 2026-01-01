import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

type UserProfile = {
  intent?: string
  skillLevel?: string
  hoursPerWeek?: number
  budget?: string
  tone?: string
}

const DEFAULT_PROFILE: Required<UserProfile> = {
  intent: "explore",
  skillLevel: "no_code",
  hoursPerWeek: 5,
  budget: "0_100",
  tone: "coach",
}

const MODEL = "gemini-1.5-flash"

function extractJson(text: string): string {
  const fenced = text.match(/```json([\s\S]*?)```/i)
  if (fenced?.[1]) return fenced[1].trim()
  const generic = text.match(/```([\s\S]*?)```/)
  if (generic?.[1]) return generic[1].trim()
  return text.trim()
}

Deno.serve(async (req) => {
  const body = await req.json()
  const userProfile: UserProfile = body?.user_profile ?? {}
  const day = typeof body?.day === "string" ? body.day.trim() : ""
  const requestedSparkMode = body?.spark_mode === "full" ? "full" : "lite"

  if (!day) {
    return new Response(
      JSON.stringify({ error: "Missing day" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    )
  }

  const profile = { ...DEFAULT_PROFILE, ...userProfile }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? ""
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? ""
  if (!supabaseUrl || !supabaseAnonKey) {
    return new Response(
      JSON.stringify({ error: "Missing Supabase env" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  const authHeader = req.headers.get("Authorization") ?? ""
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: "Missing Authorization" }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    )
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  })

  const { data: authData, error: authError } = await supabase.auth.getUser()
  const userId = authData?.user?.id
  if (authError || !userId) {
    return new Response(
      JSON.stringify({ error: "Unauthorized" }),
      { status: 401, headers: { "Content-Type": "application/json" } },
    )
  }
  const planRaw =
    (authData?.user?.user_metadata?.plan ?? authData?.user?.app_metadata?.plan ??
      "free") as string
  const plan = String(planRaw).toLowerCase()
  const isPremium = plan === "premium" || plan === "premium_x"
  const sparkMode = isPremium ? requestedSparkMode : "lite"

  const { data: existing } = await supabase
    .from("daily_sparks")
    .select("idea")
    .eq("user_id", userId)
    .eq("day", day)
    .maybeSingle()

  const existingSpark = existing?.idea?.spark
  if (typeof existingSpark === "string" && existingSpark.trim()) {
    return new Response(
      JSON.stringify({ spark: existingSpark.trim() }),
      { headers: { "Content-Type": "application/json" } },
    )
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY")
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Missing GEMINI_API_KEY" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  const prompt = sparkMode === "full"
    ? `
You are Ideafii, a startup coach. Generate one concise startup idea plus a quick rationale.
Personalize for this user:
- intent: ${profile.intent}
- skill: ${profile.skillLevel}
- budget: ${profile.budget}
- time: ${profile.hoursPerWeek} hours per week
- tone: ${profile.tone}

Return JSON only with this exact shape:
{
  "spark": string,
  "whyFit": string,
  "steps": string[],
  "tools": string[]
}
`.trim()
    : `
You are Ideafii, a startup coach. Generate one concise startup idea.
Personalize for this user:
- intent: ${profile.intent}
- skill: ${profile.skillLevel}
- budget: ${profile.budget}
- time: ${profile.hoursPerWeek} hours per week
- tone: ${profile.tone}

Return JSON only with this exact shape:
{
  "spark": string
}
`.trim()

  const geminiRes = await fetch(
    \`https://generativelanguage.googleapis.com/v1beta/models/\${MODEL}:generateContent?key=\${apiKey}\`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            role: "user",
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          temperature: 0.8,
          maxOutputTokens: 200,
        },
      }),
    },
  )

  if (!geminiRes.ok) {
    const errorText = await geminiRes.text()
    return new Response(
      JSON.stringify({ error: "Gemini error", detail: errorText }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  const geminiJson = await geminiRes.json()
  const text =
    geminiJson?.candidates?.[0]?.content?.parts?.[0]?.text ??
    geminiJson?.candidates?.[0]?.content?.parts?.map((p: any) => p?.text).join("\n") ??
    ""

  let parsed: Record<string, unknown> = {}
  try {
    parsed = JSON.parse(extractJson(text))
  } catch (_) {
    return new Response(
      JSON.stringify({ error: "Invalid JSON from model", raw: text }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  const spark = String(
    parsed.spark ?? parsed.oneLiner ?? parsed.title ?? ""
  ).trim()
  if (!spark) {
    return new Response(
      JSON.stringify({ error: "Empty spark" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  await supabase
    .from("daily_sparks")
    .upsert(
      { user_id: userId, day, idea: { spark } },
      { onConflict: "user_id,day" },
    )

  return new Response(
    JSON.stringify({ spark }),
    { headers: { "Content-Type": "application/json" } },
  )
})
