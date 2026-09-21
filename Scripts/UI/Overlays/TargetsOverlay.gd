class_name TargetsOverlay extends Overlay

static var current = null

func _ready() -> void:
	current = self
	# has to be called, to add that as the single overlay instance
	super._ready()

func remove() -> void:
	if current == self: current = null
	super.remove()
