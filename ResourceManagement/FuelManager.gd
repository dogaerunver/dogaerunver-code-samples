extends Node

signal fuel_changed(current: float, maximum: float)

const MAX_FUEL := 15.0
const DRAIN_PER_SECOND := 0.15
const REFILL_PER_SECOND := 15.0

var current: float = MAX_FUEL
var refill_pause_count: int = 0

func _process(delta: float) -> void:
	if refill_pause_count > 0:
		return
	if current > 0.0:
		current = max(current - DRAIN_PER_SECOND * delta, 0.0)
		fuel_changed.emit(current, MAX_FUEL)

func can_afford(cost: float = 1.0) -> bool:
	return current >= cost

func spend(cost: float = 1.0) -> bool:
	if not can_afford(cost):
		return false
	current -= cost
	fuel_changed.emit(current, MAX_FUEL)
	return true

func refill_tick(delta: float) -> void:
	if current < MAX_FUEL:
		current = min(current + REFILL_PER_SECOND * delta, MAX_FUEL)
		fuel_changed.emit(current, MAX_FUEL)
		
func pause_refill() -> void:
	refill_pause_count += 1

func resume_refill() -> void:
	refill_pause_count = max(refill_pause_count - 1, 0)
