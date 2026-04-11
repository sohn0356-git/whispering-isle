extends Node

const ExplorerAppearanceGeneratorScript = preload("res://scripts/ExplorerAppearanceGenerator.gd")

signal explorers_updated(explorers: Array)

@export var expedition_duration_min: float = 5.0
@export var expedition_duration_max: float = 9.0

var explorers: Array[ExplorerData] = ExplorerData.create_default_explorers()


func _ready() -> void:
	randomize()
	var used_signatures := {}
	for index in explorers.size():
		explorers[index].village_slot = index
		if explorers[index].appearance_data == null:
			explorers[index].apply_appearance(ExplorerAppearanceGeneratorScript.generate_for(explorers[index], used_signatures))
	emit_signal("explorers_updated", explorers)


func _process(delta: float) -> void:
	for explorer in explorers:
		_update_explorer(explorer, delta)

	emit_signal("explorers_updated", explorers)


func get_explorers() -> Array[ExplorerData]:
	return explorers


func _update_explorer(explorer: ExplorerData, delta: float) -> void:
	explorer.state_timer = maxf(explorer.state_timer - delta, 0.0)

	match explorer.state:
		ExplorerData.State.IDLE:
			_recover_in_village(explorer, delta, 1.2, 3.0)
			if explorer.state_timer <= 0.0:
				_choose_next_village_action(explorer)
		ExplorerData.State.PREPARE:
			_recover_in_village(explorer, delta, 0.4, 1.2)
			if explorer.state_timer <= 0.0:
				_change_state(explorer, ExplorerData.State.GO_TO_LABYRINTH, randf_range(1.5, 2.8), "Heading out to the labyrinth.")
		ExplorerData.State.GO_TO_LABYRINTH:
			if explorer.state_timer <= 0.0:
				_change_state(explorer, ExplorerData.State.EXPLORING, randf_range(expedition_duration_min, expedition_duration_max), "Exploring the labyrinth...")
		ExplorerData.State.EXPLORING:
			if explorer.state_timer <= 0.0:
				_resolve_expedition(explorer)
				_change_state(explorer, ExplorerData.State.RETURNING, randf_range(1.8, 3.0), explorer.last_result)
		ExplorerData.State.RETURNING:
			if explorer.state_timer <= 0.0:
				_choose_post_return_action(explorer)
		ExplorerData.State.RESTING:
			_recover_in_village(explorer, delta, 3.4, 7.0)
			if explorer.state_timer <= 0.0 or (explorer.hp >= explorer.max_hp * 0.95 and explorer.stamina >= explorer.max_stamina * 0.95):
				_change_state(explorer, ExplorerData.State.IDLE, randf_range(2.0, 4.0), "Feeling better after rest.")
		ExplorerData.State.SHOPPING:
			_recover_in_village(explorer, delta, 1.8, 2.0)
			if explorer.state_timer <= 0.0:
				_change_state(explorer, ExplorerData.State.IDLE, randf_range(2.0, 4.0), "Back from the market.")


func _choose_next_village_action(explorer: ExplorerData) -> void:
	var hp_ratio := explorer.hp / explorer.max_hp
	var stamina_ratio := explorer.stamina / explorer.max_stamina

	var leave_score := stamina_ratio * 55.0 + explorer.courage * 34.0 + explorer.greed * 14.0 - explorer.caution * 22.0 + randf_range(-8.0, 8.0)
	var rest_score := (1.0 - hp_ratio) * 65.0 + (1.0 - stamina_ratio) * 50.0 + explorer.caution * 28.0 - explorer.courage * 8.0 + randf_range(-6.0, 6.0)
	var shop_score := explorer.greed * 18.0 + explorer.caution * 8.0 + clampf(float(explorer.gold) - 10.0, 0.0, 25.0) + randf_range(-5.0, 5.0)

	if hp_ratio < 0.45:
		rest_score += 30.0
		leave_score -= 25.0

	if stamina_ratio < 0.4:
		rest_score += 20.0
		leave_score -= 20.0

	if explorer.gold < 10:
		shop_score -= 18.0

	if leave_score >= rest_score and leave_score >= shop_score:
		_change_state(explorer, ExplorerData.State.PREPARE, randf_range(2.0, 4.0), "%s checks gear before departure." % explorer.explorer_name)
	elif rest_score >= shop_score:
		_change_state(explorer, ExplorerData.State.RESTING, randf_range(5.0, 8.0), "%s heads for the inn to recover." % explorer.explorer_name)
	else:
		_apply_shopping(explorer)
		_change_state(explorer, ExplorerData.State.SHOPPING, randf_range(3.0, 5.5), "%s is hunting for supplies at the shop." % explorer.explorer_name)


