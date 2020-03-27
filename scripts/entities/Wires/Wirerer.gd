tool
extends Node2D
class_name Wirerer

signal wire_switch(isOn)

var PIECE = preload("res://scenes/entities/ConcreteEntities/Dynamic/WirePiece.tscn")
var GENERATOR = preload("res://scenes/entities/ConcreteEntities/Dynamic/Destructible/Generator.tscn")
var SOCKET = preload("res://scenes/entities/ConcreteEntities/Static/Socket.tscn")

export (Array) var chainAmount = chainArray setget _setChainFunc,_getChainFunc
enum NodeTypes {generator, socket}
export (NodeTypes) var StartNodeType = 0 setget _setStartType,_getStartType
export (float) var StartNodeRotation setget _setStartNodeRotation,_getStartNodeRotation
export (float) var EndNodeRotation setget _setEndNodeRotation,_getEndNodeRotation


var chainArray: Array
var startNode
var endNode
var startNodeRotation = 0
var endNodeRotation = 0
var created = false


func Enable():
	if(Engine.is_editor_hint()):
		return
	
	if(created):
		emit_signal("wire_switch", true)
	for child in $Anchor.get_children():
		if(child.has_method("Enable")):
			child.Enable()


func Disable():
	if(Engine.is_editor_hint()):
		return
	
	if(created):
		emit_signal("wire_switch", false)
	for child in $Anchor.get_children():
		if(child.has_method("Disable")):
			child.Disable()


func _ready():
	var anchor = find_node("Anchor")
	
	if(!anchor):
		return
	
	for i in anchor.get_children():
		i.queue_free()
	_buildChain()
	Enable()
	created = true;


func _setStartNodeRotation(val):
	startNodeRotation = val
	
	if(Engine.is_editor_hint()):
		_removePieces(find_node("Anchor"))
		_buildChain()


func _getStartNodeRotation():
	return startNodeRotation


func _setStartType(val):
	startNode = val
	
	if(Engine.is_editor_hint()):
		_removePieces(find_node("Anchor"))
		_buildChain()


func _getStartType():
	return startNode


func _setEndNodeRotation(val):
	endNodeRotation = val
	
	if(Engine.is_editor_hint()):
		_removePieces(find_node("Anchor"))
		_buildChain()


func _getEndNodeRotation():
	return endNodeRotation


func _setChainFunc(val):
	var temp: Array = [];
	for item in val:
		if(!item is float && !item is int):
			temp.push_back(0.0)
		else:
			temp.push_back(item)
	chainArray = temp
	
	if(Engine.is_editor_hint()):
		_removePieces(find_node("Anchor"))
		_buildChain()


func _buildChain():
	var parent = find_node("Anchor")
	var start
	var end = SOCKET.instance()
	
	match(startNode):
		0:	
			start = GENERATOR.instance()
			start.connect("wire_switch", self, "_on_Generator_switch")
		1:	start = SOCKET.instance()
		_: 	start = SOCKET.instance()
	
	if (!parent):
		return
	
	var elements: Array = []
	var joints: Array = []
	
	parent.add_child(start)
	elements.append(start)
	
	var coords = start.find_node("Joint").get_position()
	joints.append(_addJoint(parent, start.get_position()))
	var cumulativeAngle = 0
	
	for angle in chainArray:
		cumulativeAngle += angle
		var elem = _addPiece(parent, PIECE.instance(), coords, cumulativeAngle)
		coords += elem.find_node("Joint").get_position().rotated(elem.get_rotation())
		var joint = _addJoint(parent, coords)
		
		joints.append(joint)
		elements.append(elem)
	
	_addPiece(parent, end, coords, endNodeRotation)
	elements.append(end)
	
	var i = 1
	for joint in joints:
		if i == 3: break;
		var el1 = elements[i-1]
		var el2 = elements[i]
		_joinWires(joint, el1, el2)
		print_debug("---------")
		print_debug(joint.get_name())
		print_debug(el1.find_node("Joint").get_global_position())
		print_debug(joint.position)
		print_debug(el2.position)
		print_debug("---------")
		i += 1


func _getChainFunc():
	return chainArray


func _removePieces(start):
	if(start == null):
		return
	
	var item = start
	var children = item.get_children()
	for child in children:
		child.queue_free()


func _addPiece(parent, piece, coord: Vector2 = Vector2(0, 0), rotation = 0):
	if(parent == null):
		return

	piece.set_rotation(deg2rad(rotation))
	parent.add_child(piece)
	piece.set_position(coord)
	
	return piece
	
	
func _addJoint(parent, coord):
	var joint = PinJoint2D.new()
	joint.set_position(coord)
	parent.add_child(joint)
	return joint


func _joinWires(joint: PinJoint2D, elem1: Node2D, elem2: Node2D):
	if(Engine.is_editor_hint()):
		return
	
	joint.node_a = joint.get_path_to(elem1)
	joint.node_b = joint.get_path_to(elem2)


func _on_Generator_switch(enabled):
	emit_signal("wire_switch", enabled)
