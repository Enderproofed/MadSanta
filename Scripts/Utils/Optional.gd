class_name Opt extends Node # Java Optional imitation

var value = null

func is_empty() -> bool:
	return value == null

func or_else(fallback_value): # -> type of the value
	return fallback_value if is_empty() else value
func or_else_get(supplier: Callable): # -> type of the suppliers return value
	return supplier.call() if is_empty() else value

func if_present(consumer: Callable) -> void:
	consumer.call(value)

func map(function: Callable) -> Opt:
	value = function.call(value)
	return self

static func empty() -> Opt:
	return Opt.new()

static func of(value) -> Opt:
	var new = Opt.new()
	new.value = value
	return new
