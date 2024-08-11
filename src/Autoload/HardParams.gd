extends Node

const STAT_NAMES = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
const SPELL_SLOT_NAMES = ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th"]

const VERSION = "0.1.1"

# Colors
const SELECTED_TRANSPARENCY = 0.3
const SELECTED: Color = Color(1, 1, 1, SELECTED_TRANSPARENCY)
const BLOODIED: Color = Color(1, 0.5, 0.5, SELECTED_TRANSPARENCY)
const ENCOUNTER_SELECTED: Color = Color("#0095DA", SELECTED_TRANSPARENCY)
