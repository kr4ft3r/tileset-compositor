extends SubViewport

@export_global_dir var target_directory:String = "user://"
@export var image_file_name:String = "tileset.png"

@onready var export_camera:Camera2D = $ExportCamera

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("RenderAsPng"):
		render_png()
		
func render_png() -> void:
	export_camera.enabled = true
	
	await RenderingServer.frame_post_draw
	
	var image: Image = get_texture().get_image()
	var result := image.save_png(target_directory.path_join(image_file_name))
	if result == OK:
		print("Exported: ", ProjectSettings.globalize_path(target_directory.path_join(image_file_name)))
	else:
		print("PNG export failed: ", result)
