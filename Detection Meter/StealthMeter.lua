local hudsuspicion_init_original = HUDSuspicion.init
local hudsuspicions_animate_eye_original = HUDSuspicion.animate_eye
local hudsuspicion_hide_original = HUDSuspicion.hide

function HUDSuspicion:init(hud, sound_source, ...)
	hudsuspicion_init_original(self, hud, sound_source, ...)
	self._suspicion_text_panel = self._suspicion_panel:panel({
		name = "suspicion_text_panel",
		visible = true,
		x = 0,
		y = 0,
		h = self._suspicion_panel:h(),
		w = self._suspicion_panel:w(),
		layer = 1
	})
	self._suspicion_text = self._suspicion_text_panel:text({
		name = "suspicion_text",
		visible = true,
		text = "",
		valign = "center",
		align = "center",
		layer = 2,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
		font_size = 18,
		h = 64
	})
	self._suspicion_text:set_y((math.round(self._suspicion_text_panel:h() / 4)))
	for i = 1, 4 do
		self["_suspicion_bgtext" .. i] = self._suspicion_text_panel:text({
			name = "suspicion_bgtext" .. i,
			visible = true,
			text = "",
			valign = "center",
			align = "center",
			layer = 1,
			color = Color.black,
			font = tweak_data.menu.pd2_large_font,
			font_size = 18,
			h = 64
		})
	end
	self._suspicion_bgtext1:set_x(self._suspicion_bgtext1:x() - 1)
	self._suspicion_bgtext1:set_y((math.round(self._suspicion_text_panel:h() / 4)) - 1)
	self._suspicion_bgtext2:set_x(self._suspicion_bgtext2:x() + 1)
	self._suspicion_bgtext2:set_y((math.round(self._suspicion_text_panel:h() / 4)) - 1)
	self._suspicion_bgtext3:set_x(self._suspicion_bgtext3:x() - 1)
	self._suspicion_bgtext3:set_y((math.round(self._suspicion_text_panel:h() / 4)) + 1)
	self._suspicion_bgtext4:set_x(self._suspicion_bgtext4:x() + 1)
	self._suspicion_bgtext4:set_y((math.round(self._suspicion_text_panel:h() / 4)) + 1)
end

function HUDSuspicion:_set_suspicion_text_text(panel, text)
	panel:child("suspicion_text"):set_text(text)
	for i = 1, 4 do
		panel:child("suspicion_bgtext" .. i):set_text(text)
	end
end

function HUDSuspicion:ColorGradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end
	local num = select('#', ...) / 3
	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	local r_ret = r1 + (r2-r1)*relperc
	local g_ret = g1 + (g2-g1)*relperc
	local b_ret = b1 + (b2-b1)*relperc
	return math.round(r_ret*100)/100, math.round(g_ret*100)/100, math.round(b_ret*100)/100
end

function HUDSuspicion:_animate_detection_text(_suspicion_panel, ...)
	while self._animating_text do
		local t = 0
		while t <= 0.01 do
			t = t + coroutine.yield()
			if -1 ~= self._suspicion_value then
				local r,g,b = self:ColorGradient(math.round(self._suspicion_value*100)/100, 0, 0.71, 1, 0.99, 0.08, 0)
				_suspicion_panel:child("suspicion_text"):set_color(Color(1, r, g, b))
				self:_set_suspicion_text_text(_suspicion_panel, math.round(self._suspicion_value*100) .. "%")
				self:_set_suspicion_text_visibility(_suspicion_panel)
			end
		end
	end
end

function HUDSuspicion:animate_eye(...)
	hudsuspicions_animate_eye_original(self, ...)
	self._animating_text = true
	self._text_animation = self._suspicion_panel:child("suspicion_text_panel"):animate(callback(self, self, "_animate_detection_text"))
end

function HUDSuspicion:hide(...)
	hudsuspicion_hide_original(self, ...)
	if (self._text_animation) then
		self._animating_text = false
		self._text_animation = nil
	end
end