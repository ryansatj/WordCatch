# WordCatch

A camera-based hand-tracking game designed for adults **57+**. Words fall from the
top of the screen; players catch them with open palms. The pace, vocabulary,
catch tolerance, and UI are all tuned for older players.

---

## What the game is

- Phone or iPad sits on a stand. Camera faces the player(s).
- Words fall on each side of a split screen (P1 left, P2 right).
- Open your palm under a word to catch it. Close your hand or miss → it falls.
- First to **7 catches** wins.
- A round lasts ~60–90 seconds with 8–12 words spawned, max 2–3 visible at a time.

## Who it's for

Adults aged ~57+. The design hits three skills that get harder with age in one
session — without the fall risk of a full-body game:

| Stimulates | Provided by |
|---|---|
| Language recognition | Reading the falling words |
| Visual attention | Tracking a moving target |
| Light upper-body movement | Reaching with the palm |

**Not** a fitness app. **Not** a medical exercise. It's framed as recreation —
gentle, dignified play.

## Design choices that follow from that

| Choice | Reason |
|---|---|
| Words fall in 5–7 seconds | Slower than reflex-game speed |
| Max 3 words on screen | No cognitive overload |
| Real, uplifting words (`happy`, `family`, `morning`, `coffee`…) | Recognizable, dignified vocabulary |
| First-to-7, not first-to-20 | Keeps rounds under arm-fatigue threshold |
| Catch radius = 22% of shorter screen dim | Forgiving for shaky hands |
| 38pt heavy rounded type | Readable in motion |
| 3-second hold-to-exit | Stops accidental dropouts mid-game |
| Pick-then-confirm mode selection | No accidental single-tap mistakes |
| Auto-advancing tutorial + swipe back | No "Next" button hunting, but reviewable |

---

## App flow

```
Splash → Player Selection → Airplay Prompt → Tutorial → Gameplay → Winner
   ↑                                                                  │
   └──────────────────── Exit (hold 3s) ──────────────────────────────┘
```

1. **Splash** — animated mascot intro, ends with **Play** CTA
2. **Player Selection** — Solo / Duo cards, two-step (pick → Continue)
3. **Airplay Prompt** — recommends a larger screen (Learn More / Continue)
4. **Tutorial** — 3 setup positioning pages, auto-advances, "I'm Ready!" on last
5. **Gameplay** — camera + hand-tracking + falling words + score HUD
6. **Winner** — trophy reveal, Play Again / Exit via `RoleButton`

---

## Tech stack

- **SwiftUI** (iOS / iPadOS) — UI + animations
- **Vision** — `VNDetectHumanHandPoseRequest` for 21-joint hand tracking
- **AVFoundation** — front camera capture session
- **`@Observable`** — game state propagation
- Orientation locked to **landscape** for gameplay, **portrait** for menus

### Catch detection

A word is caught when the player's open palm comes within
`min(width, height) * 0.22` of the word's center, on the player's own side.

A palm is "open" when at least 4 of 5 finger tips are extended further from the
wrist than their PIP joints (with confidence > 0.3).

---

## Project structure

```
WordCatch/
├── WordCatchApp.swift          ← @main, @UIApplicationDelegateAdaptor
├── ContentView.swift           ← top-level Screen enum + transitions
├── Utilities/
│   └── OrientationManager.swift   ← lockLandscape / lockPortrait
├── Views/
│   ├── Screens/
│   │   ├── SplashScreen.swift
│   │   ├── PlayerSelectionScreen.swift
│   │   ├── AirplayOptionScreen.swift
│   │   ├── Tutor.swift           ← tutorial carousel
│   │   └── Gameplay.swift        ← composes the game pieces
│   ├── Manager/
│   │   ├── Game.swift            ← scoring + spawn loop (tuning knobs here)
│   │   ├── HandDetection.swift   ← Vision pipeline
│   │   └── PreviewGwame.swift    ← AVCaptureVideoPreview wrapper
│   └── Model/
│       └── Model.swift           ← FallingWord, HandSnapshot
└── Component/                    ← design system
    ├── AppAnimations.swift       ← every screen-level Animation / Transition
    ├── AppTypography.swift       ← .display / .h1 / .h2 / .bodyText / .caption
    ├── Buttons/
    │   ├── RoleButton.swift      ← primary / secondary / ghost variants
    │   ├── IconButton2.swift     ← circular icon w/ variant + chunky shadow
    │   ├── NoFadeButtonStyle.swift
    │   └── Oldbutton/            ← legacy IconButton / ChunkyButton
    └── Game/
        ├── GameHUD.swift         ← score pills + divider + GameExitButton
        ├── GameOverlays.swift    ← camera loading + countdown + winner
        ├── FallingWordView.swift
        └── HandSkeletonView.swift
```

