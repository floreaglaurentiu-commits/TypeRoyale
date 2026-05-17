# TypeRoyale Development Tasks

This task list is focused on making the current project functional end-to-end and resolving the missing definitions / broken matchmaking.

## 1. Core match flow (MVP)

- [ ] Define and implement a proper match lifecycle:
  - queue -> match found -> countdown -> match start -> progress sync -> match end
- [ ] Implement `MatchFound` or countdown event so clients do not immediately start when the server pairs players.
- [ ] Add match timeout logic in `MatchService` for stale matches and disconnected players.
- [ ] Ensure `MatchService.EndMatch` handles draws, disconnects, and rewards cleanly.

## 2. Networking and event definitions

- [ ] Verify `shared/Networking/Events.lua` event names and usage are consistent.
- [ ] Use `Events.List` values everywhere instead of hard-coded strings when possible.
- [ ] Add explicit definitions / validation for all remote events:
  - `QueueJoin`
  - `QueueLeave`
  - `MatchFound`
  - `MatchStart`
  - `MatchProgress`
  - `MatchEnd`
- [ ] Confirm the client and server are using the same event payload shapes.

## 3. Matchmaking system

- [ ] Fix the queue join flow so `QueueService.JoinQueue` is actually triggered and the client sees status updates.
- [ ] Add queue state / searching feedback to the main menu UI.
- [ ] Improve matchmaking to support:
  - duplicate prevention
  - requeue after failed pairing
  - player disconnect handling during queue
- [ ] Add a simple ranked matchmaking placeholder using player rank/MMR before moving to full MMR.

## 4. Client match controller and UI

- [ ] Add opponent progress handling in `ClientMatchController` so the UI can render live opponent race state.
- [ ] Implement a dedicated match HUD state update with:
  - current text
  - typed text
  - remaining text
  - opponent progress
  - timer
- [ ] Add a post-match result screen, then return to menu cleanly.
- [ ] Ensure UI hooks are defined before `ClientMatchController` calls them; guard against nil.
- [ ] Wire `MainMenuController` and `MatchUIController` to real match state, not just button press.

## 5. Typing and validation

- [ ] Implement a text bank / generation system for match text, instead of hard-coded sample text.
- [ ] Improve `KeyboardHandler` to better support shift states and punctuation.
- [ ] Fix typing progress calculation so the client and server agree on current text position.
- [ ] Harden `ServerTypingValidation` to reject cheating reliably and to update player state correctly.
- [ ] Add validation for:
  - impossible WPM spikes
  - invalid progress packet payloads
  - repeat progress updates after match end

## 6. Required definitions and missing data

- [ ] Confirm all common/shared modules are present and referenced correctly:
  - `Constants/GameConfig.lua`
  - `Typing/Math.lua`
  - `Networking/Events.lua`
- [ ] Define any missing shared types or constants used in `MatchService` and client code.
- [ ] Ensure `ClientMatchController.JoinQueue()` uses a valid remote event and that the server handler is registered.
- [ ] Add any missing `require` paths or `ReplicatedStorage.Shared` structure elements expected by the current code.

## 7. Production-ready improvements

- [ ] Add countdown visuals and sound effects on match start.
- [ ] Add matchmaking feedback text: searching, found opponent, ready.
- [ ] Add live opponent progress visualization to the HUD.
- [ ] Implement event-driven state cleanup when players leave mid-match.
- [ ] Add error handling/logging for all remote event callbacks.

## 8. Debug and diagnostics

- [ ] Verify and fix the 34 reported internal errors by running a Luau/static check on all `src/` files.
- [ ] Check for runtime issues in Roblox Studio output when the game loads.
- [ ] Validate that `Rojo` sync is working for both server and client scripts.
- [ ] Create a minimal reproduction test: two players join queue, get matched, type the text, and receive a result.

## 9. Long-term structure

- [ ] Create separate modules for:
  - queue manager
  - match manager
  - text bank
  - ranking/progression
  - anti-cheat
- [ ] Establish a clear shared API for remote event payloads.
- [ ] Add a `PlayMode` enum or mode registry to support Ranked, Arena, Hardcore, Zen, etc.

## 10. Immediate bug fixes likely causing the current breakage

- [ ] Verify `QueueService` and `MatchService` both run on the server and are loaded by `ServerMain.server.lua`.
- [ ] Confirm `MatchProgressEvent` is a server RemoteEvent when clients fire it.
- [ ] Confirm `MatchStartEvent` payload includes `text` and `opponent` on both clients.
- [ ] Ensure `ClientMatchController` does not accept keystrokes before `isInMatch` is true.
- [ ] Ensure `MatchEndEvent` is fired to both players and the client resets state.

---

### Notes

This list is designed to address the current “matchmaking doesn’t work and nothing is defined” state. The highest-priority work is making the queue + match flow functional, then adding proper client-server synchronization and shared definitions.
