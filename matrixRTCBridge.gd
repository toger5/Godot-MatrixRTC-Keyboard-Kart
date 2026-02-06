extends Node

var _data_callback_ref = JavaScriptBridge.create_callback(_data_callback)
var _members_callback_ref = JavaScriptBridge.create_callback(_members_callback)
var _local_member_callback_ref = JavaScriptBridge.create_callback(_local_member_callback)
var _connected_callback_ref = JavaScriptBridge.create_callback(_connected_callback)
var console
var sdk

signal member_change(members)
signal local_member_change(member)
signal car_position_change(member_id: String, car_pos: int)
signal connected_changed(connected: bool)

func update_own_car_position(car_pos: int):
	sdk.sendData(car_pos)

func send_text_message(message: String):
	sdk.sendRoomMessage(message)

func _ready():
	console = JavaScriptBridge.get_interface("console")
	console.log("GODOT ready")
	console.warn("danger")

	sdk = JavaScriptBridge.get_interface("window").matrixRTCSdk

func start_emitters():
	sdk.dataObs.subscribe(_data_callback_ref)
	sdk.membersObs.subscribe(_members_callback_ref)
	sdk.localMemberObs.subscribe(_local_member_callback_ref)
	sdk.connectedObs.subscribe(_connected_callback_ref)


func _data_callback(args:Array):
	var data_rtc_obj = args[0]
	var car_pos = data_rtc_obj.data;
	console.log("GODOT _data_callback", data_rtc_obj)
	var id = data_rtc_obj.rtcBackendIdentity
	emit_signal("car_position_change", id, car_pos)
	console.log("GODOT on data:", JSON.stringify(data_rtc_obj))

func _members_callback(args):
	var members_rtc = args[0]
	var members = []
	for i in range(members_rtc.length):
		var member_rtc = members_rtc[i]
		console.log("GODOT _members_callback index: ",i,"member: ", member_rtc, "userId: ",member_rtc.membership.userId, "memberId: ", member_rtc.membership.memberId)
		var m = {"id":member_rtc.membership.memberId,"name": member_rtc.membership.userId}

		members.push_back(m)
	console.log("GODOT _members_callback final list: ", members)
	emit_signal("member_change", members)

func _local_member_callback(args):
	var local_member_rtc = args[0]
	if TYPE_NIL ==typeof(local_member_rtc):
		# This can be Nil -> we do not want gd script to crash on local_member_rtc.membership
		return

	console.log("GODOT _local_member_callback emit: ", "id",local_member_rtc.membership.memberId, "name", local_member_rtc.membership.userId)
	emit_signal("local_member_change", {"id":local_member_rtc.membership.memberId, "name": local_member_rtc.membership.userId})

func _connected_callback(args):
	print("GODOT Update connectedObs", args[0])
	var connected_status: bool = args[0]
	var status_text : String
	if connected_status:
		status_text = "Connected"
	else:
		status_text = "Not Connected"
	%Status.text = "Status: " + status_text
	if connected_status:
		%Leave.visible = true
		%Join.visible = false
	else:
		%Leave.visible = false
		%Join.visible = true
	emit_signal("connected_changed", args[0])


func _on_leave_pressed() -> void:
	%Status.text = "Status: Leaving..."
	%Leave.visible = false
	%Join.visible = true
	sdk.leave()

func _on_join_pressed() -> void:
	%Status.text = "Status: Joining..."
	%Leave.visible = true
	%Join.visible = false
	sdk.join()