func _choose_post_return_action(explorer: ExplorerData) -> void:
	var hp_ratio := explorer.hp / explorer.max_hp
	var stamina_ratio := explorer.stamina / explorer.max_stamina
	var wants_shop := explorer.gold >= 15 and randf() < (0.2 + explorer.greed * 0.45)

	if hp_ratio < 0.55 or stamina_ratio < 0.4 or randf() < explorer.caution * 0.4:
		_change_state(explorer, ExplorerData.State.RESTING, randf_range(5.0, 8.0), "%s returns weary and goes to the inn." % explorer.explorer_name)
	elif wants_shop:
		_apply_shopping(explorer)
		_change_state(explorer, ExplorerData.State.SHOPPING, randf_range(3.0, 5.0), "%s spends expedition earnings at the shop." % explorer.explorer_name)
	else:
		_change_state(explorer, ExplorerData.State.IDLE, randf_range(2.0, 4.0), "%s is back in the plaza telling stories." % explorer.explorer_name)


func _apply_shopping(explorer: ExplorerData) -> void:
	var spend := mini(explorer.gold, randi_range(4, 10))
	explorer.gold -= spend
	explorer.hp = minf(explorer.max_hp, explorer.hp + 2.0 + spend * 0.35)
	explorer.stamina = minf(explorer.max_stamina, explorer.stamina + 3.0 + spend * 0.7)
	explorer.last_result = "Spent %d gold on food and supplies." % spend


func _resolve_expedition(explorer: ExplorerData) -> void:
	var success_roll := randf() + explorer.courage * 0.35 + explorer.greed * 0.12 + float(explorer.level) * 0.04
	var safety_roll := randf() + explorer.caution * 0.3
	var gold_delta := 0
	var hp_loss := 0.0
	var stamina_loss := 0.0
	var progress_gain := randf_range(8.0, 18.0) + explorer.courage * 6.0

	if success_roll > 1.28:
		gold_delta = randi_range(15, 25) + int(round(explorer.greed * 4.0))
		hp_loss = randf_range(1.0, 4.0)
		stamina_loss = randf_range(10.0, 16.0)
		explorer.last_result = "%s returned with rare spoils worth %d gold." % [explorer.explorer_name, gold_delta]
	elif success_roll > 0.95:
		gold_delta = randi_range(8, 16)
		hp_loss = randf_range(0.0, 3.0)
		stamina_loss = randf_range(9.0, 15.0)
		explorer.last_result = "%s came back from a successful hunt with %d gold." % [explorer.explorer_name, gold_delta]
	elif safety_roll < 0.38:
		gold_delta = randi_range(1, 6)
		hp_loss = randf_range(7.0, 12.0)
		stamina_loss = randf_range(14.0, 22.0)
		explorer.last_result = "%s limped home injured with only %d gold." % [explorer.explorer_name, gold_delta]
	elif explorer.stamina < explorer.max_stamina * 0.45 or randf() < 0.25 + explorer.caution * 0.2:
		gold_delta = randi_range(2, 8)
		hp_loss = randf_range(1.0, 4.0)
		stamina_loss = randf_range(16.0, 24.0)
		explorer.last_result = "%s dragged back exhausted with %d gold." % [explorer.explorer_name, gold_delta]
	else:
		gold_delta = randi_range(0, 4)
		hp_loss = randf_range(0.0, 2.0)
		stamina_loss = randf_range(8.0, 14.0)
		explorer.last_result = "%s found little and returned empty-handed." % explorer.explorer_name

	explorer.gold += gold_delta
	explorer.hp = clampf(explorer.hp - hp_loss, 1.0, explorer.max_hp)
	explorer.stamina = clampf(explorer.stamina - stamina_loss, 0.0, explorer.max_stamina)
	explorer.level_progress += progress_gain

	if explorer.level_progress >= 100.0:
		explorer.level += 1
		explorer.level_progress -= 100.0
		explorer.max_hp += 2.0
		explorer.max_stamina += 2.0
		explorer.hp = minf(explorer.max_hp, explorer.hp + 4.0)
		explorer.stamina = minf(explorer.max_stamina, explorer.stamina + 4.0)
		explorer.last_result += " Reached level %d." % explorer.level


func _recover_in_village(explorer: ExplorerData, delta: float, hp_rate: float, stamina_rate: float) -> void:
	explorer.hp = minf(explorer.max_hp, explorer.hp + hp_rate * delta)
	explorer.stamina = minf(explorer.max_stamina, explorer.stamina + stamina_rate * delta)


func _change_state(explorer: ExplorerData, new_state: int, duration: float, message: String) -> void:
	explorer.state = new_state
	explorer.state_timer = duration
	explorer.last_result = message
