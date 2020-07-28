extends Node

func loadDialogue(path : String) -> void:
	var file = File.new()
	if (file.file_exists(path)):
		file.open(path, File.READ)
		var dialogue = parse_json(file.get_as_text())
		var root = get_tree().get_nodes_in_group("dialogBox")
		file.close()
		root[0].start(dialogue)
