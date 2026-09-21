extends Node

signal debug_mode_changed(active: bool)

signal load
signal health(new_health)
signal level_reset
signal collected(collectable_type: E.COLLECT)
signal item_collected(item: E.CHEST_ITEMS)
signal upgrade_bought(item: E.CHEST_ITEMS, upgrade: Upgrades.Type)
signal state_changed(state)
signal upgrades_reset
signal player_died
signal setting_changed_bool(setting: E.BOOL_SETTING, value: bool)
