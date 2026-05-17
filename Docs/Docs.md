# TypeRoyale — Game Design Document (GDD)

## High Concept

TypeRoyale este un joc competitiv multiplayer de typing pentru Roblox, inspirat din energia și satisfacția jocurilor competitive moderne.

Jucătorii se duelează în meciuri rapide de typing unde viteza, precizia și consistența decid câștigătorul.

Gameplay-ul combină:

- competitive typing
- ranked matchmaking
- feedback vizual satisfăcător
- flow-state gameplay
- estetică cyber/esports
- progression și mastery

Nu este doar un typing game. Este un “competitive reaction + focus game”.

---

## Core Fantasy

Jucătorul trebuie să simtă:

- “Sunt foarte rapid.”
- “Îmi domin adversarul.”
- “Intră în flow.”
- “Mai joc încă un meci.”

Game-ul trebuie să creeze:

- tensiune
- satisfacție
- adrenalină
- mastery
- addiction loop sănătos

---

## Target Audience

### Primary Audience

- Roblox players 10–20 ani
- Competitive players
- Players care iubesc progression systems
- Players care joacă: osu!, Nitro Type, TypeRacer, Geometry Dash, rhythm games, esports-style games

### Secondary Audience

- Casual typing players
- Streamers
- TikTok creators
- Speed typing community

---

## Core Gameplay Loop

1. Player intră în lobby
2. Queue pentru matchmaking
3. Match found
4. Countdown cinematic
5. Typing duel începe
6. Players tastează același text
7. Real-time progress race
8. Winner screen
9. Rewards + rank progress
10. Instant requeue

Loop-ul trebuie să fie:

- rapid
- satisfăcător
- competitiv
- addictiv

Target round duration: 30 sec — 2 min

---

## Core Gameplay Mechanics

### Typing System

Players primesc același text.

Sistemul măsoară:

- WPM
- Accuracy
- Combo
- Consistency
- Reaction time

Typing-ul trebuie să se simtă:

- responsive
- clean
- smooth
- premium

---

### Error System

Greșelile trebuie să conteze.

- Penalties
- red flash
- combo reset
- micro delay
- sound distortion
- accuracy reduction

Goal: Precizia trebuie să fie la fel de importantă ca viteza.

---

### Combo System

Perfect typing creează combo.

Combo oferă:

- visual glow
- speed FX
- trail intensity
- heartbeat music escalation

Large combo = “flow state”.

---

### Real-Time Race Visualization

Players trebuie să vadă progresul adversarului LIVE.

Possible visualizations:

- moving avatars
- progress bars
- cyber race track
- energy beam race
- live percentage

Aceasta este componenta principală de tensiune.

---

## Matchmaking System

### Ranked Matchmaking

- Hidden MMR system.
- Matchmaking bazat pe:
  - WPM average
  - accuracy
  - recent performance
  - rank

Fast matchmaking este PRIORITATE.

Queue target: sub 10 sec

---

## Game Modes

### 1. Ranked Duel

- Main competitive mode.
- 1v1
- rank gain/loss
- seasonal leaderboard
- divisions
- placements

### 2. Arena Mode

- 8 players typing simultaneously.
- Top 3 câștigă.
- Perfect pentru:
  - spectating
  - TikTok clips
  - chaos gameplay

### 3. Hardcore Mode

- 1 mistake = elimination.
- High tension.
- Foarte streamable.

### 4. Zen Mode

- Relaxed typing.
- No ranks. No pressure.
- Focus pe:
  - aesthetic
  - music
  - flow

### 5. Rhythm Mode

- Typing sincronizat cu beat/music.
- Inspired by osu!, rhythm games
- Words apar pe timing windows.
- Scoring:
  - Perfect
  - Great
  - Good
  - Miss

### 6. Ghost Battles

- Player joacă împotriva replay-urilor altor players.
- Useful pentru:
  - practice
  - self improvement
  - offline feeling

---

## Ranking System

### Ranks

- Bronze
- Silver
- Gold
- Platinum
- Diamond
- Master
- Grandmaster
- Royale

Each rank:

- unique colors
- animated emblem
- profile badge
- season rewards

### Rank Progression

Players gain:

- RP (Rank Points)
- XP
- mastery score

Factors:

- win/loss
- accuracy
- consistency
- winstreak

### Seasonal System

