extends Node

enum Type {
	STRENGTH,
	RELOAD,
	SPEED,
	SIZE,
	SPREAD,
	BOUNCES
}

const STRENGTH = "strength"
const RELOAD = "reload"
const SPEED = "speed"
const SIZE = "size"
const SPREAD = "spread"
const BOUNCES = "bounces"

const init_reload_snowball = 0.6
const init_reload_icicle = 0.45
const init_speed_snowball = 750
const init_speed_icicle = 1000
const init_size_snowball = 1.0
const init_size_icicle = 1.0
const init_degrees_icicle = 6.0
const init_laser_fill_per_second = 0.02
const init_laser_time_total = 1.2
const init_laser_spread = 10.0
const init_laser_strength = 1.0
const init_flight_time = 5.0
const init_flight_wait_time = 30.0
const init_flight_speed = 450.0

var upgrades_variable_map: Dictionary = {
	E.CHEST_ITEMS.SNOWBALL: {
		Type.SIZE: "size_snowball",
		Type.STRENGTH: "damage_snowball",
		Type.RELOAD: "reload_snowball",
		Type.SPEED: "speed_snowball",
		Type.BOUNCES: "displayed_bounces"
	}, E.CHEST_ITEMS.ICICLE: {
		Type.STRENGTH: "damage_icicle",
		Type.RELOAD: "reload_icicle",
		Type.SPEED: "speed_icicle",
		Type.SPREAD: "degrees_icicle",
	}, E.CHEST_ITEMS.LASER: {
		Type.STRENGTH: "laser_strength",
		Type.RELOAD: "laser_fill_per_second",
		Type.SPEED: "laser_time_total",
		Type.SPREAD: "laser_spread",
	}, E.CHEST_ITEMS.WINGS: {
		Type.STRENGTH: "flight_time",
		Type.RELOAD: "flight_wait_time",
		Type.SPEED: "flight_speed",
	}
}

const MAX_UPGRADES = "MAX_UPGRADES"
const MAX_VALUE = "MAX_VALUE"
const maxed_amounts_n_values: Dictionary = {
	E.CHEST_ITEMS.ICICLE: {
		Type.SPREAD: {
			MAX_UPGRADES: 10,
			MAX_VALUE: 0,
		}
	}
}
func has_max(item: E.CHEST_ITEMS, upgrade: Type):
	return maxed_amounts_n_values.has(item) and maxed_amounts_n_values[item].has(upgrade)
func get_max_amount(item: E.CHEST_ITEMS, upgrade: Type) -> int:
	return maxed_amounts_n_values[item][upgrade][MAX_UPGRADES] if has_max(item, upgrade) else 999
func get_max_value(item: E.CHEST_ITEMS, upgrade: Type) -> int:
	return maxed_amounts_n_values[item][upgrade][MAX_VALUE] if has_max(item, upgrade) else 999

const upgrade_name_map: Dictionary = {
	Type.STRENGTH: STRENGTH,
	Type.RELOAD: RELOAD,
	Type.SPEED: SPEED,
	Type.SIZE: SIZE,
	Type.SPREAD: SPREAD,
	Type.BOUNCES: BOUNCES
}
func get_upgrade_name(upgrade: Type) -> String:
	return upgrade_name_map.get(upgrade, "Unbekannt :(")

const astronomical_costs: Dictionary = {
	E.COLLECT.COIN: 99999,
	E.COLLECT.SNOWFLAKE: 999,
	E.COLLECT.ICE_SHARD: 9999,
	E.COLLECT.FIRE_SHARD: 9999,
}
const upgrade_costs_map: Dictionary = {
	E.CHEST_ITEMS.SNOWBALL: {
		Type.STRENGTH: [E.COLLECT.SNOWFLAKE],
		Type.SIZE: [E.COLLECT.COIN, E.COLLECT.SNOWFLAKE],
		Type.RELOAD: [E.COLLECT.COIN, E.COLLECT.ICE_SHARD],
		Type.SPEED: [E.COLLECT.COIN],
		Type.BOUNCES: [E.COLLECT.SNOWFLAKE]
	}, E.CHEST_ITEMS.ICICLE: {
		Type.STRENGTH: [E.COLLECT.ICE_SHARD],
		Type.RELOAD: [E.COLLECT.COIN, E.COLLECT.ICE_SHARD],
		Type.SPEED: [E.COLLECT.COIN],
		Type.SPREAD: [E.COLLECT.SNOWFLAKE]
	}, E.CHEST_ITEMS.LASER: {
		Type.STRENGTH: [E.COLLECT.ICE_SHARD, E.COLLECT.FIRE_SHARD],
		Type.RELOAD: [E.COLLECT.COIN, E.COLLECT.SNOWFLAKE],
		Type.SPEED: [E.COLLECT.COIN, E.COLLECT.ICE_SHARD],
		Type.SPREAD: [E.COLLECT.SNOWFLAKE]
	}, E.CHEST_ITEMS.WINGS: {
		Type.STRENGTH: [E.COLLECT.SNOWFLAKE],
		Type.RELOAD: [E.COLLECT.COIN],
		Type.SPEED: [E.COLLECT.COIN]
	}
}
func upgrade_cost_types(item: E.CHEST_ITEMS, upgrade: Type) -> Array:
	return upgrade_costs_map[item][upgrade]
