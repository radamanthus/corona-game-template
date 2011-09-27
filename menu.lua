module(..., package.seeall)

local radlib = require "radlib"

-- Main function - MUST return a display.newGroup()
function new()
  local ui = require("ui")

  local localGroup = display.newGroup()

  -- Background
  local background = display.newImageRect("bk_default.png", 480, 320)
  background.x = display.contentCenterX
  background.y = display.contentCenterY
  localGroup:insert(background)

  -- Menu Buttons - Start

  local playButton = nil
  local function onPlayPressed ( event )
    if event.phase == "ended" and playButton.isActive then
      director:changeScene("play", "fade", 30.0,60.0,90.0)
    end
  end
  playButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['play'],
      { onRelease = onPlayPressed }
    )
  )
  playButton.x = 160
  playButton.y = 80
  playButton.isActive = true
  localGroup:insert(playButton)

  local settingsButton = nil
  local function onSettingsPressed ( event )
    if event.phase == "ended" and settingsButton.isActive then
      director:changeScene("settings", "fade", "green")
    end
  end
  settingsButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['settings'],
      { onRelease = onSettingsPressed }
    )
  )
  settingsButton.x = 160
  settingsButton.y = 130
  settingsButton.isActive = true
  localGroup:insert(settingsButton)

  local helpButton = nil
  local function onHelpPressed ( event )
    if event.phase == "ended" and helpButton.isActive then
      director:changeScene("help", "overFromTop")
    end
  end
  helpButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['help'],
      { onRelease = onHelpPressed }
    )
  )
  helpButton.x = 160
  helpButton.y = 180
  helpButton.isActive = true
  localGroup:insert(helpButton)

  local aboutButton = nil
  local function onAboutPressed ( event )
    if event.phase == "ended" and aboutButton.isActive then
      director:changeScene("about", "moveFromLeft")
    end
  end
  aboutButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['about'],
      { onRelease = onAboutPressed }
    )
  )
  aboutButton.x = 160
  aboutButton.y = 230
  aboutButton.isActive = true
  localGroup:insert(aboutButton)
  -- Menu Buttons - End

  unloadMe = function()
  end

  -- MUST return a display.newGroup()
  return localGroup
end
