module(..., package.seeall)
 
--====================================================================--        
-- DIRECTOR CLASS
--====================================================================--
--
-- Version: 1.2a (not an official Ricardo Rauber release, modified cleanGroups)
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
-- 14-NOV-2010 - Ricardo Rauber - Bux fixes and new getScene function to get
--                                the name of the active scene (lua file)
-- 14-FEB-2011 - Ricardo Rauber - General Bug Fixes
--
-- 06-MAR-2011 - Jonathan Beebe - Modified the cleanGroups function to be
--								  more efficient and remove ALL corona display
--								  objects within a group, instead of just
--								  groups within a group. Old cleanGroups would
--								  leave objects behind at times.
--
--====================================================================--
-- INFORMATION
--====================================================================--
--
-- * For best practices, use fps=60, scale = "zoomStretch" on config.lua
--
-- * In main.lua file, you have to import the class like this:
--
--   director = require( "director" )
--   local mainGroup = display.newGroup()       
--   mainGroup:insert( director.directorView )
--
-- * To change scenes, use this command [use the effect of your choice]
--
--   director:changeScene("settings","moveFromLeft")
--
-- * Every scene is a lua module file and must have a new() function that
--   must return a local display group, like this: [see template.lua]
--
--   module(..., package.seeall)
--   local localGroup = display.newGroup()
--   function new()
--     ------ Your code here ------
--     return localGroup
--   end
--
-- * Every display object must be inserted on the local display group
--
--   local background = display.newImage( "background.png" )
--   localGroup:insert( background )
--
-- * This class doesn't clean timers! If you want to stop timers when
--   change scenes, you'll have to do it manually creating a clean() function.
--
--====================================================================--
 
directorView = display.newGroup()
currView     = display.newGroup()
nextView     = display.newGroup()
effectView   = display.newGroup()
--
local currScreen, nextScreen
local currScene, nextScene = "main", "main"
local newScene
local fxTime = 200
local safeDelay = 50
local isChangingScene = false
--
directorView:insert(currView)
directorView:insert(nextView)
directorView:insert(effectView)
--
currView.x = 0
currView.y = 0
nextView.x = display.contentWidth
nextView.y = 0

------------------------------------------------------------------------        
-- GET COLOR
------------------------------------------------------------------------

local function getColor ( arg1, arg2, arg3 )
	--
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
	return r, g, b
	--
end

------------------------------------------------------------------------        
-- CHANGE CONTROLS
------------------------------------------------------------------------

-- fxTime
function director:changeFxTime ( newFxTime )
  if type(newFxTime) == "number" then
    fxTime = newFxTime
  end
end

-- safeDelay
function director:changeSafeDelay ( newSafeDelay )
  if type(newSafeDelay) == "number" then
    safeDelay = newSafeDelay
  end
end

------------------------------------------------------------------------        
-- GET SCENES
------------------------------------------------------------------------

function director:getCurrScene ()
	return currScene
end
--
function director:getNextScene ()
	return nextScene
end
 
------------------------------------------------------------------------        
-- CLEAN GROUP
------------------------------------------------------------------------

--[[	BELOW IS THE OLD CLEANGROUPS:
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
		return true
	end
end
]]--

local coronaMetaTable = getmetatable(display.getCurrentStage())

-- Returns whether aDisplayObject is a Corona display object.
local isDisplayObject = function(aDisplayObject)
	return (type(aDisplayObject) == "table" and getmetatable(aDisplayObject) == coronaMetaTable)
end

local function cleanGroups ( objectOrGroup )
    if(not isDisplayObject(objectOrGroup)) then return end
    if objectOrGroup.numChildren then
		-- we have a group, so first clean that out
		while objectOrGroup.numChildren > 0 do
			-- clean out the last member of the group (work from the top down!)
			cleanGroups ( objectOrGroup[objectOrGroup.numChildren])
		end
    end
    
    -- we have either an empty group or a normal display object - remove it
    objectOrGroup:removeSelf()
    
    return
end

------------------------------------------------------------------------        
-- CALL CLEAN FUNCTION
------------------------------------------------------------------------

local function callClean ( moduleName )
	if type(package.loaded[moduleName]) == "table" then
		if string.lower(moduleName) ~= "main" then
			for k,v in pairs(package.loaded[moduleName]) do
				if k == "clean" and type(v) == "function" then
					package.loaded[moduleName].clean()
				end
			end
		end
	end
end

------------------------------------------------------------------------        
-- UNLOAD SCENE
------------------------------------------------------------------------

local function unloadScene ( moduleName )
	if moduleName ~= "main" and type(package.loaded[moduleName]) == "table" then
		package.loaded[moduleName] = nil
		local function garbage ( event )
			collectgarbage("collect")
		end
		garbage()
		timer.performWithDelay(fxTime,garbage)
	end
end
 
------------------------------------------------------------------------        
-- LOAD SCENE
------------------------------------------------------------------------
 
