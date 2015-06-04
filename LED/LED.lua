-- return the first integer index holding the value 
function IndexOf(t,val)
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end

-- LED Namespace
LED = {}

-- Set of all entities
LED.Entities = {}

LED.Shaders = {
	drawprimitive = Shader:Load("Scripts/LED/drawprimitive.shader"),
	drawimage = Shader:Load("Scripts/LED/drawimage.shader"),
	drawtext = Shader:Load("Scripts/LED/drawtext.shader")
}

function LED:Update(context)
	context:SetBlendMode(Blend.Alpha)
	context:SetScale(1, 1)
	context:SetRotation(0)
	local mousePos = Window:GetCurrent():GetMousePosition()
	
	for k, e in ipairs(LED.Entities) do
		if (not e.hidden) then e:Update(context, mousePos.x, mousePos.y) end
	end
	
	context:SetShader(nil)
	context:SetRotation(0)
	context:SetScale(1, 1)
	context:SetBlendMode(Blend.Solid)
end

-- Release all entities
function LED:Release()
	for k in pairs (LED.Entities) do
		LED.Entities[k] = nil
	end
end

-- ENTITY - Abstract base class
LED.Entity = {}

function LED.Entity:Create(initializing)
	local entity = {}
	entity.position = Vec2(0, 0)
	entity.style = 0
	entity.color = Vec4(1, 1, 1, 1)
	entity.hidden = false
	entity.scale = Vec2(1, 1)
	entity.rotation = 0
	entity.pivot = Vec2(0, 0)
	entity.offset = Vec2(0, 0)
	entity.interacting = false
	--entity.colliding = false
	setmetatable(entity, self)
	self.__index = self
	if (not initializing) then table.insert(LED.Entities, entity) end	
	return entity
end

function LED.Entity:Update(context, x, y)
	if (self.interacting) then self:Interaction(x, y) end
	--if (self.colliding) then self:Collide(x, y) end
	
	context:SetShader(self.shader or nil)
	self:Draw(context)
end

function LED.Entity:Draw(context)		
	context:SetScale(self.scale.x, self.scale.y)
	context:SetRotation(self.rotation)
	self.shader:SetVec2("LED_pivot", Vec2(self.offset.x / self.scale.x, self.offset.y / self.scale.y))
	self.shader:SetVec4("LED_drawcolor", self.color)		
end

function LED.Entity:Interaction(x, y)
	if (x > self.position.x and x < (self.position.x + self:GetWidth()) and
		y > self.position.y and y < (self.position.y + self:GetHeight())) then
		if (not self._mouseOver) then
			self:MouseIn() 					
			self._mouseOver = true
		end
		self:MouseOver(x, y) 					
	elseif (self._mouseOver) then
		self:MouseOut() 					
		self._mouseOver = false			
	end
end

function LED.Entity:Release()
	local index = IndexOf(LED.Entities, self)
	if (index) then table.remove(LED.Entities, index) end
end

function LED.Entity:SetInteracting(interacting)
	self.interacting = interacting
end

function LED.Entity:GetInteracting()
	return self.interacting
end

function LED.Entity:MouseIn()
end

function LED.Entity:MouseOut()
end

function LED.Entity:MouseOver(x, y)
end

function LED.Entity:SetPosition(x, y)
	self.position.x = x
	self.position.y = y
end

function LED.Entity:GetPosition()
	return Vec2(self.position.x, self.position.y)	
end

function LED.Entity:SetScale(x, y)
	self.scale.x = x
	self.scale.y = y
	self:CalcOffset(self.pivot.x, self.pivot.y)
end

function LED.Entity:GetScale()
	return Vec2(self.scale.x, self.scale.y)
end

function LED.Entity:SetRotation(rotation)
	self.rotation = rotation
end

function LED.Entity:GetRotation()
	return self.rotation
end

function LED.Entity:SetPivot(x, y)
	self.pivot.x = x
	self.pivot.y = y
	self:CalcOffset(x, y)
end

function LED.Entity:CalcOffset(x, y)
	self.offset.x = x * self:GetWidth()
	self.offset.y = y * self:GetHeight()
