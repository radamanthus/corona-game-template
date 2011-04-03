-- 
-- adapted from Ghosts Vs Monsters sample project 
-- (see http://blog.anscamobile.com/2010/12/ghosts-vs-monsters-open-source-game-in-corona-sdk/)
-- 

module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	local theTimer
	local loadingImage
	
	local showLoadingScreen = function()
		loadingImage = display.newImageRect( "images/splashScreen.png", 480, 320 )
		loadingImage.x = display.contentWidth
		loadingImage.y = display.contentHeight
		localGroup:insert(loadingImage)
		
		local goToLevel = function()
			director:changeScene( "menu" )
		end
		
		math.randomseed( os.time() )		
		theTimer = timer.performWithDelay( 1000, goToLevel, 1 )
	end
	
	showLoadingScreen()
	
	unloadMe = function()
	end
	
	-- MUST return a display.newGroup()
	return localGroup
end
