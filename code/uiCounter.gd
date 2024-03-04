extends AnimatedSprite2D

@export var maxValue: int;
@export var animateSecondary: bool;

var tens: AnimatedSprite2D;
var ones: AnimatedSprite2D;
var value: int;

# Called when the node enters the scene tree for the first time.
func _ready():
	if (maxValue < 10):
		tens = null;
	else:
		tens = get_node("main/tens");
	ones = get_node("main/ones");
	
	value = maxValue;
	setValue(value);

func setValue(v: int):
	v = max(0, min(maxValue, v));
	value = v;
	
	if (maxValue > 9):
		tens.frame = v / 10;
	ones.frame = v % 10;
	
	if (animateSecondary):
		self.frame = value / 2;
	else:
		self.frame = value;
