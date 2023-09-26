extends CanvasLayer

var CurTween : Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/InteractText.visible = false
	$VBoxContainer/InteractBar.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func NewInteractable(InteractName):
	$VBoxContainer/InteractText.text = InteractName
	$VBoxContainer/InteractText.visible = true

func LoseInteractable():
	$VBoxContainer/InteractText.visible = false
	$VBoxContainer/InteractBar.visible = false

func StartInteract(InteractTime):
	$VBoxContainer/InteractBar.value = 0
	$VBoxContainer/InteractBar.visible = true
	CurTween = create_tween()
	CurTween.tween_property($VBoxContainer/InteractBar, "value", 100, InteractTime).set_trans(Tween.TRANS_SINE)
	CurTween.tween_callback(StopInteract)
func StopInteract():
	$VBoxContainer/InteractBar.visible = false
	if CurTween != null:
		CurTween.stop()

func SetHealth(Health,MaxHealth):
	$HealthBar.value = Health
	$HealthBar.max_value = MaxHealth

func ActionDoneTo(ActionName,InteractTime):
	$VBoxContainer/InteractText.text = ActionName
	$VBoxContainer/InteractText.visible = true
	$VBoxContainer/InteractBar.value = 0
	$VBoxContainer/InteractBar.visible = true
	CurTween = create_tween()
	CurTween.tween_property($VBoxContainer/InteractBar, "value", 100, InteractTime).set_trans(Tween.TRANS_SINE)
	CurTween.tween_callback(ActionStopped)
func ActionStopped():
	$VBoxContainer/InteractText.visible = false
	$VBoxContainer/InteractBar.visible = false
	if CurTween != null:
		CurTween.stop()

func GetSlotItem(SlotNum):
	var CurSlot = $HBoxContainer.get_child(SlotNum)
	return CurSlot.GetItem()