---

## Design system

### Buttons

| Component | Use |
|---|---|
| `RoleButton` | Text buttons — primary / secondary / ghost variants, sizes `xl`/`lg`/`md`/`sm` |
| `IconButton2` | 44×44 circle icon button, same variant system |
| `GameExitButton` | Hold-3-seconds-to-confirm exit (gameplay-specific) |
| `GameCloseButton` | Translucent dark X (camera overlay) |

### Animations

All screen-level motion lives in `Component/AppAnimations.swift`. Examples:

```swift
.transition(.slideForward)            // forward screen nav
.animation(.screenSwitch, value: x)   // ContentView screen swap
withAnimation(.entrance) { ... }      // hero element spring-in
withAnimation(.cardAppear) { ... }    // staggered cards
withAnimation(.iconPulse.repeatForever(autoreverses: true)) { ... }
```

### Typography

```swift
.font(.display)    // 44pt heavy — splash titles
.font(.h1)         // 32pt heavy — screen titles
.font(.h2)         // 22pt bold — section headers
.font(.bodyText)   // 17pt medium — body copy
.font(.caption)    //13pt medium — labels
```

### Brand colors

| Asset | Use |
|---|---|
| `OrangeBrand` | Primary, Player 1, accents |
| `BrownBrand` | Secondary, Player 2, text on light bg |

---

## Tuning the game for different audiences

All gameplay knobs live at the top of `Views/Manager/Game.swift`:

```swift
let winScore = 7                          // first-to-N to win
private let maxOnScreen = 3               // most words visible at once
private let spawnInterval = 5.0...7.0     // seconds between spawns
private let fallDuration  = 5.0...7.0     // seconds for a word to fall top→bottom
private let catchRadiusFraction = 0.24    // forgiveness
```

| For… | Try |
|---|---|
| Younger players | `winScore = 15`, `fallDuration = 3.0...5.0`, `catchRadiusFraction = 0.18` |
| Memory care | `winScore = 5`, `spawnInterval = 7.0...10.0`, `fallDuration = 7.0...9.0` |
| Default (elder) | values shown above |

The word pool also lives in `Game.swift` — swap for a different vocabulary set
without touching anything else.

---

## Orientation

`OrientationManager.shared` exposes `lockLandscape()` and `lockPortrait()`.
For these to actually take effect, `AppDelegate.application(_:supportedInterface
OrientationsFor:)` returns the current `mask` — this is wired up in
`WordCatchApp.swift` via `@UIApplicationDelegateAdaptor`. Without that hook,
`requestGeometryUpdate(...)` is silently ignored by iOS.

---

## Running

1. Open `WordCatch.xcodeproj` in Xcode 15+
2. Target iOS 17+ (uses `@Observable`)
3. Run on a real device — the simulator has no camera
4. First launch requires Camera permission

---

## Status

Built as a focused single-purpose game. Not yet shipped to App Store. Ideas
intentionally left out (so you can decide later):

- Audio cues on catch / miss
- Adaptive difficulty based on catch rate
- Difficulty toggle on the menu
- Multi-language word pools
- Score history / weekly streak
