# Ideafii MVP v1 Checklist (Reset Baseline)

## 1) Auth + Sign-in stability
- [ ] Confirm Google OAuth works on iOS real device (deep link opens app after auth)
- [ ] Confirm Google OAuth works on Android (intent filter or custom scheme added)
- [ ] Verify login → onboarding → app flow does not loop or hang
- [ ] Verify sign-out always returns to login

## 2) Server-side usage limits (non-negotiable)
- [ ] Create `usage_counters` table (user_id, period_start, ideas_used, blueprints_used, daily_spark_used, saved_count)
- [ ] Add DB policies for user access
- [ ] Enforce limits in `generate-blueprint` edge function
- [ ] Enforce limits in `daily-spark` edge function
- [ ] Return clear error payload on quota hit

## 3) Tier source of truth (plans)
- [ ] Add `profiles.plan` or `subscriptions` table in Supabase
- [ ] Update Edge Functions to read tier from DB (not user metadata only)
- [ ] Sync client tier from DB on login
- [ ] Add dev override for testing (optional)

## 4) Lite vs Full blueprint
- [ ] If Free: return lite blueprint (short summary + minimal sections only)
- [ ] If Premium: return full blueprint (all sections)
- [ ] UI: hide locked sections and show “Upgrade to unlock” badges

## 5) Vault limit enforcement
- [ ] Enforce max 5 saved for Free (server & DB)
- [ ] UI: disable save with upgrade CTA
- [ ] Premium: unlimited

## 6) Exports
- [ ] If Free: disable PDF + Notion buttons
- [ ] If Premium: enable PDF + Notion (implement or remove from plan copy)

## 7) QA / Regression
- [ ] Daily Spark generates once per day per user
- [ ] “Build this idea” respects lite/full + limits
- [ ] Saved ideas render correctly (cards + chips)
- [ ] App scrolls normally on iOS and Android
- [ ] App loads without crashes on fresh install
