-- return the first integer index holding the value 
function IndexOf(t,val)
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end

-- LED Namespace
LED = {}

LED.Elements = {}
LED.Interactives = {}

function LED:Update(context) 
	-- Drawing
	context:SetBlendMode(Blend.Alpha)
	for k, e in ipairs(LED.Elements) do
		if (not e.hidden) then
			context:SetColor(e.color.x,e.color.y,e.color.z, e.color.w)	
			context:SetScale(e.scale.x, e.scale.y)
			context:SetRotation(e.rotation)
			e:Draw(context)
		end		
	end
	context:SetScale(1, 1)
	context:SetRotation(0)
	context:SetBlendMode(Blend.Solid)
	
	-- Interaction
	if (#LED.Interactives > 0) then
		local mousePos = Window:GetCurrent():GetMousePosition()
		for k, e in ipairs(LED.Interactives) do
			if (mousePos.x > e.position.x and mousePos.x < (e.position.x + e:GetWidth()) and
				mousePos.y > e.position.y and mousePos.y < (e.position.y + e:GetHeight())) then
				if (not e._mouseOver) then
					e:MouseIn() 					
					e._mouseOver = true
				end
				e:MouseOver(mousePos.x, mousePos.y) 					
			elseif (e._mouseOver) then
				e:MouseOut() 					
				e._mouseOver = false			
			end
		end
	end
end

function LED:Release()
	for k in pairs (LED.Elements) do
		LED.Elements[k] = nil
	end
	for k in pairs (LED.Interactives) do
		LED.Interactives[k] = nil
	end
end

-- ELEMENT - Base class
LED.Element = {}

function LED.Element:Create(initializing)
	local element = {}
	element.position = Vec2(0, 0)
	element.style = 0
	element.color = Vec4(1, 1, 1, 1)
	element.hidden = false
	element.scale = Vec2(1, 1)
	element.rotation = 0
	element.interactive = false
	setmetatable(element, self)
	self.__index = self
	if (not initializing) then table.insert(LED.Elements, element) end	
	return element
end

function LED.Element:Release()
	local index = IndexOf(LED.Elements, self)
	table.remove(LED.Elements, index)
	local index = IndexOf(LED.Interactives, self)
	table.remove(LED.Interactives, index)
end

function LED.Element:SetInteractive(interactive)
	if (interactive) then 
		local index = IndexOf(LED.Interactives, self)
		if (not index) then
			table.insert(LED.Interactives, self)
		end
	else
		local index = IndexOf(LED.Interactives, self)
		table.remove(LED.Interactives, index)
	end
end

function LED.Element:GetInteractive()
	return IndexOf(LED.Interactives, self)
end

function LED.Element:MouseIn()
end

function LED.Element:MouseOut()
end

function LED.Element:MouseOver(x, y)
end

function LED.Element:SetPosition(x, y)
	self.position.x = x
	self.position.y = y
end

function LED.Element:GetPosition()
	return Vec2(self.position.x, self.position.y)	
end

function LED.Element:SetScale(x, y)
	self.scale.x = x
	self.scale.y = y
end

function LED.Element:GetScale()
	return Vec2(self.scale.x, self.scale.y)
end

function LED.Element:SetRotation(rotation)
	self.rotation = rotation
end

function LED.Element:GetRotation()
	return self.rotation
end

function LED.Element:SetHidden(hidden)
	self.hidden = hidden
end

function LED.Element:GetHidden()
	return self.hidden
end

function LED.Element:SetColor(r, g, b, a)
	self.color.x = r
	self.color.y = g
	self.color.z = b
	self.color.w = a
end

function LED.Element:GetColor()
	local color = Vec4(self.color.x, self.color.y, self.color.z, self.color.w)
end

-- TEXT
LED.Text = LED.Element:Create(true)

function LED.Text:Create(text, font, kerning)
	local textElement = LED.Element.Create(self)
	
	if (font ~= nil) then	
		if (type(font) == "string") then
			textElement.font = Font:Load(font)
		else
			textElement.font = font
		end
	else
		textElement.font = Context:GetCurrent():GetFont()
	end
	
	textElement:SetColor(0, 0, 0, 1)
	textElement.text = text or "Text"
	textElement.kerning = kerning or 1	
	return textElement
end

function LED.Text:Draw(context)
	context:SetFont(self.font)
	context:DrawText(self.text, self.position.x, self.position.y, self.kerning or 1)
end

function LED.Text:GetWidth() 
	return self.font:GetTextWidth(self.text) * self.scale.x
end

function LED.Text:GetHeight() 
	return self.font:GetHeight() * self.scale.y
end

function LED.Text:SetFont(font)
	self.font = font
end

function LED.Text:GetFont()
	return self.font
end

function LED.Text:SetText(text)
	self.text = text
end

function LED.Text:GetText()
	return self.text
end

-- PANEL
LED.Panel = LED.Element:Create(true)

function LED.Panel:Create(w, h)
	local panel = LED.Element.Create(self)	
	panel:SetColor(0.5, 0.5, 0.5, 0.5)	
	panel.dimensions = Vec2(w or 64, h or 64)
	return panel
end

function LED.Panel:Draw(context)
	context:DrawRect(self.position.x, self.position.y, self.dimensions.x, self.dimensions.y, self.style)
end

function LED.Panel:SetDimensions(w, h)
	self.dimensions.x = w
	self.dimensions.y = h
end

function LED.Panel:GetDimensions()
	return Vec2(self.dimensions.x, self.dimensions.y)
end

function LED.Panel:SetStyle(style)
	self.style = style
end

function LED.Panel:GetStyle()
	return self.style
end

function LED.Panel:GetWidth() 
	return self.dimensions.x * self.scale.x
end

function LED.Panel:GetHeight() 
	return self.dimensions.y * self.scale.y
end

-- IMAGE
LED.Image = LED.Element:Create(true)

function LED.Image:Create(texture)
	local image = LED.Element.Create(self)
	
	if (type(texture) == "string") then
		image.texture = Texture:Load(texture)
	else
		image.texture = texture	
	end
		
	return image
end

function LED.Image:Draw(context)
	context:DrawImage(self.texture, self.position.x, self.position.y)
end

function LED.Image:GetWidth() 
	return self.texture:GetWidth() * self.scale.x
end

function LED.Image:GetHeight() 
	return self.texture:GetHeight() * self.scale.y
end

function LED.Image:SetTexture(texture)
	self.texture = texture
end

function LED.Image:GetTexture()
	return self.texture
end

-- ANIMATION
LED.Animation = LED.Element:Create(true)

function LED.Animation:Create(textures)
	local animation = LED.Element.Create(self)
	animation.frames = {}
	for k, v in ipairs(textures) do
		animation.frames[k] = v
	end
	animation.playing = true
	animation.currentFrame = 0
	animation.speed = 1
	return animation
end

function LED.Animation:Draw(context)
	if (self.playing) then
		self.currentFrame = self.currentFrame + (Time:GetSpeed() / 60) * self.speed
		self.currentFrame = self.currentFrame % #self.frames		
	end
	context:DrawImage(self.frames[math.floor(self.currentFrame + 1)], self.position.x, self.position.y)
end

function LED.Animation:GetWidth() 
	return self.frames[math.floor(self.currentFrame + 1)]:GetWidth() * self.scale.x
end

function LED.Animation:GetHeight() 
	return self.frames[math.floor(self.currentFrame + 1)]:GetHeight() * self.scale.y
end

function LED.Animation:SetPlaying(playing)
	self.playing = playing
end

function LED.Animation:GetPlaying()
	return self.playing
end

function LED.Animation:SetSpeed(speed)
	self.speed = speed
end

function LED.Animation:GetSpeed()
	return self.speed
end