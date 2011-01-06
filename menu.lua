module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local ui = require("ui")
	
	local localGroup = display.newGroup()
	
	-- Background
	local background = display.newImage("images/bk-default.png")
	localGroup:insert(background)
	
	-- Menu Buttons - Start

  local playButton = ui.newButton{
		defaultSrc = "images/btn-play.png",
		defaultX = 160,
		defaultY = 32,		
		overSrc = "images/btn-play-over.png",
		overX = 160,
		overY = 32,		
		onEvent = onplayTouch,
		id = "playButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		emboss = false
	}
	playButton.x = 160
	playButton.y = 80
	localGroup:insert(playButton)
  

  local settingsButton = ui.newButton{
		defaultSrc = "images/btn-settings.png",
		defaultX = 160,
		defaultY = 32,		
		overSrc = "images/btn-settings-over.png",
		overX = 160,
		overY = 32,		
		onEvent = onsettingsTouch,
		id = "settingsButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		emboss = false
	}
	settingsButton.x = 160
	settingsButton.y = 130
	localGroup:insert(settingsButton)
  

  local helpButton = ui.newButton{
		defaultSrc = "images/btn-help.png",
		defaultX = 160,
		defaultY = 32,		
		overSrc = "images/btn-help-over.png",
		overX = 160,
		overY = 32,		
		onEvent = onhelpTouch,
		id = "helpButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		emboss = false
	}
	helpButton.x = 160
	helpButton.y = 180
	localGroup:insert(helpButton)
  

  local aboutButton = ui.newButton{
		defaultSrc = "images/btn-about.png",
		defaultX = 160,
		defaultY = 32,		
		overSrc = "images/btn-about-over.png",
		overX = 160,
		overY = 32,		
		onEvent = onaboutTouch,
		id = "aboutButton",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		emboss = false
	}
	aboutButton.x = 160
	aboutButton.y = 230
	localGroup:insert(aboutButton)
  
	-- Menu Buttons - End
					
	unloadMe = function()
	end
						
	-- MUST return a display.newGroup()
	return localGroup
end
