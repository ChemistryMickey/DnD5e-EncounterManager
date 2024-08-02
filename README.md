# Dungeons and Dragons 5e Encounter Manager
A small Godot User Interface for managing Dungeons and Dragons, 5th edition, encounters.

This should be especially useful in encounters with lair actions and spellcasters.

## How to use
- Populate PC database by Defining PCs in "Edit/Define PC"
- Populate NPC database by Defining NPCs in "Edit/Define NPC"
- Add PCs, NPCs, and "Non-Actors" (e.g. lair actions) to the initiative order using the top "Add PC"/"Add NPC"/"Add Non-Actor" buttons
- Enter initiative of each PC/NPC/Non-Actor
- "Sort By/Initiative" to auto-sort (you may also manually sort by selecting the line (left-box) and moving up and down with the up and down arrow buttons)
- Begin the encounter ("Next Turn" begins as "Start Encounter" and morphs into "Next Turn"). The blue highlight moves with the current turn in the round.

## Quality of Life Features
- Easy action economy tracking (Action, Bonus Action, etc. radio buttons)
- Auto-clearing action economy at the start of your turn (Action, Bonus Action, etc.)
- Automatic decrementing statuses (this is enabled per-status because status updates are more complex than just "at the end of the actor's turn")
- Integrated spellbook with Core rulebook spells
- Spellbook supports adding custom spells
- Add multiple NPCs to the initiative by incrementing "# to add" in "Add NPC to Initiative" popup
- NPC info in bottom right (including tracking spell slots and spell list)
- Tracking multiple attacks
- Half-screen design
- Drag-able action economy/NPC info squares for convenient sizing
- Save/load such that encounters can be prepared in advance or encounters can persist between sessions

## Example
![Example Encounter](assets/example-encounter.png?raw=true "Example Encounter")