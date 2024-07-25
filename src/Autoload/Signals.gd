extends Node
#warning-ignore-all:unused_signal

# Window Open
signal show_notes()
signal show_spellbook()
signal show_help()
signal show_add_PC()
signal show_add_NPC()
signal show_manage_PCs()
signal show_manage_NPCs()
signal show_add_NPCs_to_initative()

# Spellbook
signal update_spellbook()
signal update_PCs()
signal update_NPCs()

# Interactions
signal request_save()
signal request_load()
signal request_quit()

# Actor Specific
signal status_changed(actor_name: String)
signal add_NPC_to_initiative(npc_name: String)

### Character summary
#signal class_updated(class_choice)
#signal race_changed(race_choice)

### Inventory
#signal equip_item(name)
#signal unequip_item(name)
#signal display_item_info(node_name, item_name, info_text)
#signal item_info_changed(node_name, info_text)
#signal update_total_weights_and_values()
#signal display_item_database_info(string)
#signal add_item_to_inventory(selected_item, quantity)
#signal add_purchase_entry(selected_item, quantity, price)
