swayimg.viewer.set_image_background(0xff000000)
swayimg.decoration = false
swayimg.imagelist.adjacent = true
swayimg.text.visible = false

swayimg.viewer.on_mouse("ScrollLeft", function()
	swayimg.viewer.open("prev")
end)

swayimg.viewer.on_mouse("ScrollRight", function()
	swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("q", function()
	swayimg.exit(0)
end)
