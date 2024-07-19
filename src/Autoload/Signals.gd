extends Node
#warning-ignore-all:unused_signal

## Window Open
signal show_notes()
signal show_spellbook()
signal show_add_pc()

## Spellbook
signal update_spellbook()

## Interactions
signal request_save()
signal request_load()
signal request_quit()

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
