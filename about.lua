module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	-- Background
	local background = display.newImageRect("images/bk-default.png", 480, 320)
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	localGroup:insert(background)
	
	-- Title
	local title = display.newText("Touch to go back", 0, 0, native.systemFontBold, 16)
	title:setTextColor( 255,255,255)
	title.x = display.contentCenterX
	title.y = display.contentCenterY
	title.name = "title"
	localGroup:insert(title)
	
	-- Touch to go back
	local function touched ( event )
		if ("ended" == event.phase) then
			director:changeScene("menu","fade")
		end
	end
	background:addEventListener("touch",touched)	
		
	unloadMe = function()
	end	
	
	-- MUST return a display.newGroup()
	return localGroup
end
