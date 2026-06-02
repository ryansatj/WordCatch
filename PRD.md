# WordCatch — Product Requirements Document

| | |
|---|---|
| **Product** | WordCatch |
| **Topic** | Health & Sport |
| **Target segment** | Retired adults 57+ |
| **Document owner** | Group 19 — Gung, Tio, Ryan, Lori, Felis |
| **Status** | v1.0 — pre-launch baseline |
| **Last updated** | 2026-05-29 |
| **Platform** | iOS 17+ / iPadOS 17+ (real device only — camera required) |
| **Research** | Miro board (C26-CH3, Group 19) — desk research + 3 user interviews + persona empathy maps |

---

## 1. Refined Challenge

> **Empower retired elders to re-discover their passion through physical and
> social activity.**

The phrasing is the team's refined challenge statement from the Miro
exploration. It frames the problem as **purpose and belonging after
retirement**, not as "exercise" or "brain training."

## 2. Challenge Response

> **An app that helps elders stay physically and cognitively active through
> interactive language-based games.**

That's WordCatch: a calm, dignified, camera-based language game that combines
**word recognition + gentle upper-body movement** in a 60–90 second round.

## 3. What the research told us

From desk research, user interviews, and empathy mapping:

- **Older adults *want* to be active and social.** The stereotype that they
  withdraw after retirement is wrong — they're seeking new activities and
  purpose.
- **They self-appreciate "achieving something."** Small wins matter more than
  ranking or leaderboards.
- **They feel left out by modern tech.** Curiosity is high but onboarding
  friction is the main blocker — not lack of interest.
- **They feel "not useful" after retirement** and actively look for ways to
  feel useful and not behind the times.
- **They don't want to feel like an "elder app" user.** Patronizing UI is more
  off-putting than functional friction.

These findings drive the entire product direction — see §11 for how each one
maps to a specific design choice.

## 4. Primary User Persona

### Linda Wijaya, 66
*"Life doesn't stop at retirement."*

| | |
|---|---|
| **Age** | 66 |
| **Status** | Married |
| **Location** | Malang, Indonesia |
| **Job before retirement** | BUMN Corporate |
| **Currently** | Family-oriented, helping society, warm |
| **Tech literacy** | Moderate — daily basic communication |
| **Device** | Phone (mid-tier, mid-low usage) |
| **Connectivity** | 4G / Wi-Fi |

### Bio
Retired ~2 years alongside her spouse. Her children are focused on their own
work and studies. She fills her time with religious community activities and
a physical exercise schedule.

### Motivations
- Being retired makes her feel old → wants a healthier lifestyle
- No daily routine post-retirement → still wants to move her body regularly
- Bored at home → wants to belong to a physical/social community
- Feels left out by tech → curious to learn while keeping her brain working
- Feels "not useful" → wants to feel useful and not left behind by modern gen
- Would do anything to spend time with family

### Goals
- Stay physically active in her old age
- Figure out what activity to fill her time
- Learn new skills, new activities, new tech
- Build stronger social/community bonds
- Get along with younger generations

### Frustrations
- Fear of being scammed by apps and online services
- Complicated app features overwhelm her
- "Health apps" she's tried require a subscription she doesn't understand how to use → waste of money
- Hanging out with peers in her same situation (other retirees) is boring
- A lot of information at once overwhelms her
- Phone text is often too small to read

### Pain Points
- Tech-based scams are a real, daily fear
- Apps and even phones themselves aren't built for elders
- "Retiree-only" social settings get boring
- New tech requires too much attention and reading to learn

### Needs
- An easy-to-use app with helpful, simple-to-understand features
- Guidance/support when learning new digital tools
- A community — **not segmented strictly by age** — that combines social
  contact with light physical activity
- Reminders and structure for family gatherings

---

## 5. Why a language-based game (and not just exercise)?

Linda's profile points to **four overlapping needs** that no single existing
product addresses well:

| Linda's need | Sedentary brain games (Lumosity) | Exercise apps (Apple Fitness+) | Senior apps (large-button) | **WordCatch** |
|---|:---:|:---:|:---:|:---:|
| Stay physically active | ❌ | ✅ | ⚠️ | ✅ (gentle) |
| Stay cognitively sharp | ✅ | ❌ | ⚠️ | ✅ |
| Feel useful / achieve something | ⚠️ | ⚠️ | ❌ | ✅ |
| Doesn't feel "for old people" | ⚠️ | ✅ | ❌ | ✅ |
| No subscription/scam fear | ❌ | ❌ | ⚠️ | ✅ (no IAP) |
| Single-screen, no learning curve | ❌ | ⚠️ | ✅ | ✅ |
| Can play with peers (Duo) | ❌ | ⚠️ | ❌ | ✅ |

