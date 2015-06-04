--Initialize Steamworks (optional)
Steamworks:Initialize()

--Set the application title
title="LED Test"

--Create a window
local windowstyle = Window.Titlebar
if System:GetProperty("fullscreen")=="1" then windowstyle=windowstyle+Window.FullScreen end
window=Window:Create(title,0,0,System:GetProperty("screenwidth","1024"),System:GetProperty("screenheight","768"),windowstyle)
--window:HideMouse()

--Create the graphics context
context=Context:Create(window,0)
if context==nil then return end

--Create a world
world=World:Create()
world:SetLightQuality((System:GetProperty("lightquality","1")))
	
--LED Test
import "Scripts/LED/LED.lua"

local pos

--Image
led_image = LED.Image:Create("Materials/Developer/GreyGrid.tex")
led_image:SetScale(0.5, 0.5)
led_image:SetPivot(0.5, 0.5)
led_image:SetPosition(window:GetWidth() / 2 - led_image:GetWidth() / 2, window:GetHeight() / 2 - led_image:GetHeight() / 2)

--Text
led_text = LED.Text:Create("Hover the mouse over me ;)")
pos = led_image:GetPosition()
led_text:SetPosition(pos.x + 4, pos.y + led_image:GetHeight() / 4 - led_text:GetHeight() - 4)
led_text:SetColor(1, 1, 0, 1)
led_text:SetScale(1.25, 1.25)
led_text2 = LED.Text:Create("I'll give you mouse hover coords.")
led_text2:SetPosition(pos.x + 4, pos.y + led_image:GetHeight() / 4 - led_text:GetHeight() + 16)

--Panel
led_panel = LED.Panel:Create(128, 64)
pos = led_image:GetPosition()
led_panel:SetPosition(pos.x + 32, pos.y + 32)
--led_panel:SetPivot(0.5, 0.5)
led_panel:SetScale(0.75, 0.75)
led_panel:SetColor(0, 0.75, 0.75, 0.5)
function led_panel:MouseIn()
	led_text:SetText("I'm LED panel and mouse is IN me :) at " .. Time:GetCurrent() .. ".")
	self:SetColor(0.8, 0.1, 0.85, 0.9)
	self:SetDimensions(148, 80)
end
function led_panel:MouseOut()
	led_text:SetText("Mouse is OUT :( at " .. Time:GetCurrent() .. ".    Q/E to move me | R to release me.")
	led_text2:SetText("I'll give you mouse hover coords.")
	self:SetColor(0, 0.75, 0.75, 0.5)
	self:SetDimensions(128, 64)
end
function led_panel:MouseOver(x, y)
	led_text2:SetText("Mouse OVER coords: x = " .. x .. ", y = " .. y)
end
led_panel:SetInteractive(true)

led_panel2 = LED.Panel:Create(32, 64)
led_panel2:SetPosition(pos.x + 48, pos.y + led_image:GetHeight() * 0.75)
led_panel2:SetColor(0, 0.75, 0, 0.5)
led_panel2:SetPivot(0.5, 0.5)


--Animation
local textures = {}
local texture = Texture:Load("Materials/Icons/PointLight.tex")
table.insert(textures, texture)
texture = Texture:Load("Materials/Icons/ParticleEmitter.tex")
table.insert(textures, texture)
texture = Texture:Load("Materials/Icons/DirectionalLight.tex")
table.insert(textures, texture)

led_animation = LED.Animation:Create(textures)
pos = led_image:GetPosition()
led_animation:SetPosition(pos.x + led_image:GetWidth() * 0.75, pos.y + led_image:GetHeight() * 0.75)
led_animation:SetPlaying(false)
led_animation:SetSpeed(3)
led_animation:SetInteractive(true)
led_animation:SetColor(0.2, 0.2, 0.2, 1)
led_animation.isRotating = false -- custom var, not part of LED 
function led_animation:MouseOver()
	if window:MouseHit(1) then
		self:SetPlaying(not self:GetPlaying())
		led_animation:SetColor(1, 1, 1, 1)
		led_animation.isRotating = true
	end
end
led_animation:SetScale(2, 2)
led_animation:SetPivot(0.5, 0.5)

led_text3 = LED.Text:Create("Click me ;) WASD to move me | F to release me.")
pos = led_animation:GetPosition()
led_text3:SetPosition(pos.x - led_text3:GetWidth() / 2 - 8, pos.y - 48)

while window:KeyDown(Key.Escape)==false do
	
	--If window has been closed, end the program
	if window:Closed() then break end
	
	--Update the app timing
	Time:Update()
	
	--Update the world
	world:Update()
	
	--Render the world
	world:Render()
	
	--Image logic
	--led_image:SetRotation(led_image:GetRotation() + Time:GetSpeed() / 10)
	
	--Panel logic
	local pos = led_panel:GetPosition()
	if (window:KeyDown(Key.Q)) then 		
		led_panel:SetPosition(pos.x - Time:GetSpeed() * 5, pos.y)
	elseif (window:KeyDown(Key.E)) then
		led_panel:SetPosition(pos.x + Time:GetSpeed() * 5, pos.y)
	end	
	if (window:KeyHit(Key.R)) then
		led_panel:Release()
	end		
	led_panel2:SetRotation(led_panel2:GetRotation() + Time:GetSpeed())
	
	--Animation logic 
	pos = led_animation:GetPosition()
	if (window:KeyDown(Key.A)) then 	
		pos.x = pos.x - Time:GetSpeed() * 5		
	elseif (window:KeyDown(Key.D)) then
		pos.x = pos.x + Time:GetSpeed() * 5
	end
	if (window:KeyDown(Key.W)) then 		
		pos.y = pos.y - Time:GetSpeed() * 5
	elseif (window:KeyDown(Key.S)) then
		pos.y = pos.y + Time:GetSpeed() * 5
	end
	led_animation:SetPosition(pos.x, pos.y)	
	if (window:KeyHit(Key.F)) then
		led_animation:Release()
	end		
	if (led_animation.isRotating) then
		led_animation:SetRotation(led_animation:GetRotation() + Time:GetSpeed() / 5)
	end
	
	--Release all elements
	if (window:KeyHit(Key.Z)) then
		LED:Release()
	end
	
	-- Clear the context
	context:SetColor(0, 0, 0, 1)
	context:Clear()	
	
	-- Update the LED
	LED:Update(context)
	
	--Refresh the screen
	context:Sync(true)	
end