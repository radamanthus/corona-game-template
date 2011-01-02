module(..., package.seeall)

--====================================================================--	
-- DIRECTOR CLASS
--====================================================================--
--
-- Version: 1.1
-- Made by Ricardo Rauber Pereira @ 2010
-- Blog: http://rauberlabs.blogspot.com/
-- Mail: ricardorauber@gmail.com
--
-- This class is free to use, feel free to change but please send new versions
-- or new features like new effects to me and help us to make it better!
--
--====================================================================--	
-- CHANGES
--====================================================================--
--
-- 06-OCT-2010 - Ricardo Rauber - Created
-- 07-OCT-2010 - Ricardo Rauber - Functions loadScene and fxEnded were
--                                taken off from the changeScene function;
--                                Added function cleanGroups for best
--                                memory clean up;
--                                Added directorView and effectView groups
--                                for better and easier control;
--                                Please see INFORMATION to know how to use it
--
--====================================================================--
-- VARIABLES
--====================================================================--
--
-- currentView: 	Main display group
-- nextView:		Display group for transitions
-- currentScreen:	Active module
-- nextScreen:		New module
-- lastScene:		Active module in string for control
-- nextScene:		New module in string for control
-- effect:		Transition type
-- arg[N]:		Arguments for each transition
-- fxTime:		Time for transition.to
--
--====================================================================--
-- INFORMATION
--====================================================================--
--
-- * For best practices, use fps=60, scale = "zoomStretch" on config.lua
--
-- * In main.lua file, you have to import the class like this:
--
--   director = require("director")
--   local g = display.newGroup()	
--	 g:insert(director.directorView)
--
-- * To change scenes, use this command [use the effect of your choice]
--
--   director:changeScene("settings","moveFromLeft")
--
-- * Every scene is a lua module file and must have a new() function that
--   must return a local display group, like this: [see template.lua]
--
--   module(..., package.seeall)
--   function new()
--	   local lg = display.newGroup()
--     ------ Your code here ------
--     return lg
--   end
--
-- * Every display object must be inserted on the local display group
--
--   local background = display.newImage("background.png")
--	 lg:insert(background)
--
-- * This class doesn't clean timers! If you want to stop timers when
--   change scenes, you'll have to do it manually.
--
--====================================================================--

directorView = display.newGroup()
currentView  = display.newGroup()
nextView     = display.newGroup()
effectView   = display.newGroup()
--
local currentScreen, nextScreen
local lastScene = "main"
local fxTime = 200
--
directorView:insert(currentView)
directorView:insert(nextView)
directorView:insert(effectView)

------------------------------------------------------------------------	
-- CLEAN GROUP
------------------------------------------------------------------------

local function cleanGroups ( curGroup, level )
	if curGroup.numChildren then
		while curGroup.numChildren > 0 do
			cleanGroups ( curGroup[curGroup.numChildren], level+1 )
		end
		if level > 0 then
			curGroup:removeSelf()
		end
	else
		curGroup:removeSelf()
		curGroup = nil
		return
	end
end

------------------------------------------------------------------------	
-- LOAD SCENE
------------------------------------------------------------------------

local function loadScene ( nextScene )

	nextScreen = require(nextScene).new()
	nextView:insert(nextScreen)
	
end

------------------------------------------------------------------------	
-- EFFECT ENDED
------------------------------------------------------------------------

local function fxEnded ( event )

	currentView.x = 0
	currentView.y = 0
	currentView.xScale = 1
	currentView.yScale = 1
	--
	cleanGroups(currentView,0)
	--
	currentScreen = nextScreen
	currentView:insert(currentScreen)
	nextView.x = display.contentWidth
	nextView.y = 0
	nextView.xScale = 1
	nextView.yScale = 1
	
end

------------------------------------------------------------------------	
-- CHANGE SCENE
------------------------------------------------------------------------

