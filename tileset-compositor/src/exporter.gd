extends SubViewport

@onready var export_camera:Camera2D = $ExportCamera

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("RenderAsPng"):
		render_png()
		
func render_png() -> void:
	export_camera.enabled = true
	
	await RenderingServer.frame_post_draw
	
	var image: Image = get_texture().get_image()
	var result := image.save_png("user://map.png")
	if result == OK:
		print("Exported: ", ProjectSettings.globalize_path("user://map.png"))
	else:
		print("PNG export failed: ", result)
