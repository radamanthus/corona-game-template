module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	-- Background
	local background = display.newImage("images/backgrounds/default.png")
	localGroup:insert(background)
	
	-- Title
	local title = display.newText("Touch to go back", 0, 0, native.systemFontBold, 16)
	title:setTextColor( 255,255,255)
	title.x = 160
	title.y = 240
	title.name = "title"
	localGroup:insert(title)
	
	-- Touch to go back
	local function touched ( event )
		if event.phase == "ended" then
			director:changeScene("menu","fade")
		end
	end
	background:addEventListener("touch",touched)
	
	unloadMe = function()
	end	
	
	-- MUST return a display.newGroup()
	return localGroup
end
