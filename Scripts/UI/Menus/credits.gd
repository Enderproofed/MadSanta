extends Control

@export var credit_text: RichTextLabel
@export var textures_text: RichTextLabel
@export var texts_container: VBoxContainer

const COLOR_NORMAL = Color(0, 0.7, 1.0)
const COLOR_HOVERED = Color(0.1, 0.8, 1.2)

enum URL {
	MY_PROFILE,
	ADMURIN,
	EDUARDO,
	HEE_HEE,
}
@onready var URL_CONTENT_DIC: Dictionary = {
	URL.MY_PROFILE: ["Mirko Riek", "https://enderproofed.itch.io/", credit_text],
	# Texture Credits
	URL.ADMURIN: ["Admurin", "https://admurin.itch.io/", textures_text],
	URL.EDUARDO: ["Eduardo Scarpato", "https://eduardscarpato.itch.io/", textures_text],
	URL.HEE_HEE: ["HEE HEE", "https://www.youtube.com/watch?v=z93i3GrmtAY", textures_text],
}
func url(url_enum: URL) -> String:
	var url_content = URL_CONTENT_DIC[url_enum]
	return build_url(url_content[0], url_content[1])
func find_content_by_url(url_text: String) -> Array:
	for key in URL_CONTENT_DIC.keys():
		if URL_CONTENT_DIC[key][1] == url_text: return URL_CONTENT_DIC[key]
	return []
func find_content_by_container(container: RichTextLabel):
	var content_in_container = []
	for key in URL_CONTENT_DIC.keys():
		if URL_CONTENT_DIC[key][2] == container: content_in_container.append(key)
	return content_in_container

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for text: RichTextLabel in texts_container.get_children():
		text.connect("meta_hover_started", _on_meta_hover_started)
		text.connect("meta_hover_ended", _on_meta_hover_ended)
		text.connect("meta_clicked", _on_meta_clicked)
	credit_text.text = str(tr("CREDITS_TEXT"), " ", url(URL.MY_PROFILE), ".")
	
	var textures_list = ""
	for texture_credit_url: URL in find_content_by_container(textures_text):
		textures_list += "\n" + url(texture_credit_url)
	textures_text.text = centered(str(tr("TEXTURES"), ":", textures_list))

func build_url(visible_text: String, url_text: String, hovering: bool = false) -> String:
	return str("[color=", COLOR_NORMAL.to_html(false) if !hovering else COLOR_HOVERED.to_html(false), "][url=", url_text, "]", visible_text, "[/url][/color]")

func centered(text):
	return str("[center]", text, "[/center]")

func _on_meta_hover_started(meta):
	var url_content = find_content_by_url(meta)
	url_content[2].text = url_content[2].text.replace(build_url(url_content[0], url_content[1]), build_url(url_content[0], url_content[1], true))

func _on_meta_hover_ended(meta):
	var url_content = find_content_by_url(meta)
	url_content[2].text = url_content[2].text.replace(build_url(url_content[0], url_content[1], true), build_url(url_content[0], url_content[1], false))

func _on_meta_clicked(meta):
	OS.shell_open(meta)
