local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
function initializeGame()
  require 'init_buttons'

  math.randomseed( os.time() )
end

function scene:createScene( event )
  local screenGroup = self.view

  local loadingImage = display.newImageRect( "splash_screen.png", 480, 320 )
  loadingImage.x = display.contentWidth/2
  loadingImage.y = display.contentHeight/2
  screenGroup:insert(loadingImage)

  local gotoMainMenu = function()
    storyboard.gotoScene( "menu" )
  end

  initializeGame()

  local loadMenuTimer = timer.performWithDelay( 1000, gotoMainMenu, 1 )
end

function scene:enterScene( event )
  print("Loading screen loaded...")

  storyboard.removeAll()
end

function scene:exitScene( event )
end

function scene:destroyScene( event )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
--
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
---------------------------------------------------------------------------------

return scene