function director:changeScene(nextScene, 
                              effect, 
                              arg1,
                              arg2,
                              arg3)


	-----------------------------------
	-- If is the same, don't change
	-----------------------------------
	
	if lastScene then
		if string.lower(lastScene) == string.lower(nextScene) then
			return true
		end
	end
	
	local showFx

	-----------------------------------
	-- EFFECT: Move From Right
	-----------------------------------
	
	if effect == "moveFromRight" then
			
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currentView, { x=display.contentWidth*-1, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
		
	-----------------------------------
	-- EFFECT: Over From Right
	-----------------------------------
	
	elseif effect == "overFromRight" then
	
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
		
	-----------------------------------
	-- EFFECT: Move From Left
	-----------------------------------
	
	elseif effect == "moveFromLeft" then
	
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currentView, { x=display.contentWidth, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
	
	-----------------------------------
	-- EFFECT: Over From Left
	-----------------------------------
	
	elseif effect == "overFromLeft" then
	
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
	
	-----------------------------------
	-- EFFECT: Over From Top
	-----------------------------------
	
	elseif effect == "overFromTop" then
	
		nextView.x = 0
		nextView.y = display.contentHeight*-1
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
	
	-----------------------------------
	-- EFFECT: Over From Bottom
	-----------------------------------
	
	elseif effect == "overFromBottom" then
	
		nextView.x = 0
		nextView.y = display.contentHeight
		--
		loadScene (nextScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
		
	-----------------------------------
	-- EFFECT: Fade
	-----------------------------------
	-- ARG1 = color [string]
	-----------------------------------
	-- ARG1 = red   [number]
	-- ARG2 = green [number]
	-- ARG3 = blue  [number]
	-----------------------------------
	
	elseif effect == "fade" then
	
		local r, g, b
		--
		if type(arg1) == "nil" then
			arg1 = "black"
		end
		--
		if string.lower(arg1) == "red" then
			r=255
			g=0
			b=0
		elseif string.lower(arg1) == "green" then
			r=0
			g=255
			b=0
		elseif string.lower(arg1) == "blue" then
			r=0
			g=0
			b=255
		elseif string.lower(arg1) == "yellow" then
			r=255
			g=255
			b=0
		elseif string.lower(arg1) == "pink" then
			r=255
			g=0
			b=255
		elseif string.lower(arg1) == "white" then
			r=255
			g=255
			b=255
		elseif type (arg1) == "number"
		   and type (arg2) == "number"
		   and type (arg3) == "number" then
			r=arg1
			g=arg2
			b=arg3
		else
			r=0
			g=0
			b=0
		end
		--
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (nextScene)
		--
		local fade = display.newRect( 0 - display.contentWidth, 0 - display.contentHeight, display.contentWidth * 3, display.contentHeight * 3 )
		fade.alpha = 0
		fade:setFillColor( r,g,b )
		effectView:insert(fade)
		--
		showFx = transition.to ( fade, { alpha=1.0, time=fxTime } )
		--
		timer.performWithDelay( fxTime, fxEnded )
		--
		local function returnFade ( event )
		
			showFx = transition.to ( fade, { alpha=0, time=fxTime } )
			--
			local function removeFade ( event )
				fade:removeSelf()
			end
			--
			timer.performWithDelay( fxTime, removeFade )
			
		end
		--
		timer.performWithDelay( fxTime+1, returnFade )
		
	-----------------------------------
	-- EFFECT: Flip
	-----------------------------------
	
	elseif effect == "flip" then
	
		showFx = transition.to ( currentView, { xScale=0.001, time=fxTime } )
		showFx = transition.to ( currentView, { x=display.contentWidth*0.5, time=fxTime } )
		--
		loadScene (nextScene)
		--
		nextView.xScale=0.001
		nextView.x=display.contentWidth*0.5
		--
		showFx = transition.to ( nextView, { xScale=1, delay=fxTime, time=fxTime } )
		showFx = transition.to ( nextView, { x=0, delay=fxTime, time=fxTime } )
		--
		timer.performWithDelay( fxTime*2, fxEnded )
		
	-----------------------------------
	-- EFFECT: Down Flip
	-----------------------------------
	
	elseif effect == "downFlip" then
	
		showFx = transition.to ( currentView, { xScale=0.7, time=fxTime } )
		showFx = transition.to ( currentView, { yScale=0.7, time=fxTime } )
		showFx = transition.to ( currentView, { x=display.contentWidth*0.15,  time=fxTime } )
		showFx = transition.to ( currentView, { y=display.contentHeight*0.15, time=fxTime } )
		showFx = transition.to ( currentView, { xScale=0.001, delay=fxTime, time=fxTime } )
		showFx = transition.to ( currentView, { x=display.contentWidth*0.5, delay=fxTime, time=fxTime } )
		--
		loadScene (nextScene)
		--
		nextView.x = display.contentWidth*0.5
		nextView.xScale=0.001
		nextView.yScale=0.7
		nextView.y=display.contentHeight*0.15
		--
		showFx = transition.to ( nextView, { x=display.contentWidth*0.15, delay=fxTime*2, time=fxTime } )
		showFx = transition.to ( nextView, { xScale=0.7, delay=fxTime*2, time=fxTime } )
		showFx = transition.to ( nextView, { xScale=1, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { yScale=1, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { x=0, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { y=0, delay=fxTime*3, time=fxTime } )
		--
		timer.performWithDelay( fxTime*4, fxEnded )
		
	-----------------------------------
	-- EFFECT: None
	-----------------------------------
	
	else
		timer.performWithDelay( 0, fxEnded )
		loadScene (nextScene)
	end
	
	-----------------------------------
	-- Clean up memory
	-----------------------------------
	
  if lastScene then
	  -- Custom clean function (unloadMe)
	  if string.lower(lastScene) ~= "main" then
	  	package.loaded[lastScene].unloadMe()
	  end
	  package.loaded[lastScene] = nil
  end	
	-- if lastScene then
	-- 	package.loaded[lastScene] = nil
	-- end
	lastScene = nextScene
	collectgarbage("collect")
	
	return true
end