The intersection — **light movement + light cognition + warm modern UI + no
subscription** — is the gap WordCatch fills.

---

## 6. Goals

### Product goals (this version)

1. Deliver a **complete, polished single-session experience** for a retired
   adult who fits Linda's profile.
2. **Make a round feel like a small win** — short enough to finish without
   fatigue, calibrated so wins feel earned, not gifted.
3. **Visual identity must feel modern and warm** — *not* the patronizing
   large-button-cartoon style Linda explicitly resents.
4. **Zero learning curve.** Linda should reach a playable round without help
   from her children.

### What we're optimizing for

- **First-session completion** — does a target user finish a round?
- **Self-driven onboarding** — can they get to gameplay without external help?
- **"I'd play this again" rate** — emotional connection, not retention metric

### What we're explicitly NOT optimizing for

- DAU / weekly active users
- Session length (5 minutes is the sweet spot, not 30)
- Habit-loop retention
- Monetization (no IAP, no ads, no subscription — Linda's pain point §4)

## 7. Non-goals

- **Not** a fitness/exercise tracker. No calorie counting. No "health" claims.
- **Not** a brain-training app. No daily score, no skill graph.
- **Not** a social network. No accounts, no friend lists, no leaderboards.
- **Not** multi-language at launch — English baseline first.
- **Not** customizable. No settings menu, no difficulty slider in v1.
- **Not** subscription-based. One free download.

---

## 8. User stories

| As… | I want to… | So that… |
|---|---|---|
| Linda | Open the app and reach a playable round without reading | I don't feel overwhelmed before I start |
| Linda | Read every word on screen without squinting | I'm not blocked by small text |
| Linda | Stop a game without losing it accidentally | I don't feel punished for bumping the phone |
| Linda | Win a round in ~5 minutes | I can fit it in around my day |
| Linda + her husband | Play head-to-head from one device | We can do this together |
| Linda's friend at religious group | Be shown the app once and pick it up | She doesn't need her grandkids to set it up |
| Sarah (Linda's daughter) | Trust that there's no in-app cost or data leak | I feel safe recommending it to my mum |

## 9. Functional requirements

### 9.1 Splash & onboarding
- **F1.** App opens to a branded splash with an animated mascot
- **F2.** Splash auto-times for ~3.5s, then reveals a "Play" CTA
- **F3.** Splash never blocks — Play CTA is reachable

### 9.2 Mode selection
- **F4.** Two modes visible: Solo, Duo
- **F5.** Solo is pre-selected (Linda lives with her spouse → Duo is a natural
  intent, but Solo lowers the bar to "tap Continue")
- **F6.** Selection is two-step: tap a card → tap Continue
- **F7.** Selected state is unmistakable (filled color, checkmark)

### 9.3 Setup tutorial
- **F8.** Tutorial has ≥3 setup steps with image + caption
- **F9.** Pages auto-advance (Linda doesn't have to hunt for "Next")
- **F10.** User can swipe back to re-read at her own pace
- **F11.** Manual swipe cancels auto-advance (no "tug of war" with the UI)
- **F12.** "I'm Ready!" CTA appears only on the final page

### 9.4 Camera & hand tracking
- **F13.** Camera permission is requested only when needed (on first game)
- **F14.** Front camera feed displays full-screen
- **F15.** Hand-skeleton overlay shows joints + chains in real time
- **F16.** Open palm = orange skeleton ("active"); closed = white
- **F17.** Open palm = ≥4 of 5 finger tips extended past PIP joints

### 9.5 Gameplay
- **F18.** Camera-loading overlay shown while session warms (~0.9s)
- **F19.** 3-2-1-GO countdown plays before words spawn
- **F20.** Each word falls in 5–7 seconds (device-independent math)
- **F21.** Max 3 words visible simultaneously
- **F22.** Spawn cadence: 5–7s between words when below cap
- **F23.** Words alternate sides — fair to both players in Duo
- **F24.** Catch radius = `min(width, height) × 0.24` — generous for shaky hands
- **F25.** First to **7** catches wins (round target ~60–90 s)

### 9.6 HUD
- **F26.** P1 score top-left, P2 score top-right
- **F27.** Center "First to N" pill keeps the goal visible
- **F28.** Score colors: P1 orange, P2 brown (brand-aligned, not blue/red)
- **F29.** Numeric score changes animate (`.numericText()`)
- **F30.** Exit button center-bottom, requires **3-second hold** to confirm

### 9.7 End of game
- **F31.** Winner overlay shows trophy + "Player X Wins"
- **F32.** Subtitle indicates which color side won (orange / brown)
- **F33.** Two actions: Play Again (primary), Exit (secondary)
- **F34.** Play Again restarts immediately — no tutorial reshow

### 9.8 Navigation
- **F35.** Back chevron from every post-splash screen
- **F36.** Forward = slide-from-right + fade; back = slide-from-left + fade

### 9.9 Orientation
- **F37.** Menus locked **portrait**; Airplay, Tutorial, Gameplay locked **landscape**
- **F38.** Enforced via `AppDelegate.supportedInterfaceOrientationsFor:`
  (Info.plist alone is insufficient)

## 10. Non-functional requirements

### Performance
- **NF1.** ≥30 FPS hand tracking on iPhone 13+ / iPad Air 4+
- **NF2.** Game tick at 60 Hz
- **NF3.** Cold-start to playable ≤ 6 seconds

### Accessibility (driven by Linda's needs)
- **NF4.** All in-game text ≥16pt; falling words ≥38pt
- **NF5.** All touch targets ≥44×44pt (iOS HIG)
- **NF6.** Text contrast ≥4.5:1
- **NF7.** No timed UI interaction shorter than 3 seconds in menus
- **NF8.** Forgiving catch radius — designed for shaky hands

### Visual identity
- **NF9.** Brand palette: `OrangeBrand`, `BrownBrand`, white, black —
  warm and modern, **explicitly avoiding "elder app" cartoonish style**
- **NF10.** Typography: SF Rounded, defined in `AppTypography.swift`
- **NF11.** Press feedback consistent across all buttons
- **NF12.** All screen-level motion centralized in `AppAnimations.swift`

### Privacy & trust (directly addressing Linda's scam fears)
- **NF13.** **No data leaves the device.** No analytics, no telemetry, no accounts.
- **NF14.** Camera feed is rendered only — never stored, never transmitted.
- **NF15.** **No subscription**, no in-app purchase, no premium tier.
- **NF16.** No microphone, no location, no contacts access.
- **NF17.** No sign-in. No email collection. No phone number collection.

These five are non-negotiable. Linda's frustration with "subscription apps she
doesn't know how to use" and her fear of scams are the dominant trust signals
from the research.

## 11. Research finding → design choice mapping

This is the table that justifies every decision in the product:

| Finding from research | Design choice |
|---|---|
| Older adults *want* to be active socially | Duo mode + same-device 2-player |
| They self-appreciate "achieving something" | Visible score + a clear "first to 7" win condition |
| They feel left out by modern tech | Visual style is modern (not cartoonish) — they're respected, not babied |
| Linda fears scams and subscriptions | No accounts, no IAP, no network calls at all |
| Phone text is too small for her | 38pt falling words, 32pt scores, 36pt headers, ≥16pt anywhere |
| Complicated app features overwhelm her | Single concept (catch words). No settings menu. No nested screens. |
| Apps aren't "built for elders" | But also aren't "obviously for elders" — warm orange/brown brand, friendly mascot |
| Same-age social circles get boring | Duo mode is designed so a younger family member can join in |
| Family is central — she'd do anything to see them | Duo mode is the "play with your grandchild" entry point |
| She wants reminders and structure | (Out of v1 — see §13) Family-gathering reminders are explicitly deferred |

## 12. Constraints

- **C1.** iOS 17+ minimum (`@Observable`)
- **C2.** Real device required (camera). No simulator support.
- **C3.** Single binary for iPhone + iPad. No iPad-specific layout in v1.
- **C4.** No backend. No CloudKit. In-memory state only.
- **C5.** No third-party SDKs. Cuts attack surface for the privacy promise.

## 13. Success metrics

Because we deliberately collect no telemetry (NF13), success is measured
**qualitatively** in target-audience testing.

| Metric | Target | Method |
|---|---|---|
| First-session completion | ≥80% finish a round unaided | Observation, n≥10 |
| Setup understandable | ≥80% get through tutorial without help | Observation |
| Comfortable difficulty | ≥70% rate "just right" | 3-pt post-session question |
| Trust signal | ≥90% report "feels safe" | Single Likert |
| Enjoyment | ≥70% "I'd play this again" | Single Likert |
| Zero critical bugs | 0 crashes, 0 stuck states | Bug log |

Pass criteria for v1 ship: all 6 met with ≥10 testers fitting Linda's profile
(retired, 57+, moderate tech literacy).

## 14. Out of scope (v1)

| Out of scope | Why deferred |
|---|---|
| Audio cues on catch / miss / countdown | Needs sound design + accessibility review |
| Adaptive difficulty (catch-rate driven) | Need real-user data first — auto-tune without data is worse than fixed |
| In-app difficulty toggle | One calibrated baseline is clearer to launch with |
| Multi-language word pools (Bahasa Indonesia, etc.) | Add after English baseline validates with target persona |
| Settings screen | Nothing meaningful to set in v1 |
| Family-gathering reminders | Useful for Linda — but a separate "reminder" product, not this game |
| Persistent score history | Not a stats product |
| Social sharing / leaderboards | Not a social product |
| Pause mid-round | Exit-to-menu is the only mid-round action |
| Apple Watch / VisionOS | Out of scope |
| Caregiver-facing companion screen | Separate product surface |

## 15. Risks & assumptions

### Assumptions

- **A1.** Target users have an iPad or iPhone propped on a stable surface
- **A2.** They can stand 3–6 ft from the camera for one round
- **A3.** They can read 4–6 letter English words at 38pt
- **A4.** They have moderate hand mobility (can open and close a fist)
- **A5.** The English word pool feels uplifting, not infantilizing
- **A6.** Linda's profile generalizes to ~70%+ of retired 57+ users in our market
  (validated by 3 interviews — we'll re-check with more testers)

### Risks

| Risk | Mitigation |
|---|---|
| Hand tracking degrades in dim home lighting | Tutorial hints "make sure you have good lighting" |
| Players don't realize palm must be **open** to catch | Tutorial page 3 explicitly: "Open your hand wide" |
| 3-second hold-to-exit is confusing | (Open Q1) Possibly swap to tap → confirm modal |
| Pre-selected Solo confuses Duo players | They see Solo highlighted, tap Duo, no harm — confirmed in testing |
| Word vocabulary feels random or culturally off | Pool curated for warm/positive tone in English. Bahasa pool deferred to post-v1 |
| Catch radius too generous = trivial / too tight = frustrating | Calibrated in target-user testing; knob at top of `Game.swift` |
| Linda doesn't know what "AirPlay" is | (Open Q2) The AirPlay screen may need rewording — "use a bigger screen" is the actual user value |

## 16. Open questions

- **Q1.** Hold-to-exit vs. tap → confirm modal — which is more intuitive for Linda?
- **Q2.** AirPlay screen — does the word "AirPlay" mean anything to Linda? Test alternative copy.
- **Q3.** Should the tutorial be skippable on the 2nd+ session?
- **Q4.** Should Continue be disabled when no mode is selected (even with Solo pre-selected)?
- **Q5.** Should the winner overlay prompt "best of 3"?
- **Q6.** Is "Duo on one device" actually what Linda + her husband do, or do they each want their own phone?

## 17. Tuning reference

All gameplay parameters live at the top of `WordCatch/Views/Manager/Game.swift`:

```swift
let winScore = 7                          // first-to-N to win
private let maxOnScreen = 3               // simultaneous words cap
private let spawnInterval = 5.0...7.0     // seconds between spawns
private let fallDuration  = 5.0...7.0     // seconds top→bottom
private let catchRadiusFraction = 0.24    // forgiveness
```

| Profile | winScore | spawnInterval | fallDuration | catchRadius |
|---|---|---|---|---|
| Younger users (under 50) | 15 | 3.0…5.0 | 3.0…5.0 | 0.18 |
| **Linda's profile (current default)** | **7** | **5.0…7.0** | **5.0…7.0** | **0.24** |
| Memory care / very gentle | 5 | 7.0…10.0 | 7.0…9.0 | 0.28 |

---

## Research artifacts

- **Miro board:** C26-CH3, Group 19 (Gung, Tio, Ryan, Lori, Felis)
- **Persona empathy maps:** in `WordCatch/TOPIC/` screenshots
- **User interviews:** 3 sessions with target-segment retirees
- **Refined challenge** and **challenge response** statements ratified by the team

The persona shown in §4 (Linda Wijaya) is the synthesized primary persona from
the empathy mapping exercise. Secondary personas exist on the board and can be
added here if the product expands beyond Linda's profile.
