local composer = require( "composer" )
local scene = composer.newScene()

local ui = require "scripts.lib.ui"
local radlib = require "scripts.lib.radlib"

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
local screen = nil

function scene:create( event )
  screen = self.view

  local playButton = nil
  local function onPlayPressed ( event )
    if event.phase == "ended" and playButton.isActive then
      composer.gotoScene( "play" )
    end
  end
  playButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['play'],
      { onRelease = onPlayPressed }
    )
  )
  playButton.x = display.contentCenterX
  playButton.y = 80
  playButton.isActive = true
  screen:insert(playButton)

  local settingsButton = nil
  local function onSettingsPressed( event )
    if event.phase == "ended" and settingsButton.isActive then
      composer.gotoScene( "settings" )
    end
  end
  settingsButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['settings'],
      { onRelease = onSettingsPressed }
    )
  )
  settingsButton.x = display.contentCenterX
  settingsButton.y = 130
  settingsButton.isActive = true
  screen:insert(settingsButton)

  local aboutButton = nil
  local function onAboutPressed( event )
    if event.phase == "ended" and aboutButton.isActive then
      composer.gotoScene( "about" )
    end
  end
  aboutButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['about'],
      { onRelease = onAboutPressed }
    )
  )
  aboutButton.x = display.contentCenterX
  aboutButton.y = 180
  aboutButton.isActive = true
  screen:insert(aboutButton)

  local helpButton = nil
  local function onHelpPressed( event )
    if event.phase == "ended" and helpButton.isActive then
      composer.gotoScene( "help" )
    end
  end
  helpButton = ui.newButton(
    radlib.table.merge(
      _G.buttons['help'],
      { onRelease = onHelpPressed }
    )
  )
  helpButton.x = display.contentCenterX
  helpButton.y = 230
  helpButton.isActive = true
  screen:insert(helpButton)
end

function scene:show( event )

  local sceneGroup = self.view
  local phase = event.phase

  if phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif phase == "did" then
    -- Called when the scene is now on screen
    -- 
    -- INSERT code here to make the scene come alive
    -- e.g. start timers, begin animation, play audio, etc.
    print("Menu loaded...")
  end	
end

function scene:hide( event )
  local sceneGroup = self.view
  local phase = event.phase

  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
    --
    -- INSERT code here to pause the scene
    -- e.g. stop timers, stop animation, unload sounds, etc.)
  elseif phase == "did" then
    -- Called when the scene is now off screen
  end
end

function scene:destroy( event )
  local sceneGroup = self.view

-- Called prior to the removal of scene's "view" (sceneGroup)
-- 
-- INSERT code here to cleanup the scene
-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
--
-- "create" event is dispatched if scene's view does not exist
scene:addEventListener( "create", scene )

-- "show" event is dispatched whenever scene transition has finished
scene:addEventListener( "show", scene )

-- "hide" event is dispatched before next scene's transition begins
scene:addEventListener( "hide", scene )

-- "destroy" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- composer.purgeScene() or composer.removeScene().
scene:addEventListener( "destroy", scene )
---------------------------------------------------------------------------------

return scene
