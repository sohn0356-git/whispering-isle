# Prototype Plan

## Goal
Build a minimal playable slice where the player explores a small harbor scene and chats with one NPC to complete a simple favor.

## Scope
- **Environment:** Blockout of Mistveil Harbor pier with walkable bounds and visual markers.
- **Character:** Placeholder player model with idle/walk animations; single NPC (Mira Tidekeeper) with looping idle.
- **Interaction:** Prompt appears when close to NPC; dialogue tree with greeting, request, completion branch.

## Required Systems
- Third-person or top-down movement controller with collision + camera follow.
- Simple UI prompts for interaction and quest journal entry.
- Dialogue system supporting branching text and quest flag updates.
- Collectible mock item (e.g., lost tide marker) tracked in inventory.
- Save stub to retain quest completion state (optional stretch).

## Success Criteria
Player can load the scene, walk smoothly, speak with Mira, retrieve the marker, return it, and see a confirmation that the harbor is ready for the next milestone.