func upgrade_cost(item: E.CHEST_ITEMS, upgrade: Type, amount = Globals.upgrades[item][get_upgrade_name(upgrade)]) -> Dictionary:
	var costs_types = upgrade_cost_types(item, upgrade)
	var coins_plus = E.COLLECT.COIN in costs_types and costs_types.size() > 1
	var costs = {}
	if !costs_types or costs_types.is_empty(): costs = astronomical_costs
	for cost_type in costs_types:
		var cost = -1
		var base_cost = -1
		match cost_type:
			E.COLLECT.SNOWFLAKE:
				# doesn't jump from 2 to 4, result:     1, 2, 3, 5, 8, 12, 17, 23...
				# with coins and other cost, once more: 1, 1, 2, 3, 4, 6,  9,  13
				cost = upgrades_cost_step(amount, coins_plus, 1, 1, [1, 3, 4]) # 1 supresses first increase
			E.COLLECT.COIN:
				# doesn't jump from 15 to 25, result:   10, 15, 20, 30, 45, 65, 90, 120...
				# with coins and other cost, once more: 5,  10, 15, 20, 25, 35, 50, 70, 95...
				cost = 10 if !coins_plus else 5
				cost = upgrades_cost_step(amount, coins_plus, cost, 5, [3, 4])
			E.COLLECT.ICE_SHARD, E.COLLECT.FIRE_SHARD:
				 # doesn't jump from 4 to 8, result:     2, 4, 6, 10, 16, 24, 34, 46...
				 # with coins and other cost, once more: 2, 4, 6, 8,  10, 14, 20, 28
				cost = upgrades_cost_step(amount, coins_plus, 2, 2, [3, 4])
			_:
				print("Unknown upgrade type: ", cost_type)
				costs = astronomical_costs
		if cost != -1:
			costs[cost_type] = cost
	#if item == E.CHEST_ITEMS.WINGS:
		#print("Wings cost: ", costs, " upgrade: ", upgrade)
	#else:
		#print("Other cost: ", costs, " upgrade: ", upgrade)
	return costs

func upgrades_cost_step(upgrade_amount: int, coins_plus: bool, base_cost: int, upgrade_step: int, skipping_increase: Array[int]) -> int:
	var cost: int = base_cost
	for i in range(upgrade_amount):
		if i >= 2 and !skipping_increase.has(1): cost -= base_cost # always skip -> too much increase for the start
		if coins_plus:
			for skip in skipping_increase:
				if i >= skip: cost -= base_cost
		cost += i * upgrade_step
	return cost

func fetch_upgrade_amount(item: E.CHEST_ITEMS, upgrade: Type):
	return Globals.upgrades[item][get_upgrade_name(upgrade)]-1

