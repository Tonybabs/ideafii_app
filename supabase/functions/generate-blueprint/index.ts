// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from "jsr:@supabase/supabase-js@2"

type UserProfile = {
  intent?: string
  skillLevel?: string
  hoursPerWeek?: number
  budget?: string
  tone?: string
}

type GenerateMode = "blueprint" | "daily_spark"
type BlueprintMode = "lite" | "full"

type Blueprint = {
  summary: string
  whoItHelps: string
  whyNow: string
  startupCost: string
  incomePotential: string
  toolsNeeded: string[]
  stepByStepPlan: string[]
  marketingPlan: string[]
  nameIdeas: string[]
  roadmap7Days: string[]
  noCodeVersion: string[]
  risksAndFixes: string[]
  mvpFeatures: string[]
  cardTag: string
  cardIcon: string
  difficulty: string
  cost: string
  durationWeeks: string
  blueprintMode: BlueprintMode
}

const DEFAULT_PROFILE: Required<UserProfile> = {
  intent: "explore",
  skillLevel: "no_code",
  hoursPerWeek: 5,
  budget: "0_100",
  tone: "coach",
}

const MODEL = "gemini-1.5-flash"

function asList(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.map((v) => String(v).trim()).filter(Boolean)
  }
  if (typeof value === "string") {
    return value
      .split("\n")
      .map((v) => v.replace(/^[•\-\d\)\.]+\s*/, "").trim())
      .filter(Boolean)
  }
  return []
}

function extractJson(text: string): string {
  const fenced = text.match(/```json([\s\S]*?)```/i)
  if (fenced?.[1]) return fenced[1].trim()
  const generic = text.match(/```([\s\S]*?)```/)
  if (generic?.[1]) return generic[1].trim()
  return text.trim()
}

function normalizeBlueprint(raw: Record<string, unknown>): Blueprint {
  return {
    summary: String(raw.summary ?? ""),
    whoItHelps: String(raw.whoItHelps ?? ""),
    whyNow: String(raw.whyNow ?? ""),
    startupCost: String(raw.startupCost ?? ""),
    incomePotential: String(raw.incomePotential ?? ""),
    toolsNeeded: asList(raw.toolsNeeded),
    stepByStepPlan: asList(raw.stepByStepPlan),
    marketingPlan: asList(raw.marketingPlan),
    nameIdeas: asList(raw.nameIdeas),
    roadmap7Days: asList(raw.roadmap7Days),
    noCodeVersion: asList(raw.noCodeVersion),
    risksAndFixes: asList(raw.risksAndFixes),
    mvpFeatures: asList(raw.mvpFeatures),
    cardTag: String(raw.cardTag ?? ""),
    cardIcon: String(raw.cardIcon ?? ""),
    difficulty: String(raw.difficulty ?? ""),
    cost: String(raw.cost ?? ""),
    durationWeeks: String(raw.durationWeeks ?? ""),
    blueprintMode: "lite",
  }
}

Deno.serve(async (req) => {
  const body = await req.json()
  const mode: GenerateMode =
    body?.mode === "daily_spark" ? "daily_spark" : "blueprint"
  const requestedBlueprintMode: BlueprintMode =
    body?.blueprint_mode === "full" ? "full" : "lite"
  const idea = typeof body?.idea === "string" ? body.idea.trim() : ""
  const modifier = typeof body?.modifier === "string" ? body.modifier.trim() : ""
  const userProfile: UserProfile = body?.user_profile ?? {}

  if (mode === "blueprint" && !idea) {
    return new Response(
      JSON.stringify({ error: "Missing idea" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    )
  }

  const profile = { ...DEFAULT_PROFILE, ...userProfile }

  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? ""
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? ""
  let effectiveBlueprintMode: BlueprintMode = requestedBlueprintMode

  const authHeader = req.headers.get("Authorization") ?? ""
  if (authHeader && supabaseUrl && supabaseAnonKey) {
    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    })
    const { data: authData } = await supabase.auth.getUser()
    const planRaw =
      (authData?.user?.user_metadata?.plan ?? authData?.user?.app_metadata?.plan ??
        "free") as string
    const plan = String(planRaw).toLowerCase()
    const isPremium = plan === "premium" || plan === "premium_x"
    if (!isPremium) effectiveBlueprintMode = "lite"
  } else {
    effectiveBlueprintMode = "lite"
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY")
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: "Missing GEMINI_API_KEY" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    )
  }

  const prompt = mode === "daily_spark"
    ? `
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
    : `
You are Ideafii, a startup coach. Generate a concise, actionable blueprint.
${modifier ? `Modifier: ${modifier}` : ""}
Personalize for this user:
- intent: ${profile.intent}
- skill: ${profile.skillLevel}
- budget: ${profile.budget}
- time: ${profile.hoursPerWeek} hours per week
- tone: ${profile.tone}

Idea: ${idea}

Return JSON only, with exactly these keys and types.
If blueprintMode is "lite", keep non-core sections short or empty, but still include all keys.
{
  "summary": string,
  "whoItHelps": string,
  "whyNow": string,
  "startupCost": string,
  "incomePotential": string,
  "toolsNeeded": string[],
  "stepByStepPlan": string[],
  "marketingPlan": string[],
  "nameIdeas": string[],
  "roadmap7Days": string[],
  "noCodeVersion": string[],
  "risksAndFixes": string[],
  "mvpFeatures": string[],
  "cardTag": string, // e.g. "AI Tools", "Local", "Digital", "Low Cost"
  "cardIcon": string, // emoji icon that fits the idea
  "difficulty": string, // Beginner | Intermediate | Advanced
  "cost": string, // $ | $$ | $$$ | $$$$
  "durationWeeks": string, // e.g. "2-3 weeks"
  "blueprintMode": "${effectiveBlueprintMode}"
}
`.trim()

  const geminiRes = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${apiKey}`,
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
        generationConfig: mode === "daily_spark"
          ? {
              temperature: 0.8,
              maxOutputTokens: 200,
            }
          : {
              temperature: 0.7,
              maxOutputTokens: 1200,
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

  if (mode === "daily_spark") {
    const spark = String(parsed.spark ?? "").trim()
    if (!spark) {
      return new Response(
        JSON.stringify({ error: "Empty spark" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      )
    }

    return new Response(
      JSON.stringify({ spark }),
      { headers: { "Content-Type": "application/json" } },
    )
  }

  const blueprint = normalizeBlueprint(parsed)
  blueprint.blueprintMode = effectiveBlueprintMode

  return new Response(
    JSON.stringify(blueprint),
    { headers: { "Content-Type": "application/json" } },
  )
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-blueprint' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json' \
    --data '{"name":"Functions"}'

*/