- Each season: 30–60 days
- leaderboard reset soft
- exclusive cosmetics
- seasonal themes
- ranked rewards

---

## Statistics System

Track:

- average WPM
- highest WPM
- best accuracy
- longest combo
- wins/losses
- favorite language
- total typed words
- rank history
- clutch win rate

Players iubesc statisticile.

---

## Language System

One of the BIGGEST differentiators.

Supported languages:

- English
- Romanian
- French
- German
- Spanish
- Japanese
- Korean
- Russian

Possible future:

- custom community dictionaries
- language mastery ranks

---

## Text Generation System

Texts trebuie să fie:

- readable
- balanced
- fair
- scalable by difficulty

Categories:

- common words
- esports phrases
- internet slang
- long paragraphs
- quotes
- technical words
- meme mode

Difficulty scaling:

- beginner
- normal
- advanced
- impossible

---

## Anti-Cheat System

CRITICAL SYSTEM.

Typing games atrag:

- scripts
- macros
- auto typers

Server-side validation mandatory.

Detection examples:

- impossible WPM spikes
- perfect intervals
- robotic patterns
- no human variation
- impossible reaction times

Punishments:

- shadow queue
- rank lock
- temporary ban
- permanent ban

Without anti-cheat ranked dies.

---

## UX / UI Design Philosophy

IMPORTANT

TypeRoyale NU trebuie să arate ca un simulator Roblox generic.

Trebuie să pară:

- premium
- modern
- competitive
- esports-like
- smooth

---

## UI Inspiration

DA — ne putem inspira din structura și claritatea UI-ului din Clash Royale.

IMPORTANT: Nu copiem assets. Nu copiem layout 1:1. Nu copiem identitate vizuală.

Ne inspirăm din:

- clarity
- readability
- strong visual hierarchy
- polished animations
- satisfying feedback
- clean progression presentation

Clash Royale are:

- UI foarte clar
- feedback excelent
- progression extrem de satisfăcător
- reward openings dopamine-heavy

Asta vrem și noi.

---

## Visual Identity

### Main Aesthetic

Cyber esports aesthetic.

Mix între:

- neon
- modern esports UI
- rhythm game feedback
- typing culture
- clean minimalism

Inspirations:

- osu!
- VALORANT UI
- Monkeytype
- futuristic keyboards
- RGB setups

### Visual Style Rules

DO

- dark backgrounds
- strong contrast
- neon highlights
- smooth gradients
- glow effects
- responsive UI
- fluid animations
- crisp fonts

DO NOT

- simulator clutter
- random rainbow spam
- too many particles
- oversized buttons
- childish style
- low quality UI

### Color Palette

Primary:

- dark charcoal
- black
- deep navy

Accent Colors:

- cyan
- purple
- electric blue
- neon pink

Rank colors:

- Bronze = warm orange
- Silver = metallic gray
- Gold = bright gold
- Diamond = cyan/blue
- Royale = animated rainbow energy

### Typography

VERY IMPORTANT.

Fonts should feel:

- modern
- clean
- competitive
- readable at high speed

Possible inspirations:

- geometric sans fonts
- esports typography
- modern terminal aesthetics

Typing readability is priority #1.

---

## Main Menu Design

Main menu trebuie să fie foarte clean.

Central focus:

- Play button
- Rank display
- Current season
- Player profile

Secondary:

- Shop
- Inventory
- Leaderboards
- Missions
- Settings

Background:

- animated cyber city
- moving particles
- reactive keyboard visuals

---

## Match Intro

Before each match:

- cinematic countdown
- player cards
- rank display
- subtle camera movement
- sound build-up

Goal: Every match should feel IMPORTANT.

---

## In-Game UI

Must prioritize readability.

Display:

- current text
- typed text
- next letters
- combo
- WPM
- accuracy
- enemy progress
- timer

Animations should be:

- fast
- smooth
- responsive
- satisfying

---

## Audio Design

EXTREMELY IMPORTANT.

Typing games live or die by sound.

Sound Layers

- Typing Sounds
- mechanical keyboard feel
- soft tactile sounds
- customizable sound packs

Combo Sounds

- escalating intensity
- rhythm reinforcement

Match Sounds

- countdown
- victory sting
- rank up audio
- clutch warning

Music

- Dynamic electronic soundtrack.
- Inspired by rhythm games, cyberpunk ambience, esports intensity
- Music intensifies near finish.

