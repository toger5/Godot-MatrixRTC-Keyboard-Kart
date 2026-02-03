extends Node
class MockConsole:
	func log(a1=null, a2=null, a3=null, a4=null, a5=null):
		print(a1,a2,a3,a4,a5)

class MockSdk:
	func sendData(d):
		print("Mock send data ",d)

var console = MockConsole.new()
var sdk = MockSdk.new()

signal local_member_change(member)
# skip any remote member emissions
signal member_change(members)
signal car_position_change(member_id: String, car_pos: int)

func update_own_car_position(car_pos: int):
	sdk.sendData(car_pos)
func send_text_message(msg):
	print(msg)

func _ready():
	console.log("GODOT MOCK ready")


func start_emitters():
	emit_signal("local_member_change", {"id":"mockId", "name": "mock@local.org"})
