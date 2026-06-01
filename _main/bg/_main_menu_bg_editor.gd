@tool
extends Node3D

@export var mesh_instance:Mesh = null
@export var mesh_material:Material = null
@export var size_x:int = 0
@export var size_y:int = 0
@export var gap:float = 0

@export_tool_button("Spawn") var spawn = _spawn
@export_tool_button("Clear") var clear = _clear
@export var counts:int = 0

func _spawn()->void:
	_clear()
	
	if mesh_instance == null:
		print("Error: No mesh assigned!")
		return
	
	for x in range(size_x):
		for y in range(size_y):
			var pos_x = x * gap - (size_x - 1) * gap / 2.0
			var pos_z = y * gap - (size_y - 1) * gap / 2.0
			var _pos = Vector3(pos_x, 0, pos_z)
			
			var mesh_instance_3d = MeshInstance3D.new()
			mesh_instance_3d.mesh = mesh_instance
			mesh_instance_3d.set_surface_override_material(0,mesh_material.duplicate())
			mesh_instance_3d.cast_shadow = false
			
			mesh_instance_3d.position = _pos
			add_child(mesh_instance_3d)
			mesh_instance_3d.owner = get_tree().edited_scene_root
			counts += 1

func _clear()->void:
	counts = 0
	for child in get_children():
		if child is MeshInstance3D:
			child.queue_free()
