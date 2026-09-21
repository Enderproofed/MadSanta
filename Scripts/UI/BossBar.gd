class_name BossBar extends Control

var bar_count: int = 1
var total_health: float = 1000.0
var health: float = total_health

func set_boss_name(boss_name):
	$Label.text = boss_name

func set_health(new_health, new_total_health = null):
	if new_total_health != null: total_health = new_total_health
	health = new_health
	set_values()

func set_bar_count(new_bar_count: int):
	bar_count = new_bar_count
	$Healthbar1.visible = bar_count >= 1
	$Healthbar2.visible = bar_count >= 2
	$Healthbar3.visible = bar_count >= 3
	custom_minimum_size.y = 52 + 18 * (bar_count - 1)
	set_values()

func set_values():
	var bar_part = total_health / float(bar_count)
	var total_ratio = health / total_health
	for i in range(1, bar_count + 1):
		var healthbar: TextureProgressBar = get_node("Healthbar" + str(i))
		var ratio = 1.0 if health >= bar_part * i else clamp((health - bar_part * (i-1)) / float(bar_part), 0.0, 1.0)
		healthbar.value = healthbar.max_value * ratio
		healthbar.tint_progress = HealthBar.calculate_color(ratio)