---

## Spectator Experience

Watching should also be exciting.

Features:

- live WPM graphs
- combo display
- camera transitions
- clutch highlights
- replay system

Goal: TikTok and YouTube friendly.

---

## Progression Systems

### XP System

Players gain XP after every match.

Rewards:

- profile cosmetics
- keyboard skins
- titles
- banners
- effects

### Mastery System

Players level up:

- languages
- modes
- accuracy
- speed classes

Example: “English Master” “Hardcore Champion”

### Cosmetic System

Monetization focused on cosmetics.

Cosmetics:

- keyboard skins
- cursor trails
- profile banners
- animated avatars
- typing FX
- victory animations
- hit sounds
- UI themes

NO PAY TO WIN.

### Battle Pass System

Optional seasonal battle pass.

Contains:

- exclusive cosmetics
- currency
- animated rewards
- profile customization

Should feel rewarding but fair.

---

## Social Features

- Friends System
- private matches
- spectating
- party queue
- custom lobbies

### Clubs / Teams

Possible future update.

Players can:

- join typing clans
- compete in clan wars
- earn seasonal rewards

---

## Daily Retention Systems

- Daily Missions
  - Win 3 matches
  - Reach 98% accuracy
  - Type 500 words
  - Get 2 perfect games
- Login Rewards
  - currency
  - cosmetics
  - boosts
- Events
  - Limited-time modes
  - Halloween mode
  - Retro mode
  - Meme mode
  - Ultra Hardcore

---

## Monetization Strategy

Monetization must NOT ruin competitive integrity.

Monetization Sources:

- battle pass
- cosmetics
- premium themes
- animated profile cards
- typing sound packs
- emotes

Avoid:

- stat boosts
- gameplay advantages
- pay-to-win systems

---

## Technical Priorities

### Priority #1

Typing responsiveness.

Input delay must feel minimal.

### Priority #2

Server validation.

Competitive integrity first.

### Priority #3

Optimization.

Game should run smoothly on:

- mobile
- low-end PC
- tablets
- console UI support possible future

---

## Viral Potential Features

- Instant Replay Clips
- Auto-generate clutch finishes
- insame WPM moments
- perfect games

Perfect for TikTok.

---

## Streamer Features

- streamer mode
- audience tournaments
- custom rooms
- hide stream sniping info

---

## Long-Term Vision

TypeRoyale should evolve into:

- the definitive Roblox typing game
- an esports-style typing platform
- a social competitive experience
- a highly replayable skill game

Potential future:

- official tournaments
- creator cups
- world leaderboards
- rhythm typing maps
- custom songs
- map editor

---

## Development Priorities (MVP)

### Phase 1 — Prototype

Build:

- typing system
- text validation
- simple matchmaking
- 1v1 gameplay
- WPM tracking
- accuracy system

Goal: Find the “fun”.

### Phase 2 — Core Game

Add:

- UI polish
- ranked system
- progression
- cosmetics
- anti-cheat
- better visuals

### Phase 3 — Content Expansion

Add:

- multiple modes
- seasonal system
- battle pass
- social systems
- tournaments

---

## Success Metrics

Important KPIs:

- average session length
- rematch rate
- retention D1/D7/D30
- queue time
- average matches/session
- battle pass completion
- social shares

Most important metric: “one more game” feeling.

---

## Final Vision Statement

TypeRoyale este un competitive typing game modern pentru Roblox care transformă tastatul într-o experiență intensă, satisfăcătoare și highly replayable.

Prin gameplay rapid, UI premium, feedback excelent și progression systems puternice, jocul își propune să devină cel mai polished și addictive typing game de pe platformă.

Am făcut primul GDD complet pentru TypeRoyale, inclusiv:

- gameplay loop
- ranked systems
- modes
- UI/UX philosophy
- aesthetic direction
- anti-cheat
- progression
- cosmetics
- battle pass
- audio design
- long-term vision
- MVP roadmap

Și da — direcția inspirată din UI-ul Clash Royale este foarte bună dacă o folosești ca:

- clarity
- responsiveness
- dopamine feedback
- clean hierarchy

NU ca:

- copie vizuală directă.

Combinația:

- osu! feel
- Clash Royale polish
- Monkeytype aesthetic
- Roblox accessibility