local function loadScene ( moduleName, target )

	-- Test parameters
	if type(moduleName) == "nil" then
		return true
	end
	if type(target) == "nil" then
		target = "next"
	end
	
	-------------------------------------
	-- Load choosed scene
	-------------------------------------
	
	-- Prev
 	if string.lower(target) == "curr" then
 		--
 		callClean ( moduleName )
 		--
 		cleanGroups(currView,0)
 		currView = display.newGroup()
 		--
 		if nextScene == moduleName then
 			cleanGroups(nextView,0)
 			nextView = display.newGroup()
 		end
 		--
 		unloadScene( moduleName )
 		--
		currScreen = require(moduleName).new()
		currView:insert(currScreen)
		currScene = moduleName

	-- Next
	else
		--
		callClean ( moduleName )
		--
		cleanGroups(nextView,0)
		nextView = display.newGroup()
		--
 		if currScene == moduleName then
 			cleanGroups(currView,0)
 			currView = display.newGroup()
 		end
 		--
 		unloadScene( moduleName )
 		--
		nextScreen = require(moduleName).new()
		nextView:insert(nextScreen)
		nextScene = moduleName
		
	end
	
end

-- Load curr screen
function director:loadCurrScene ( moduleName )
	loadScene ( moduleName, "curr" )
end

-- Load next screen
function director:loadNextScene ( moduleName )
	loadScene ( moduleName, "next" )
end
 
------------------------------------------------------------------------
-- EFFECT ENDED
------------------------------------------------------------------------
 
local function fxEnded ( event )
 
	currView.x = 0
	currView.y = 0
	currView.xScale = 1
	currView.yScale = 1
	--
	callClean  ( currScene )
	cleanGroups( currView ,0)
	currView = display.newGroup()
	unloadScene( currScene )
	--
	currScreen = nextScreen
	currScene = newScene
	currView:insert(currScreen)
	--
	nextView.x = display.contentWidth
	nextView.y = 0
	nextView.xScale = 1
	nextView.yScale = 1
	--
	isChangingScene = false
        
end
 
------------------------------------------------------------------------        
-- CHANGE SCENE
------------------------------------------------------------------------
 
function director:changeScene(nextLoadScene, 
                              effect, 
                              arg1,
                              arg2,
                              arg3)

	-----------------------------------
	-- If is changing scene, return without do anything
	-----------------------------------
 
 	if isChangingScene then
 		return true
 	else
 		isChangingScene = true
 	end
 
	-----------------------------------
	-- If is the same, don't change
	-----------------------------------
        
	if currScene then
		if string.lower(currScene) == string.lower(nextLoadScene) then
			return true
		end
	end
        
	newScene = nextLoadScene
	local showFx
 
	-----------------------------------
	-- EFFECT: Move From Right
	-----------------------------------
        
	if effect == "moveFromRight" then
                        
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*-1, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Over From Right
	-----------------------------------
        
	elseif effect == "overFromRight" then
        
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Move From Left
	-----------------------------------
        
	elseif effect == "moveFromLeft" then
        
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Left
	-----------------------------------
        
	elseif effect == "overFromLeft" then
        
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Move From Top
	-----------------------------------

	elseif effect == "moveFromTop" then

		nextView.x = 0
		nextView.y = display.contentHeight*-1
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Top
	-----------------------------------
        
	elseif effect == "overFromTop" then
        
		nextView.x = 0
		nextView.y = display.contentHeight*-1
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Move From Bottom
	-----------------------------------

	elseif effect == "moveFromBottom" then

		nextView.x = 0
		nextView.y = display.contentHeight
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight*-1, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Bottom
	-----------------------------------
        
	elseif effect == "overFromBottom" then
        
		nextView.x = 0
		nextView.y = display.contentHeight
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Crossfade
	-----------------------------------

	elseif effect == "crossfade" then

		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		nextView.alpha = 0
		nextView.x = 0
		--
		showFx = transition.to ( nextView, { alpha=1, time=fxTime*2 } )
		--
		timer.performWithDelay( fxTime*2+safeDelay, fxEnded )
                
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
        
		local r, g, b = getColor ( arg1, arg2, arg3 )
		--
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		local fade = display.newRect( 0 - display.contentWidth, 0 - display.contentHeight, display.contentWidth * 3, display.contentHeight * 3 )
		fade.alpha = 0
		fade:setFillColor( r,g,b )
		effectView:insert(fade)
		--
		showFx = transition.to ( fade, { alpha=1.0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		--
		local function returnFade ( event )
                
			showFx = transition.to ( fade, { alpha=0, time=fxTime } )
			--
			local function removeFade ( event )
				fade:removeSelf()
			end
			--
			timer.performWithDelay( fxTime+safeDelay, removeFade )

		end
		--
		timer.performWithDelay( fxTime+safeDelay+1, returnFade )
                
	-----------------------------------
	-- EFFECT: Flip
	-----------------------------------
        
	elseif effect == "flip" then
        
		showFx = transition.to ( currView, { xScale=0.001, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.5, time=fxTime } )
		--
		loadScene (newScene)
		--
		nextView.xScale=0.001
		nextView.x=display.contentWidth*0.5
		--
		showFx = transition.to ( nextView, { xScale=1, delay=fxTime, time=fxTime } )
		showFx = transition.to ( nextView, { x=0, delay=fxTime, time=fxTime } )
		--
		timer.performWithDelay( fxTime*2+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Down Flip
	-----------------------------------
        
	elseif effect == "downFlip" then
        
		showFx = transition.to ( currView, { xScale=0.7, time=fxTime } )
		showFx = transition.to ( currView, { yScale=0.7, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.15,  time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight*0.15, time=fxTime } )
		showFx = transition.to ( currView, { xScale=0.001, delay=fxTime, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.5, delay=fxTime, time=fxTime } )
		--
		loadScene (newScene)
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
		timer.performWithDelay( fxTime*4+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: None
	-----------------------------------
        
	else
		timer.performWithDelay( 0, fxEnded )
		loadScene (newScene)
	end
    
	return true
	
end