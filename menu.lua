module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	-- Background
	local background = display.newImage("images/backgrounds/menu.png")
	localGroup:insert(background)
	
	-- Menu Buttons - Start

  local playButton = display.newImage("images/buttons/play.png")
  local function playPressed ( event )
  	if event.phase == "ended" then
  		director:changeScene("play", "fade", 30.0,60.0,90.0)
  	end
  end
  playButton:addEventListener("touch", playPressed)
  playButton.x = 160
  playButton.y = 80
  localGroup:insert(playButton)        
  

  local settingsButton = display.newImage("images/buttons/settings.png")
  local function settingsPressed ( event )
  	if event.phase == "ended" then
  		director:changeScene("settings", "fade", "green")
  	end
  end
  settingsButton:addEventListener("touch", settingsPressed)
  settingsButton.x = 160
  settingsButton.y = 130
  localGroup:insert(settingsButton)        
  

  local helpButton = display.newImage("images/buttons/help.png")
  local function helpPressed ( event )
  	if event.phase == "ended" then
  		director:changeScene("help", "overFromTop")
  	end
  end
  helpButton:addEventListener("touch", helpPressed)
  helpButton.x = 160
  helpButton.y = 180
  localGroup:insert(helpButton)        
  

  local aboutButton = display.newImage("images/buttons/about.png")
  local function aboutPressed ( event )
  	if event.phase == "ended" then
  		director:changeScene("about", "moveFromLeft")
  	end
  end
  aboutButton:addEventListener("touch", aboutPressed)
  aboutButton.x = 160
  aboutButton.y = 230
  localGroup:insert(aboutButton)        
  
	-- Menu Buttons - End
					
	unloadMe = function()
	end
						
	-- MUST return a display.newGroup()
	return localGroup
end
