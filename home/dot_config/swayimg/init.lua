swayimg.viewer.set_image_background(0xff000000)
swayimg.decoration = false
swayimg.imagelist.adjacent = true
swayimg.text.visible = false

-- swayimg 5.7 replaced the Scroll* mouse buttons with on_scroll, which takes
-- over all scrolling: horizontal switches image, the rest matches the defaults.
swayimg.viewer.on_scroll(function(kmods, horizontal, vertical)
	if horizontal and horizontal ~= 0 then
		swayimg.viewer.open(horizontal > 0 and "prev" or "next")
	elseif kmods == "Ctrl" then
		local mouse = swayimg.get_mouse_pos()
		local scale = swayimg.viewer.scale
		swayimg.viewer.set_abs_scale(scale - scale * vertical / 10.0, mouse.x, mouse.y)
	elseif vertical then
		local pos = swayimg.viewer.get_position()
		swayimg.viewer.set_abs_position(pos.x, pos.y + math.floor(vertical * 50))
	end
end)

-- Close with q in every mode.
for _, mode in ipairs({ swayimg.viewer, swayimg.gallery, swayimg.slideshow }) do
	mode.on_key("q", function()
		swayimg.exit(0)
	end)
end