func upgrade_effect(item: E.CHEST_ITEMS, upgrade: Type, amount: int):
	if amount >= get_max_amount(item, upgrade): return get_max_value(item, upgrade)
	
	if item == E.CHEST_ITEMS.SNOWBALL:
		if upgrade == Type.SIZE:
			return upgrade_step(amount, init_size_snowball, [2, 4, 8, 12], [0.2, 0.1, 0.075, 0.05, 0.025])
		elif upgrade == Type.STRENGTH:
			return 15 + amount * 5   # result: 15, 20, 25, 30, 35, 40, 45, 50...
		elif upgrade == Type.RELOAD:
			return upgrade_step(amount, init_reload_snowball, [4, 8, 12], [-0.05, -0.025, -0.02, -0.01])
		elif upgrade == Type.SPEED:
			return upgrade_step(amount, init_speed_snowball, [4, 8, 12], [75, 50, 35, 25])
		elif upgrade == Type.BOUNCES:
			return 1 + amount
	
	elif item == E.CHEST_ITEMS.ICICLE:
		if upgrade == Type.STRENGTH:
			return 10 + amount * 4   # result: 10, 14, 18, 22, 26, 30, 34, 38...
		elif upgrade == Type.RELOAD:
			return upgrade_step(amount, init_reload_icicle, [4, 8, 12], [-0.04, -0.02, -0.015, -0.01])
		elif upgrade == Type.SPEED:
			return upgrade_step(amount, init_speed_icicle, [4, 8, 12], [150, 100, 75, 50])
		elif upgrade == Type.SPREAD:
			return upgrade_step(amount, init_degrees_icicle, [3, 7, 9], [-1.0, -0.5, -0.25, -0.1])
	
	elif item == E.CHEST_ITEMS.LASER:
		if upgrade == Type.STRENGTH:
			return upgrade_step(amount, init_laser_strength, [4, 8, 12], [0.75, 0.5, 0.3, 0.2])
		elif upgrade == Type.SPREAD:
			return upgrade_step(amount, init_laser_spread, [4, 8, 12], [7, 5, 3, 2])
		elif upgrade == Type.RELOAD:
			return upgrade_step(amount, init_laser_fill_per_second, [4, 8, 12], [0.015, 0.01, 0.0075, 0.005])
		elif upgrade == Type.SPEED:
			return upgrade_step(amount, init_laser_time_total, [4, 8, 12], [0.5, 0.3, 0.2, 0.1])
	
	elif item == E.CHEST_ITEMS.WINGS:
		if upgrade == Type.STRENGTH:
			return upgrade_step(amount, init_flight_time, [4, 8, 12], [2.0, 1.0, 0.5, 0.25])
		if upgrade == Type.RELOAD:
			return max(1.0, upgrade_step(amount, init_flight_wait_time, [3, 6, 9], [-5.0, -2.5, -1.5, -1.0]))
		if upgrade == Type.SPEED:
			return upgrade_step(amount, init_flight_speed, [4, 8, 12], [75.0, 50.0, 25.0, 10.0])

func upgrade_effect_suffix(item: E.CHEST_ITEMS, upgrade: Type) -> String:
	if item == E.CHEST_ITEMS.ICICLE and upgrade == Type.SPREAD: return "°"
	if item == E.CHEST_ITEMS.WINGS and upgrade in [Type.STRENGTH, Type.RELOAD]\
	or item == E.CHEST_ITEMS.LASER and upgrade == Type.SPEED: return "s"
	if upgrade == Type.RELOAD: return "%"
	return ""

func upgrade_effect_text(item: E.CHEST_ITEMS, upgrade: Type, with_upgraded = false, effect_suffix = null, variable_name = null):
	effect_suffix = Opt.of(effect_suffix).or_else_get(func(): return upgrade_effect_suffix(item, upgrade))
	var amount = fetch_upgrade_amount(item, upgrade)
	if effect_suffix == "%":
		var init_value = Upgrades.get("init_" + variable_name)
		return [upgrade_effect_ratio(item, upgrade, init_value, amount), upgrade_effect_ratio(item, upgrade, init_value, amount + 1)]
	else:
		return [str(Upgrades.upgrade_effect(item, upgrade, amount), effect_suffix), str(Upgrades.upgrade_effect(item, upgrade, amount + 1), effect_suffix)]
func upgrade_effect_ratio(item: E.CHEST_ITEMS, upgrade: Type, init_value, amount):
	var effect = Upgrades.upgrade_effect(item, upgrade, amount)
	var value = (effect / init_value) if effect >= init_value else (init_value / effect)
	return format_float(value * 100, 2) + "%"
func format_float(value: float, digits: int) -> String:
	var result = String.num(value, digits)
	return result.rstrip("0").rstrip(".") if result.contains(".") else result


func upgrade_step(upgrades: int, init_value: float, thresholds: Array[int], factors: Array[float]) -> float:
	var result = init_value
	for i in range(thresholds.size()):
		var threshold = thresholds[i]
		var difference = thresholds[i] if i==0 else thresholds[i]-thresholds[i-1]
		if upgrades > threshold:
			result += difference * factors[i]
		else:
			result += (difference - (threshold - upgrades)) * factors[i]
			break
	var max_threshold = thresholds[thresholds.size()-1]
	if upgrades > max_threshold and factors.size() > thresholds.size():
		result += (upgrades - max_threshold) * factors[factors.size()-1]
	return result

#func simulation(till: int):
	#for i in range(till):
		#print(i, " fill: ", upgrade_step(i, init_laser_fill_per_second, [4, 8, 12], [0.05, 0.03, 0.02, 0.01]))
	#for i in range(till):
		#print(i, " time: ", upgrade_step(i, init_laser_time_total, [4, 8, 12], [0.5, 0.3, 0.2, 0.1]))
