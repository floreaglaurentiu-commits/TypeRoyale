# TypeRoyale — Core Gameplay & Offline Gamemode Roadmap

This document serves as the implementation checklist and technical foundation for the **Offline Practice / Practice Mode** of TypeRoyale. Building this offline flow first guarantees that our core typing engine, UI feedback, metric calculations, and feel are absolutely polished and robust before we hook them up to the multiplayer matchmaking server.

---

## 🎨 Design References
> [!NOTE]
> Detailed design visual references, screen mockups, and UI styles (such as esports graphics, menu screens, and in-game layouts) are located in the [DesignRef](file:///e:/WorkRelated/Roblox/VersionControl/dev-stage1000/TypeRoyale/DesignRef) folder. These assets should guide the color palettes, transitions, and dynamic effects of the HUD.

---

## 📋 Core Architectural Goal
To establish a fully functional, self-contained client-side typing match loop that feels incredibly premium (tactile click feedback, dynamic camera effects, neon combo escalation) and tracks performance accurately. Once this foundation is solid, multiplayer integration will simply involve passing the progress packets to `MatchService` and swapping the local bot progress with real player network packets.

---

## 🚀 Step-by-Step Task Roadmap

### 📦 Phase 1: Core Systems & Asset Setup
*Define the rules, data libraries, and low-level key bindings.*

- [x] **1.1. Create Shared Text Bank (`src/shared/Typing/TextBank.lua`)**
  - Define categorized text arrays: `Quotes` (philosophical, esports), `Words` (pure word list like Monkeytype), and `Meme` (fast slang, funny phrases).
  - Expose a clean API: `TextBank.GetRandomText(category: string, difficulty: string): string`.
  - Ensure compatibility so both Client (for offline play) and Server (for online validation) can use it.

- [x] **1.2. Refine Game Configuration (`src/shared/Constants/GameConfig.lua`)**
  - Add specific parameters for practice mode:
    ```lua
    GameConfig.Practice = {
        BotSpeeds = { Easy = 30, Medium = 60, Hard = 90, Insane = 120 }, -- WPM
        CountdownDuration = 3,
        DefaultCategory = "Quotes",
        DefaultDifficulty = "Normal"
    }
    ```

- [x] **1.3. Harden Keyboard Input Capture (`src/client/Input/KeyboardHandler.lua`)**
  - Fix any potential issues with special characters (punctuation, capitals, numeric symbols).
  - Guarantee that when typing is active, other player controls (like default Roblox emote wheels, camera zoom with hotkeys, or jumping) are completely disabled.
  - Implement clean focus loss and recapture guards to prevent the typing text box from losing focus if the user clicks outside.

---

### 🎨 Phase 2: Beautiful HUD & Cinematic Transition
*Craft a gorgeous cyber-esports interface inspired by Clash Royale's hierarchy and Monkeytype's sleek minimalism.*

- [x] **2.1. Dynamic Selection Menu**
  - Add an options layout when clicking **OFFLINE TEST MODE** on the main menu.
  - Allow the player to pick:
    - **Mode**: Zen (no timer/no bot) or Bot Duel.
    - **Bot WPM Speed**: 30, 60, 90, 120.
    - **Text Category**: Quotes, Common Words.

- [x] **2.2. Premium UI Transition**
  - Implement smooth fade-out tweens for `MainMenuController`.
  - Freeze the character, turn base parts transparent, and position the current camera at a stylized, neon-lit typing cockpit backdrop.

- [x] **2.3. Monospace Typing Box & RichText Rendering**
  - Re-engineer the text display in `MatchUIController.lua` to leverage professional monospace fonts (e.g., `Enum.Font.Code`).
  - Implement a character-by-character RichText highlighter:
    - **Correct characters**: Glowing purple or electric teal `<font color="#8A2BE2">`
    - **Mistake characters**: Bold crimson neon `<font color="#FF0000"><u>`
    - **Remaining characters**: Soft muted charcoal/gray `<font color="#808080">`
  - Position an animated, vertical cursor bar indicator that blinks at the current character index.

- [x] **2.4. Active Letter Caret Overlay / Highlight Box**
  - Implement a completely transparent, hollow neon highlight box outline placed directly over the character the user is currently on (active index).
  - The highlight box adjusts its width and position dynamically and moves fluidly as the player types, providing a strong visual focus point without obscuring the text.

---

### 🎬 Phase 3: The Pre-Match Countdown (Cinematics & Build-up)
*Build the "every match feels important" tension before the typing begins.*

- [x] **3.1. Cinematic Ticking**
  - On transition, render large, center-screen neon numbers (3... 2... 1...).
  - Use `TypingFeedback.PlayCountdown()` to trigger high-quality clicking/ticking sounds matching the numbers.
  - Apply scale-up and fade-out tweens to each number as it displays.

- [x] **3.2. Heartbeat Screen Vignette Pulse**
  - Apply a subtle screen vignette pulse (darkening edges) and camera zoom bumps synchronized with each countdown second.

- [x] **3.3. The "GO!" Ignition**
  - Play a heavy bass synthetic "GO!" sound.
  - Enable typing input (`KeyboardHandler.Enable()`) and start the timer immediately.

---

### ⌨️ Phase 4: Core Typing Loop & Real-Time Metrics
*The primary feedback loop that keeps the player focused and rewards speed.*

- [x] **4.1. Exact Input Casing and Backspace Logic**
  - Backspace deleting is disabled completely by design so all mistakes are permanent and locked in.
  - Typing a typo registers as an error, muting the combo multiplier, but the cursor index advances forward normally without blocking.
  - Ensure that spaces correctly register and colorize properly.

- [x] **4.2. Precision Metrics Calculation (`src/shared/Typing/Math.lua`)**
  - Maintain real-time calculations on every keystroke:
    - **WPM**: Calculated as `(Correct Keystrokes / 5) / (Time Elapsed / 60)`.
    - **Accuracy**: `(Correct Keystrokes / Total Keystrokes) * 100`.
    - **Combo**: Consecutive error-free keys.
  - Display these stats live on the left panel with subtle bounce animations whenever they increase.

- [x] **4.3. Visual Combo Milestones**
  - Create milestone visual feedback:
    - **Combo x10**: HUD borders start glowing cyan.
    - **Combo x25**: Play subtle neon spark trails across the screen.
    - **Combo x50+ ("Flow State")**: UI colors transition to animated gradients; background music increases pitch/intensity slightly.

---

### 🔊 Phase 5: High-Fidelity Feedback & Juice (Dopamine FX)
*Transform a text-entry box into a satisfying, juicy game loop.*

- [x] **5.1. Mechanical Keyboard Switch Sounds**
  - Incorporate audible click feedback on each key press.
  - Scale the pitch or volume up slightly as the combo multiplier rises.

- [x] **5.2. Error Impact FX**
  - On mistake:
    - Play a distorted error buzz.
    - Screen-shake the camera slightly (using a spring-like function for crisp vibration).
    - Pulse a translucent red border around the screen for 100ms.
    - Instantly reset combo back to `0` and mute the high-combo music effects.

---

### 🤖 Phase 6: Simulated Practice Bot (Ghost Battles)
*Inject competitive tension even when playing solo.*

- [x] **6.1. Natural Bot Speed Simulation**
  - Create a local bot progress timer inside `ClientMatchController`.
  - Move the bot's typing index forward at the chosen target WPM.
  - Introduce random human-like variance (slowing down on complex/punctuation words, speeding up on short words, occasionally pausing for 100-200ms).

- [x] **6.2. The Dual Race Track Visual**
  - Mount a "Race Track" UI element at the top of the screen:
    - Render two premium horizontal progress tracks.
    - Track 1 (Cyan/Neon): Displays Player's name, avatar, and completion percentage.
    - Track 2 (Orange/Cyber): Displays the Bot's name ("CyberBot"), avatar, and percentage.
  - Include a dynamic live lead indicator showing who is ahead and by how many words.

---

### 🏆 Phase 7: Match Termination & Premium Statistics
*Make completing a match extremely satisfying and highly streamable.*

- [x] **7.1. Win/Loss Evaluation**
  - Detect immediately when the Player or Bot reaches 100% completion of the text.
  - Disable typing input (`KeyboardHandler.Disable()`) instantly to freeze WPM and accuracy metrics.

- [x] **7.2. Epic Victory Fanfare / Defeat Meltdown**
  - **Victory**: Run a screen-wide particle confetti explosion, play a triumphant neon fanfare, and display "VICTORY" with a neon yellow glow.
  - **Defeat**: Play a low digital power-down sound effect and display "DEFEAT" in glowing orange.

- [x] **7.3. Beautiful Analytical Result Card**
  - Construct a summarizing results panel:
    - **Primary Stats**: Large, stylized displays for **Final WPM**, **Accuracy**, and **Max Combo**.
    - **Secondary Stats**: Duration (seconds), keys typed, mistake count.
    - **Dopamine unlocks**: If they set a new personal record, display a flashy "NEW BEST WPM!" animation.
  - Expose two sleek buttons:
    - **RETRY**: Instantly mounts the countdown with a fresh text from the text bank.
    - **MAIN MENU**: Fades out the HUD and cleanly remounts the main lobby.

---

## ⚡ Unified Client-Server Foundation (Ready for Online 1v1)
*Ensuring the offline code is a drag-and-drop base for multiplayer.*

- [x] **8.1. Decoupled Progression Handlers**
  - Design the progress reporting hook in `ClientMatchController` so it looks like this:
    ```lua
    local function reportProgress(progressIndex, isFinished)
        if isOfflineMatch then
            -- Handle locally
        else
            -- Fire server event
            MatchProgressEvent:FireServer({
                correctCount = correctKeystrokes,
                totalKeystrokes = totalKeystrokes,
                isFinished = isFinished
            })
        end
    end
    ```
  - This guarantees zero duplicate typing loops and makes shifting to multiplayer extremely clean.

- [x] **8.2. Reusable Math & Anti-Cheat Validation**
  - Leverage `shared/Typing/Math.lua` for all calculations, guaranteeing that the local WPM displayed in offline mode matches the server-validated WPM exactly.

---

### 🎨 Phase 9: Premium HUD Esports Polish (Parity with InGame.jpeg)
*Polishing visual aesthetic layers to match the esports 1v1 graphic design reference.*

- [x] **9.1. Head-to-Head Scoreboard VS Header**
  - Built a competitive versus header containing glowing avatar frames, usernames, rank tags (`DIAMOND II`), and striped diagonal progress fill bars for player and bot.
  - Placed a gold crown emblem and ticking pill-box match timer centrally.
- [x] **9.2. Dual-Gradient typing boundary**
  - Styled the border outline of the center typing panel with a dual gradient transition from cyber purple to gold.
- [x] **9.3. Stacked left-side statistics column**
  - Reorganized stats dynamically into distinct cyan WPM, white ACC, pink COMBO, and red MISTAKES text rows, plus a separate lower card for BEST COMBO.
- [x] **9.4. Symmetric right-side quest indicators**
  - Mounted Ranked RP progression indicators and Daily Quest checkmarks for feature-rich, high-production value representation.
- [x] **9.5. Interactive virtual key highlighted QWERTY keyboard**
  - Placed a complete floating QWERTY keyboard layout at the bottom of the HUD that lights up and flashes keys in real time when typed.

---

### 🏆 Phase 10: Cinematic Results Standings & Rank Progression (Esports Victory Screen)
*Delivering an epic, jaw-dropping match end comparison panel with rolling stats and ranks.*

- [x] **10.1. Comparative Dual Column Scoreboard**
  - Replaced the simple metrics list with a side-by-side comparison scoreboard comparing "YOU" (Cyan/Emerald Theme) vs "BOT" (Orange/Gold Theme) side-by-side.
  - Displays circular avatar outline frames, bold usernames, WPM Speed, Accuracy %, Max Combo, Keystrokes, and Mistakes for both competitors.
- [x] **10.2. Spring Elastic Scaling Card Intro**
  - Configured the results modal frame to scale up from zero using an elastic bounce ease (`Enum.EasingStyle.Back`) for visual crunch and punchy UX.
- [x] **10.3. Real-Time Rolling Counter Numbers**
  - Coded an animated ticker thread that rolls numbers up dynamically from 0 to target stats, synchronized with tactile mechanical click audio sounds.
- [x] **10.4. Ranked rating slide and RP rewards**
  - Positioned a beautiful central RP bar showing progression and floating RP rating reward notifications (`+25 RP` on victory, `-10 RP` on defeat) with glowing diamond badge emblems.
- [x] **10.5. Daily Quest checkmarks updates**
  - Triggers a green checklist check animation and success bells when quests are updated at the finish line.

---

### 🌐 Phase 11: Online Multiplayer Matchmaking & Lobby (Tasks 1-5)
*Moving from solo practice to the competitive 1v1 online arena.*

- [ ] **11.1. Multiplayer Lobby Matchmaking GUI**
  - Design a premium glassmorphism queue screen with estimated wait times and live active-player counters.
- [ ] **11.2. Server-Side Matchmaker Engine**
  - Implement a queue collector that pools active players and pairs them based on Rank Rating (RP) thresholds.
- [ ] **11.3. Match Cancellation Handlers**
  - Build robust cancellation hooks to safely remove players from the queue when they exit or lose focus.
- [ ] **11.4. Server-Side Match Allocator**
  - Create a master manager that instantiates dynamic match session records on match start, locking in target quotes.
- [ ] **11.5. Seamless Match Transporter**
  - Wire up server-to-client triggers that automatically transition both matched clients into the live cockpit.

---

### 📡 Phase 12: Real-Time Network Progress Sync (Tasks 6-10)
*Visualizing the opponent's keystrokes and progress in real-time.*

- [ ] **12.1. Opponent Progress Net Events**
  - Set up highly efficient RemoteEvents (`MatchProgressUpdate`) for sending client index progression updates to the server.
- [ ] **12.2. Network Update Throttling**
  - Rate-limit updates to prevent network exhaustion (e.g. transmit progress every 3 characters or 100ms instead of every key).
- [ ] **12.3. Opponent Progress Bar Interpolation**
  - Code visual tween smoothing inside `MatchUIController` to prevent opponent avatar jumping due to latency.
- [ ] **12.4. Disconnection & Rage-Quit Listeners**
  - Detect if the opponent leaves the match or loses connection, immediately halting play and declaring victory.
- [ ] **12.5. Post-Match Synced Results Screen**
  - Swap the simulated practice bot's columns on the results screen with real opponent stats fetched from the server.

---

### 🛡️ Phase 13: Server-Side Anti-Cheat & Keystroke Verification (Tasks 11-15)
*Guaranteeing competitive integrity and preventing macro/auto-typer exploits.*

- [ ] **13.1. Server-Side Text Validation**
  - Verify that each client-reported index actually matches the character sequence of the designated match text on the server.
- [ ] **13.2. WPM Human Boundary Verifier**
  - Implement mathematically validated human bounds checking: reject finishes exceeding plausible speeds (e.g., >250 WPM).
- [ ] **13.3. Keystroke Intervals Variance Auditer**
  - Analyze keystroke intervals (time between typed keys); flag players with zero variance (indicative of auto-typers).
- [ ] **13.4. Hard-Mistake Progress Locking**
  - Enforce server-side locking that blocks cursor progress if the client reports an index without clearing mistakes.
- [ ] **13.5. Exploitation Logging & Auto-Banning**
  - Set up discord webhook or database logging that flags suspicious accounts and prevents them from entering competitive matches.

---

### 📊 Phase 14: Ranked Datastores & RP Rating Systems (Tasks 16-20)
*Creating a persistent competitive ladder and storing historical typist statistics.*

- [ ] **14.1. Player Profile Stats Datastore**
  - Set up Roblox DataStoreService schemas to track player stats (total wins, WPM records, total characters typed).
- [ ] **14.2. Ranked RP (Rating Points) Allocator**
  - Program an Elo-based RP progression scale: calculate point payouts (+25 RP on victory, -15 RP on defeat) adjusted for rank gap.
- [ ] **14.3. Competitive Tier Promotion Screens**
  - Construct animated promotion/demotion splash panels (e.g. glowing diamond transition screens upon tier rank ups).
- [ ] **14.4. Daily Quests Progress Persistence**
  - Integrate quest progression into data saving, ensuring quest progress spans multiple gameplay sessions.
- [ ] **14.5. Global Top 50 Ranked Leaderboard**
  - Design a massive neon lobby leaderboard showcase that queries and displays the top 50 competitive typists worldwide.