end

function LED.Entity:GetPivot()
	return Vec2(self.pivot.x, self.pivot.y)
end

function LED.Entity:SetHidden(hidden)
	self.hidden = hidden
end

function LED.Entity:GetHidden()
	return self.hidden
end

function LED.Entity:SetColor(r, g, b, a)
	self.color.x = r
	self.color.y = g
	self.color.z = b
	self.color.w = a
end

function LED.Entity:GetColor()
	local color = Vec4(self.color.x, self.color.y, self.color.z, self.color.w)
end

-- TEXT class
LED.Text = LED.Entity:Create(true)

function LED.Text:Create(text, font, kerning)
	local textEntity = LED.Entity.Create(self)
	
	if (font ~= nil) then	
		if (type(font) == "string") then
			textEntity.font = Font:Load(font)
		else
			textEntity.font = font
		end
	else
		textEntity.font = Context:GetCurrent():GetFont()
	end
	
	textEntity:SetColor(0, 0, 0, 1)
	textEntity.text = text or "Text"
	textEntity.kerning = kerning or 1	
	textEntity.shader = LED.Shaders.drawtext
	return textEntity
end

function LED.Text:Draw(context)
	LED.Entity.Draw(self, context)
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

-- Rect class
LED.Rect = LED.Entity:Create(true)

function LED.Rect:Create(w, h)
	local rect = LED.Entity.Create(self)	
	rect:SetColor(0.5, 0.5, 0.5, 0.5)	
	rect.dimensions = Vec2(w or 64, h or 64)
	rect.shader = LED.Shaders.drawprimitive
	return rect
end


function LED.Rect:Draw(context)		
	LED.Entity.Draw(self, context)
	context:DrawRect(self.position.x + self.offset.x, self.position.y + self.offset.y, 
		self.dimensions.x, self.dimensions.y, self.style)	
end

function LED.Rect:SetDimensions(w, h)
	self.dimensions.x = w
	self.dimensions.y = h
	self:CalcOffset(self.pivot.x, self.pivot.y)
end

function LED.Rect:GetDimensions()
	return Vec2(self.dimensions.x, self.dimensions.y)
end

function LED.Rect:SetStyle(style)
	self.style = style
end

function LED.Rect:GetStyle()
	return self.style
end

function LED.Rect:GetWidth() 
	return self.dimensions.x * self.scale.x
end

function LED.Rect:GetHeight() 
	return self.dimensions.y * self.scale.y
end

-- IMAGE class
LED.Image = LED.Entity:Create(true)

function LED.Image:Create(texture, initializing)
	local image = LED.Entity.Create(self, initializing)
	
	if (type(texture) == "string") then
		image.texture = Texture:Load(texture)
	else
		image.texture = texture	
	end
		
	image.shader = LED.Shaders.drawimage
		
	return image
end

function LED.Image:Draw(context)
	LED.Entity.Draw(self, context)
	context:DrawImage(self.texture, self.position.x + self.offset.x, self.position.y + self.offset.y)	
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

-- ANIMATION class
LED.Animation = LED.Entity:Create(true)

function LED.Animation:Create(textures)
	local animation = LED.Entity.Create(self)
	animation.frames = {}
	for k, v in ipairs(textures) do
		animation.frames[k] = LED.Image:Create(v, true)		
	end
	animation.playing = true
	animation.currentFrame = 0
	animation.speed = 1
	animation.shader = LED.Shaders.drawimage
	return animation
end

function LED.Animation:Draw(context)
	LED.Entity.Draw(self, context)
	if (self.playing) then
		self.currentFrame = self.currentFrame + (Time:GetSpeed() / 60) * self.speed
		self.currentFrame = self.currentFrame % #self.frames		
	end
	context:DrawImage(self.frames[math.floor(self.currentFrame + 1)].texture, 
		self.position.x + self.offset.x, self.position.y + self.offset.y)
end

function LED.Animation:SetPivot(x, y)
	LED.Entity.SetPivot(self, x, y)
	for k, v in ipairs(self.frames) do
		v:SetPivot(x, y)
	end
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