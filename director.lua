module( ..., package.seeall )

--====================================================================--
-- DIRECTOR CLASS
--====================================================================--

--[[ 

 - Version: 1.4
 - Made by Ricardo Rauber Pereira @ 2010
 - Blog: http://rauberlabs.blogspot.com/
 - Mail: ricardorauber@gmail.com
 - Twitter: @rauberlabs

******************
 - INFORMATION
******************

  - This class is free to use, feel free to change but please send new versions
	or new features like new effects to me and help us to make it better!
  - Please take a look on the template.lua file and don't forget to always
	insert your display objects into the localGroup.
  - If you like Director Class, please help us donating at my blog, so I could
	keep doing it for free. http://rauberlabs.blogspot.com/

******************
 - HISTORY
******************

 - 06-OCT-2010 - Ricardo Rauber - Created;
 - 07-OCT-2010 - Ricardo Rauber - Functions loadScene and fxEnded were
								  taken off from the changeScene function;
								  Added function cleanGroups for best
								  memory clean up;
								  Added directorView and effectView groups
								  for better and easier control;
								  Please see INFORMATION to know how to use it;
 - 14-NOV-2010 - Ricardo Rauber - Bux fixes and new getScene function to get
								  the name of the active scene(lua file);
 - 14-FEB-2011 - Ricardo Rauber - General Bug Fixes;
 - 26-APR-2011 - Ricardo Rauber - cleanGroups() changed; Added Pop Up;
 - 21-JUN-2011 - Ricardo Rauber - Added error control; cleanGroups() removed;
								  Added touch protection; loadScene() changed;
								  Effects improved; Send Parameters; Bug fixes;
 - 28-JUN-2011 - Ricardo Rauber - Added Books;
 - 05-JUL-2011 - Ricardo Rauber - Added rebuildGroup(), initVars() and Toggle Degug;
 - 21-JUL-2011 - Ricardo Rauber - Search for missed objects to insert into the
								  right group and prevent keeping on the screen;
 - 25-AUG-2011 - Ricardo Rauber - Bug fixes;

 -- ]]

print( "-----------------------------------------------" )

--====================================================================--
-- TOGGLE DEBUG
--====================================================================--

showDebug = true
--showDebug = false

--====================================================================--
-- CONTENT INFO
--====================================================================--

local _W = display.contentWidth
local _H = display.contentHeight

--====================================================================--
-- DISPLAY GROUPS
--====================================================================--

directorView = display.newGroup()
--
local currView       = display.newGroup()
local prevView       = display.newGroup()
local nextView       = display.newGroup()
local protectionView = display.newGroup()
local popupView      = display.newGroup()
local effectView     = display.newGroup()
--
local initViews = function()
	directorView:insert( currView )
	directorView:insert( prevView )
	directorView:insert( nextView )
	directorView:insert( protectionView )
	directorView:insert( popupView )
	directorView:insert( effectView )
end

--====================================================================--
-- VARIABLES
--====================================================================--

local prevScreen, currScreen, nextScreen, popupScreen
local prevScene, currScene, nextScene, popupScene = "main", "main", "main", "main"
local newScene
local fxTime = 200
local safeDelay = 50
local isChangingScene = false
local popUpOnClose
local isBook = false
local bookPages = {}
local currBookPage = 1
local moveBookPage
--
prevView.x = -_W
prevView.y = 0
currView.x = 0
currView.y = 0
nextView.x = _W
nextView.y = 0
popupView.x = 0
popupView.y = 0

--====================================================================--
-- GET COLOR
--====================================================================--

local getColor = function( strValue1, strValue2, strValue3 )
	
	------------------
	-- Variables
	------------------
	
	local r, g, b
	
	------------------
	-- Test Parameters
	------------------
	
	if type( strValue1 ) == "nil" then
		strValue1 = "black"
	end
	
	------------------
	-- Find Color
	------------------
	
	if string.lower( tostring( strValue1 ) ) == "red" then
		r = 255
		g = 0
		b = 0
	elseif string.lower( tostring( strValue1 ) ) == "green" then
		r = 0
		g = 255
		b = 0
	elseif string.lower( tostring( strValue1 ) ) == "blue" then
		r = 0
		g = 0
		b = 255
	elseif string.lower( tostring( strValue1 ) ) == "yellow" then
		r = 255
		g = 255
		b = 0
	elseif string.lower( tostring( strValue1 ) ) == "pink" then
		r = 255
		g = 0
		b = 255
	elseif string.lower( tostring( strValue1 ) ) == "white" then
		r = 255
		g = 255
		b = 255
	elseif type( strValue1 ) == "number"
	   and type( strValue2 ) == "number"
	   and type( strValue3 ) == "number" then
		r = strValue1
		g = strValue2
		b = strValue3
	else
		r = 0
		g = 0
		b = 0
	end
	
	------------------
	-- Return
	------------------
	
	return r, g, b
	
end

--====================================================================--
-- SHOW ERRORS
--====================================================================--

local showError = function( errorMessage, debugMessage )
	local message = "Director ERROR: " .. tostring( errorMessage )
	local function onComplete( event )
		print()
		print( "-----------------------" )
		print( message )
		print( "-----------------------" )
		print( debugMessage )
		print( "-----------------------" )
		error()
	end
	--
	if showDebug then
		local alert = native.showAlert( "Director Class - ERROR", message, { "OK" }, onComplete )
	else
		onComplete()
	end
end

--====================================================================--
-- GARBAGE COLLECTOR
--====================================================================--

local garbageCollect = function( event )
	collectgarbage( "collect" )
end

--====================================================================--
-- IS DISPLAY OBJECT ?
--====================================================================--

local coronaMetaTable = getmetatable( display.getCurrentStage() )
--
local isDisplayObject = function( aDisplayObject )
	return( type( aDisplayObject ) == "table" and getmetatable( aDisplayObject ) == coronaMetaTable )
end

--====================================================================--
-- PROTECTION
--====================================================================--

------------------
-- Rectangle
------------------

local protection = display.newRect( -_W, -_H, _W * 3, _H * 3 )
protection:setFillColor( 255, 255, 255 )
protection.alpha = 0.01
protection.isVisible = false
protectionView:insert( protection )

------------------
-- Listener
------------------

local fncProtection = function( event )
	return true
end
protection:addEventListener( "touch", fncProtection )
protection:addEventListener( "tap", fncProtection )

--====================================================================--
-- CHANGE CONTROLS
--====================================================================--

------------------
-- Effects Time
------------------

function director:changeFxTime( newFxTime )
	if type( newFxTime ) == "number" then
		fxTime = newFxTime
	end
end

------------------
-- Safe Delay
------------------

function director:changeSafeDelay( newSafeDelay )
	if type( newSafeDelay ) == "number" then
		safeDelay = newSafeDelay
	end
end

--====================================================================--
-- GET SCENES
--====================================================================--

------------------
-- Previous
------------------

function director:getPrevScene()
	return prevScene
end

------------------
-- Current
------------------

function director:getCurrScene()
	return currScene
end

------------------
-- Next
------------------

function director:getNextScene()
	return nextScene
end

--====================================================================--
-- REBUILD GROUP
--====================================================================--

local rebuildGroup = function( target )
	
	------------------
	-- Verify which group
	------------------
	
	-- Prev
	if target == "prev" then
		
		------------------
		-- Clean Group
		------------------
		
		prevView:removeSelf()
		
		------------------
		-- Search for the localGroup.clean() function
		------------------
		
		if prevScreen then
			if prevScreen.clean then
				
				------------------
				-- Clean Object
				------------------
				
				local handler, message = pcall( prevScreen.clean )
				--
				if not handler then
					showError( "Failed to clean object '" .. prevScene .. "' - Please verify the localGroup.clean() function.", message )
					return false
				end
			
			end
			
		end
		
		------------------
		-- Create Group
		------------------
		
		prevView = display.newGroup()
		
	-- Curr
	elseif target == "curr" then
		
		------------------
		-- Clean Group
		------------------
		
		currView:removeSelf()
		
		------------------
		-- Search for the localGroup.clean() function
		------------------
		
		if currScreen then
			if currScreen.clean then
				
				------------------
				-- Clean Object
				------------------
				
				local handler, message = pcall( currScreen.clean )
				--
				if not handler then
					showError( "Failed to clean object '" .. currScene .. "' - Please verify the localGroup.clean() function.", message )
					return false
				end
			
			end
			
		end
		
		------------------
		-- Create Group
		------------------
		
		currView = display.newGroup()
		
	-- Next
	elseif target == "next" then
		
		------------------
		-- Clean Group
		------------------
		
		nextView:removeSelf()
		
		------------------
		-- Search for the localGroup.clean() function
		------------------
		
		if nextScreen then
			if nextScreen.clean then
				
				------------------
				-- Clean Object
				------------------
				
				local handler, message = pcall( nextScreen.clean )
				--
				if not handler then
					showError( "Failed to clean object '" .. nextScene .. "' - Please verify the localGroup.clean() function.", message )
					return false
				end
			
			end
			
		end
		
		------------------
		-- Create Group
		------------------
		
		nextView = display.newGroup()
		
	-- Popup
	elseif target == "popup" then
		
		------------------
		-- Clean Group
		------------------
		
		popupView:removeSelf()
		
		------------------
		-- Search for the localGroup.clean() function
		------------------
		
		if popupScreen then
			if popupScreen.clean then
			
				------------------
				-- Clean Object
				------------------
				
				local handler, message = pcall( popupScreen.clean )
				--
				if not handler then
					showError( "Failed to clean object '" .. popupScene .. "' - Please verify the localGroup.clean() function.", message )
					return false
				end
			
			end
			
		end
		
		------------------
		-- Create Group
		------------------
		
		popupView = display.newGroup()
		
	end
	
	------------------
	-- Init
	------------------
	
	initViews()
	
end

--====================================================================--
-- INITIATE VARIABLES
--====================================================================--

local initVars = function( target )
	
	------------------
	-- Verify which group
	------------------
	
	-- Prev
	if target == "prev" then
		
		------------------
		-- Search for the localGroup.initVars() function
		------------------
		
		if prevScreen then
			if prevScreen.initVars then
				
				------------------
				-- Init Vars
				------------------
				
				local handler, message = pcall( prevScreen.initVars )
				--
				if not handler then
					showError( "Failed to initiate variables of object '" .. prevScene .. "' - Please verify the localGroup.initVars() function.", message )
					return false
				end
			
			end
		end
		
	-- Curr
	elseif target == "curr" then
		
		------------------
		-- Search for the localGroup.initVars() function
		------------------
		
		if currScreen then
			if currScreen.initVars then
				
				------------------
				-- Init Vars
				------------------
				
				local handler, message = pcall( currScreen.initVars )
				--
				if not handler then
					showError( "Failed to initiate variables of object '" .. currScene .. "' - Please verify the localGroup.initVars() function.", message )
					return false
				end
			
			end
			
		end
		
	-- Next
	elseif target == "next" then
		
		------------------
		-- Search for the localGroup.initVars() function
		------------------
		
		if nextScreen then
			if nextScreen.initVars then
				
				------------------
				-- Init Vars
				------------------
				
				local handler, message = pcall( nextScreen.initVars )
				--
				if not handler then
					showError( "Failed to initiate variables of object '" .. nextScene .. "' - Please verify the localGroup.initVars() function.", message )
					return false
				end
			
			end
			
		end
		
	-- Popup
	elseif target == "popup" then
		
		------------------
		-- Search for the localGroup.initVars() function
		------------------
		
		if popupScreen then
			if popupScreen.initVars then
				
				------------------
				-- Init Vars
				------------------
				
				local handler, message = pcall( popupScreen.initVars )
				--
				if not handler then
					showError( "Failed to initiate variables of object '" .. popupScene .. "' - Please verify the localGroup.initVars() function.", message )
					return false
				end
				
			end
			
		end
		
	end
	
end

--====================================================================--
-- UNLOAD SCENE
--====================================================================--

local unloadScene = function( moduleName )
	
	------------------
	-- Test parameters
	------------------
	
	if moduleName ~= "main" then
		
		------------------
		-- Verify if it was loaded
		------------------
		
		if type( package.loaded[ moduleName ] ) ~= "nil" then
			
			------------------
			-- Search for the clean() function
			------------------
			
			if package.loaded[ moduleName ].clean then
				
				------------------
				-- Execute
				------------------
				
				local handler, message = pcall( package.loaded[ moduleName ].clean )
				--
				if not handler then
					showError( "Failed to clean module '" .. moduleName .. "' - Please verify the clean() function.", message )
					return false
				end
				
			end
			
			------------------
			-- Try to free memory
			------------------
			
			package.loaded[ moduleName ] = nil
			--
			local function garbage( event )
				garbageCollect()
			end
			--
			timer.performWithDelay( fxTime, garbage )
			
		end
		
	end
	
end

--====================================================================--
-- LOAD SCENE
--====================================================================--

local loadScene = function( moduleName, target, params )
	
	------------------
	-- Test parameters
	------------------
	
	if type( moduleName ) ~= "string" then
		showError( "Module name must be a string. moduleName = " .. tostring( moduleName ) )
		return false
	end
	
	------------------
	-- Load Module
	------------------
	
	if not package.loaded[ moduleName ] then
		local handler, message = pcall( require, moduleName )
		if not handler then
			showError( "Failed to load module '" .. moduleName .. "' - Please check if the file exists and it is correct.", message )
			return false
		end
	end
	
	------------------
	-- Serach new() Function
	------------------
	
	if not package.loaded[ moduleName ].new then
		showError( "Module '" .. tostring( moduleName ) .. "' must have a new() function." )
		return false
	end
	--
	local functionName = package.loaded[ moduleName ].new
	
	------------------
	-- Variables
	------------------
	
	local handler
	
	------------------
	-- Load choosed scene
	------------------
	
	-- Prev
	if string.lower( target ) == "prev" then
		
		------------------
		-- Rebuild Group
		------------------
		
		rebuildGroup( "prev" )
		
		------------------
		-- Unload Scene
		------------------
		
		if prevScene ~= currScene and prevScene ~= nextScene then
			unloadScene( moduleName )
		end
		
		------------------
		-- Start Scene
		------------------
		
		handler, prevScreen = pcall( functionName, params )
		--
		if not handler then
			showError( "Failed to execute new( params ) function on '" .. tostring( moduleName ) .. "'.", prevScreen )
			return false
		end
		
		------------------
		-- Check if it returned an object
		------------------
		
		if not isDisplayObject( currScreen ) then
			showError( "Module " .. moduleName .. " must return a display.newGroup()." )
			return false
		end
		
		------------------
		-- Books Touch Area
		------------------
		
		local bookBackground = display.newRect( 0, 0, _W, _H )
		bookBackground.alpha = 0.01
		bookBackground:addEventListener( "touch", moveBookPage )
		prevView:insert( bookBackground )
		
		------------------
		-- Finish
		------------------
		
		prevView:insert( prevScreen )
		prevScene = moduleName
		
		------------------
		-- Initiate Variables
		------------------
		
		initVars( "prev" )
		
	-- Curr
	elseif string.lower( target ) == "curr" then
		
		------------------
		-- Rebuild Group
		------------------
		
		rebuildGroup( "curr" )
		
		------------------
		-- Unload Scene
		------------------
		
		if prevScene ~= currScene and currScene ~= nextScene then
			unloadScene( moduleName )
		end
		
		------------------
		-- Start Scene
		------------------
		
		handler, currScreen = pcall( functionName, params )
		--
		if not handler then
			showError( "Failed to execute new( params ) function on '" .. tostring( moduleName ) .. "'.", currScreen )
			return false
		end
		
		------------------
		-- Check if it returned an object
		------------------
		
		if not isDisplayObject( currScreen ) then
			showError( "Module " .. moduleName .. " must return a display.newGroup()." )
			return false
		end
		
		------------------
		-- Books Touch Area
		------------------
		
		local bookBackground = display.newRect( 0, 0, _W, _H )
		bookBackground.alpha = 0.01
		bookBackground:addEventListener( "touch", moveBookPage )
		currView:insert( bookBackground )
		
		------------------
		-- Finish
		------------------
		
		currView:insert( currScreen )
		currScene = moduleName
		
		------------------
		-- Initiate Variables
		------------------
		
		initVars( "curr" )
		
	-- Next
	else
		
		------------------
		-- Rebuild Group
		------------------
		
		rebuildGroup( "next" )
		
		------------------
		-- Unload Scene
		------------------
		
		if prevScene ~= nextScene and currScene ~= nextScene then
	 		unloadScene( moduleName )
	 	end
		
		------------------
		-- Start Scene
		------------------
		
		handler, nextScreen = pcall( functionName, params )
		--
		if not handler then
			showError( "Failed to execute new( params ) function on '" .. tostring( moduleName ) .. "'.", nextScreen )
			return false
		end
		
		------------------
		-- Check if it returned an object
		------------------
		
		if not isDisplayObject( nextScreen ) then
			showError( "Module " .. moduleName .. " must return a display.newGroup()." )
			return false
		end
		
		------------------
		-- Books Touch Area
		------------------
		
		local bookBackground = display.newRect( 0, 0, _W, _H )
		bookBackground.alpha = 0.01
		bookBackground:addEventListener( "touch", moveBookPage )
		nextView:insert( bookBackground )
		
		------------------
		-- Finish
		------------------
		
		nextView:insert( nextScreen )
		nextScene = moduleName
		
		------------------
		-- Initiate Variables
		------------------
		
		initVars( "next" )
		
	end
	
	------------------
	-- Return
	------------------
	
	return true
	
end

------------------
-- Load prev screen
------------------

local loadPrevScene = function( moduleName, params )
	loadScene( moduleName, "prev", params )
	prevView.x = -_W
end

------------------
-- Load curr screen
------------------

local loadCurrScene = function( moduleName, params )
	loadScene( moduleName, "curr", params )
	currView.x = 0
end

------------------
-- Load next screen
------------------

local loadNextScene = function( moduleName, params )
	loadScene( moduleName, "next", params )
	nextView.x = _W
end

--====================================================================--
-- EFFECT ENDED
--====================================================================--

local fxEnded = function( event )
	
	------------------
	-- Reset current view
	------------------
	
	currView.x = 0
	currView.y = 0
	currView.xScale = 1
	currView.yScale = 1
	
	------------------
	-- Rebuild Group
	------------------
	
	rebuildGroup( "curr" )
	
	------------------
	-- Unload scene
	------------------
	
	if currScene ~= nextScene then
		unloadScene( currScene )
	end
	
	------------------
	-- Next -> Current
	------------------
	
	currScreen = nextScreen
	currScene = newScene
	currView:insert( currScreen )
	
	------------------
	-- Reset next view
	------------------
	
	nextView.x = _W
	nextView.y = 0
	nextView.xScale = 1
	nextView.yScale = 1
	nextScene = "main"
	nextScreen = nil
	
	------------------
	-- Finish
	------------------
	
	isChangingScene = false
	protection.isVisible = false
	
	------------------
	-- Return
	------------------
	
	return true
	
end

--====================================================================--
-- CHANGE SCENE
--====================================================================--
	
function director:changeScene( params,
							   nextLoadScene,
							   effect,
							   arg1,
							   arg2,
							   arg3 )
	
	------------------
	-- If is changing scene, return without do anything
	------------------
	
	if isChangingScene then
		return true
	else
		isChangingScene = true
	end
	
	------------------
	-- If is book, return without do anything
	------------------
 
 	if isBook then
 		return true
 	end
	
	------------------
	-- Test parameters
	------------------
	
	if type( params ) ~= "table" then
		arg3 = arg2
		arg2 = arg1
		arg1 = effect
		effect = nextLoadScene
		nextLoadScene = params
		params = nil
	end
	--
	if type( nextLoadScene ) ~= "string" then
		showError( "The scene name must be a string. scene = " .. tostring( nextLoadScene ) )
		return false
	end
	
	------------------
	-- If is popup, don't change
	------------------
	
	if popupScene ~= "main" then
		showError( "Could not change scene inside a popup." )
		return false
	end
	
	------------------
	-- Verify objects on current stage
	------------------
	
	local currentStage = display.getCurrentStage()
	--
	for i = currentStage.numChildren, 1, -1 do
		
		------------------
		-- Verify directorId
		------------------
	
		if type( currentStage[i].directorId ) == "nil" then
			currentStage[i].directorId = currScene
		end
		
		------------------
		-- Insert into the CURR group if it's needed
		------------------
	
		if currentStage[i].directorId == currScene
		and currentStage[i].directorId ~= "main" then			
			currScreen:insert( currentStage[i] )
		end
		
	end
	
	------------------
	-- Prevent change to main
	------------------
	
	if nextLoadScene == "main" then
		return true
	end
	
	------------------
	-- Protection
	------------------
	
	protection.isVisible = true
	
	------------------
	-- Variables
	------------------
	
	newScene = nextLoadScene
	local showFx
	
	------------------
	-- Load Scene
	------------------
	
	loadNextScene( newScene, params )
	
	------------------
	-- Verify objects on current stage
	------------------
	
	for i = currentStage.numChildren, 1, -1 do
		
		------------------
		-- Verify directorId
		------------------
	
		if type( currentStage[i].directorId ) == "nil" then
			currentStage[i].directorId = newScene
		end
		
		------------------
		-- Insert into the NEXT group if it's needed
		------------------
	
		if currentStage[i].directorId == newScene
		and currentStage[i].directorId ~= "main" then			
			nextScreen:insert( currentStage[i] )
		end
		
	end
	
	------------------
	-- EFFECT: Move From Right
	------------------
	
	if effect == "moveFromRight" then
		
		nextView.x = _W
		nextView.y = 0
		--
		showFx = transition.to( nextView, { x = 0,   time = fxTime } )
		showFx = transition.to( currView, { x = -_W, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Over From Right
	------------------
	
	elseif effect == "overFromRight" then
		
		nextView.x = _W
		nextView.y = 0
		--
		showFx = transition.to( nextView, { x = 0, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Move From Left
	------------------
	
	elseif effect == "moveFromLeft" then
		
		nextView.x = -_W
		nextView.y = 0
		--
		showFx = transition.to( nextView, { x = 0,  time = fxTime } )
		showFx = transition.to( currView, { x = _W, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Over From Left
	------------------
	
	elseif effect == "overFromLeft" then
		
		nextView.x = -_W
		nextView.y = 0
		--
		showFx = transition.to( nextView, { x = 0, time = fxTime, onComplete = fxEnded } )
		
	------------------
	-- EFFECT: Move From Top
	------------------
	
	elseif effect == "moveFromTop" then
		
		nextView.x = 0
		nextView.y = -_H
		--
		showFx = transition.to( nextView, { y = 0,  time = fxTime } )
		showFx = transition.to( currView, { y = _H, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Over From Top
	------------------
	
	elseif effect == "overFromTop" then
		
		nextView.x = 0
		nextView.y = -_H
		--
		showFx = transition.to( nextView, { y = 0, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Move From Bottom
	------------------
	
	elseif effect == "moveFromBottom" then
		
		nextView.x = 0
		nextView.y = _H
		--
		showFx = transition.to( nextView, { y = 0,   time = fxTime } )
		showFx = transition.to( currView, { y = -_H, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Over From Bottom
	------------------
	
	elseif effect == "overFromBottom" then
		
		nextView.x = 0
		nextView.y = _H
		--
		showFx = transition.to( nextView, { y = 0, time = fxTime, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Crossfade
	------------------
	
	elseif effect == "crossfade" then
		
		nextView.x = 0
		nextView.y = 0
		--
		nextView.alpha = 0
		--
		showFx = transition.to( currView, { alpha = 0, time = fxTime * 2 } )
		showFx = transition.to( nextView, { alpha = 1, time = fxTime * 2, onComplete = fxEnded } )
	
	------------------
	-- EFFECT: Fade
	------------------
	-- ARG1 = color [ string ]
	------------------
	-- ARG1 = red   [ number ]
	-- ARG2 = green [ number ]
	-- ARG3 = blue  [ number ]
	------------------
	
	elseif effect == "fade" then
		
		nextView.x = _W
		nextView.y = 0
		--
		local fade = display.newRect( -_W, -_H, _W * 3, _H * 3 )
		fade.alpha = 0
		fade:setFillColor( getColor( arg1, arg2, arg3 ) )
		effectView:insert( fade )
		--
		local function returnFade( event )
			currView.x = _W
			nextView.x = 0
			--
			local function removeFade( event )
				fade:removeSelf()
				fxEnded()
			end
			--
			showFx = transition.to( fade, { alpha = 0, time = fxTime, onComplete = removeFade } )
		end
		--
		showFx = transition.to( fade, { alpha = 1.0, time = fxTime, onComplete = returnFade } )
	
	------------------
	-- EFFECT: Flip
	------------------
	
	elseif effect == "flip" then
		
		nextView.xScale = 0.001
		--
		nextView.x = _W / 2
		--
		local phase1, phase2
		--
		showFx = transition.to( currView, { xScale = 0.001,  time = fxTime } )
		showFx = transition.to( currView, { x      = _W / 2, time = fxTime } )
		--
		phase1 = function( e )
			showFx = transition.to( nextView, { xScale = 0.001, x = _W / 2, time = fxTime, onComplete = phase2 } )
		end
		--
		phase2 = function( e )
			showFx = transition.to( nextView, { xScale = 1, x = 0, time = fxTime, onComplete = fxEnded } )
		end
		--
		showFx = transition.to( nextView, { time = 0, onComplete = phase1 } )
	
	------------------
	-- EFFECT: Down Flip
	------------------
	
	elseif effect == "downFlip" then
		
		nextView.x = _W / 2
		nextView.y = _H * 0.15
		--
		nextView.xScale = 0.001
		nextView.yScale = 0.7
		--
		local phase1, phase2, phase3, phase4
		--
		phase1 = function( e )
			showFx = transition.to( currView, { xScale = 0.7, yScale = 0.7, x = _W * 0.15, y = _H * 0.15, time = fxTime, onComplete = phase2 } )
		end
		--
		phase2 = function( e )
			showFx = transition.to( currView, { xScale = 0.001, x = _W / 2, time = fxTime, onComplete = phase3 } )
		end
		--
		phase3 = function( e )
			showFx = transition.to( nextView, { x = _W * 0.15, xScale = 0.7, time = fxTime, onComplete = phase4 } )
		end
		--
		phase4 = function( e )
			showFx = transition.to( nextView, { xScale = 1, yScale = 1, x = 0, y = 0, time = fxTime, onComplete = fxEnded } )
		end
		--
		showFx = transition.to( currView, { time = 0, onComplete = phase1 } )
	
	------------------
	-- EFFECT: None
	------------------
	
	else
		timer.performWithDelay( safeDelay, fxEnded )
	end
	
	------------------
	-- Return
	------------------
	
	return true
	
end

--====================================================================--
-- OPEN POPUP
--====================================================================--

function director:openPopUp( params, newPopUpScene, onClose )
	
	------------------
	-- Test parameters
	------------------
	
	if type( params ) ~= "table" then
		onClose = newPopUpScene
		newPopUpScene = params
		params = nil
	end
	--
	if type( newPopUpScene ) ~= "string" then
		showError( "Module name must be a string. moduleName = " .. tostring( newPopUpScene ) )
		return false
	end
	--
	if type( onClose ) == "function" then
		popUpOnClose = onClose
	else
		popUpOnClose = nil
	end
	
	------------------
	-- Test scene name
	------------------
	
	if newPopUpScene == currScene
	or newPopUpScene == nextScene
	or newPopUpScene == "main"
	then
		return false
	end
	
	------------------
	-- If is inside a popup, don't load
	------------------
	
	if popupScene ~= "main" then
		showError( "Could not load more then 1 popup." )
		return false
	end
	
	------------------
	-- Rebuild Group
	------------------
	
	rebuildGroup( "popup" )
	
	------------------
	-- Unload Scene
	------------------
		
	unloadScene( newPopUpScene )
	popupScene = "main"
	popupScreen = nil
	
	------------------
	-- Load scene
	------------------
	
	local handler, message = pcall( require, newPopUpScene )
	--
	if not handler then
		showError( "Failed to load module '" .. newPopUpScene .. "' - Please check if the file exists and it is correct.", message )
		return false
	end
	
	------------------
	-- Serach for new() function
	------------------
	
	if not package.loaded[ newPopUpScene ].new then
		showError( "Module '" .. tostring( newPopUpScene ) .. "' must have a new() function." )
		return false
	end
	
	------------------
	-- Execute new() function
	------------------
	
	local functionName = package.loaded[ newPopUpScene ].new
	--
	handler, popupScreen = pcall( functionName, params )
	--
	if not handler then
		showError( "Failed to execute news( params ) function on '" .. tostring( moduleName ) .. "'.", popupScreen )
		return false
	end
	
	------------------
	-- Test if a group was returned
	------------------
	
	if not isDisplayObject( currScreen ) then
		showError( "Module " .. moduleName .. " must return a display.newGroup()." )
		return false
	end
	--
	popupView:insert( popupScreen )
	popupScene = newPopUpScene
	
	------------------
	-- Initiate Variables
	------------------
		
	initVars( "popup" )
	
	------------------
	-- Protection
	------------------
	
	protection.isVisible = true
	
	------------------
	-- Return
	------------------
	
	return true
	
end

--====================================================================--
-- CLOSE POPUP
--====================================================================--

function director:closePopUp()
	
	------------------
	-- If no popup is loaded, don't do anything
	------------------
	
	if popupScene == "main" then
		return true
	end
	
	------------------
	-- Rebuild Group
	------------------
	
	rebuildGroup( "popup" )
	
	------------------
	-- Unload Scene
	------------------
		
	unloadScene( newPopUpScene )
	popupScene = "main"
	popupScreen = nil
	
	------------------
	-- Protection
	------------------
	
	protection.isVisible = false
	
	------------------
	-- Call function
	------------------
	
	if type( popUpOnClose ) == "function" then
		popUpOnClose()
	end
	
	------------------
	-- Return
	------------------
	
	return true
	
end

--====================================================================--
-- VERIFY IF IS BOOK
--====================================================================--

function director:isBook()
	return isBook
end

--====================================================================--
-- GET CURRENT PAGE NAME
--====================================================================--

getCurrBookPage = function()
	if bookPages[ currBookPage ] then
		return bookPages[ currBookPage ]
	end
end

--====================================================================--
-- GET CURRENT PAGE NUMBER
--====================================================================--

getCurrBookPageNum = function()
	return currBookPage
end

--====================================================================--
-- GET PAGE COUNT
--====================================================================--

getBookPageCount = function()
	return table.maxn( bookPages )
end

--====================================================================--
-- INSERT PAGES
--====================================================================--

function director:newBookPages( pageList, fade )

	------------------
	-- If is not book, return without do anything
	------------------

 	if not isBook then
 		return true
 	end

	------------------
	-- Test parameters
	------------------
	
	if type( pageList ) ~= "table" then
		return true
	end
	
	------------------
	-- Clean it
	------------------
	
	while getBookPageCount() > 0 do
		table.remove( bookPages )
	end
	
	------------------
	-- Mount
	------------------
	
	local i = 1
	while pageList[ i ] do
		if type( pageList[ i ] ) == "table" then
			bookPages[ i ] = pageList[ i ]
			i = i + 1
		end
	end
		
	------------------
	-- Fade
	------------------
	
	local fadeFx = display.newRect( 0, 0, _W, _H )
	fadeFx:setFillColor( 0, 0, 0 )
	fadeFx.alpha = 0
	fadeFx.isVisible = false
	effectView:insert( fadeFx )
	--
	local fxEnded = function( e )
	
		------------------
		-- Remove Fade
		------------------
	
		fadeFx:removeSelf()
		fadeFx = nil
				
	end
	
	------------------
	-- Go to page
	------------------
	
	local change = function( e )
	
		------------------
		-- Rebuild Group
		------------------
	
		rebuildGroup( "prev" )
		
		------------------
		-- Unload Scene
		------------------
		
		if prevScene ~= bookPages[ 1 ] and prevScene ~= bookPages[ 2 ] then
			unloadScene( prevScene )
		end
		--
		prevScene = "main"
		
		------------------
		-- Rebuild Group
		------------------
	
		rebuildGroup( "next" )
		
		------------------
		-- Unload Scene
		------------------
		
		if nextScene ~= bookPages[ 1 ] and nextScene ~= bookPages[ 2 ] then
			unloadScene( nextScene )
		end
		--
		nextScene = "main"
	
		------------------
		-- Load pages 1 and 2
		------------------
	
		if bookPages[ 1 ] then
			loadCurrScene( bookPages[ 1 ].page, bookPages[ 1 ].params )
			currBookPage = 1
		end
		--
		if bookPages[ 2 ] then
			loadNextScene( bookPages[ 2 ].page, bookPages[ 2 ].params )
		end
		
		------------------
		-- Search for the localGroup.start() function
		------------------
		
		if currScreen then
			if currScreen.start then
				
				------------------
				-- Start Page
				------------------
				
				local handler, message = pcall( currScreen.start )
				--
				if not handler then
					showError( "Failed to start page of object '" .. currScene .. "' - Please verify the localGroup.start() function.", message )
					return false
				end
			
			end
		end
		
		------------------
		-- Complete Fade
		------------------
		
		local showFx = transition.to( fadeFx, { alpha = 0, time = fxTime, onComplete = fxEnded } )
		
	end
	
	------------------
	-- Execute Fade
	------------------
	
	if fade then
		fadeFx.isVisible = true
		local showFx = transition.to( fadeFx, { alpha = 1, time = fxTime, onComplete = change } )
	else
		change()
	end
	
end

--====================================================================--
-- CHANGE BOOK PAGE
--====================================================================--

function director:changeBookPage( target )

	------------------
	-- If is not book, return without do anything
	------------------
 
 	if not isBook then
 		return true
 	end

	------------------
	-- If is changing scene, return without do anything
	------------------

 	if isChangingScene then
 		return true
 	else
 		isChangingScene = true
 	end
	
	------------------
	-- Test parameters
	------------------
	
	if type( target ) == nil then
		return true
	end
	--
	if string.lower( target ) == "next" then
		if getCurrBookPageNum() + 1 < getBookPageCount() then
			target = getCurrBookPageNum() + 1
		else
			target = getBookPageCount()
		end
	elseif string.lower( target ) == "prev" then
		if getCurrBookPageNum() - 1 > 1 then
			target = getCurrBookPageNum() - 1
		else
			target = 1
		end
	end
	--
	if not type( target ) == "number" then
		return true
	end
	--
	local showFx
	
	------------------
	-- Prevent page -1
	------------------
	
	if target < 1 or 
	   target > getBookPageCount() or
	   target == getCurrBookPageNum() then

		local bookFxEnded = function( event )
			isChangingScene = false
		end
		--
		showFx = transition.to( prevView, { x = -_W, time = fxTime, transition = easing.outQuad } )
		showFx = transition.to( currView, { x = 0,   time = fxTime, transition = easing.outQuad } )
		showFx = transition.to( nextView, { x = _W,  time = fxTime, transition = easing.outQuad, onComplete = bookFxEnded } )

	else
	
		------------------
		-- Animate to the correct side
		------------------
		
		-- Moved left
		if target > getCurrBookPageNum() then

			local bookFxEnded = function( event )
				
				------------------
				-- Rebuild Group
				------------------
	
				rebuildGroup( "prev" )
				
				------------------
				-- Unload Scene
				------------------
				
				if prevScene ~= currScene and prevScene ~= nextScene then
					unloadScene( prevScene )
				end
				
				------------------
				-- Curr -> Prev
				------------------
				
				prevScreen = currScreen
				prevScene = currScene
				prevView:insert( prevScreen )
				prevView.x = -_W
				
				------------------
				-- Initiate Variables
				------------------
		
				initVars( "prev" )
				
				------------------
				-- Next -> Curr
				------------------
				
				currScreen = nextScreen
				currScene = nextScene
				currView:insert( currScreen )
				currView.x = 0
				--
				nextScreen = nil
				
				------------------
				-- Load Scene
				------------------
				
				if bookPages[ target + 1 ] then
					loadNextScene( bookPages[ target + 1 ].page, bookPages[ target + 1 ].params )
				end
				--
				nextView.x = _W
				
				------------------
				-- Finish
				------------------
				
				currBookPage = target
				isChangingScene = false
				
				------------------
				-- Search for the localGroup.start() function
				------------------
				
				if currScreen then
					if currScreen.start then
						
						------------------
						-- Start Page
						------------------
						
						local handler, message = pcall( currScreen.start )
						--
						if not handler then
							showError( "Failed to start page of object '" .. currScene .. "' - Please verify the localGroup.start() function.", message )
							return false
						end
					
					end
				end
				
			end
			--
			showFx = transition.to( prevView, { x = -_W, time = fxTime, transition = easing.outQuad } )
			showFx = transition.to( currView, { x = -_W, time = fxTime, transition = easing.outQuad } )
			showFx = transition.to( nextView, { x = 0,   time = fxTime, transition = easing.outQuad, onComplete = bookFxEnded } )

		-- Moved right
		else

			local bookFxEnded = function( event )
				
				------------------
				-- Rebuild Group
				------------------
	
				rebuildGroup( "next" )
				
				------------------
				-- Unload Scene
				------------------
				
				if prevScene ~= nextScene and currScene ~= nextScene then
					unloadScene( nextScene )
				end
				
				------------------
				-- Curr -> Next
				------------------
				
				nextScreen = currScreen
				nextScene = currScene
				nextView:insert( nextScreen )
				nextView.x = _W
				
				------------------
				-- Initiate Variables
				------------------
		
				initVars( "next" )
				
				------------------
				-- Prev -> Curr
				------------------
				
				currScreen = prevScreen
				currScene = prevScene
				currView:insert( currScreen )
				currView.x = 0
				--
				prevScreen = nil
				
				------------------
				-- Load Scene
				------------------
				
				if bookPages[ target - 1 ] then
					loadPrevScene( bookPages[ target - 1 ].page, bookPages[ target - 1 ].params )
				end
				--
				prevView.x = -_W
				
				------------------
				-- Finish
				------------------
				
				currBookPage = target
				isChangingScene = false
				
				------------------
				-- Search for the localGroup.start() function
				------------------
				
				if currScreen then
					if currScreen.start then
						
						------------------
						-- Start Page
						------------------
						
						local handler, message = pcall( currScreen.start )
						--
						if not handler then
							showError( "Failed to start page of object '" .. currScene .. "' - Please verify the localGroup.start() function.", message )
							return false
						end
					
					end
				end
				
			end
			--
			showFx = transition.to( prevView, { x = 0,  time = fxTime, transition = easing.outQuad } )
			showFx = transition.to( currView, { x = _W, time = fxTime, transition = easing.outQuad } )
			showFx = transition.to( nextView, { x = _W, time = fxTime, transition = easing.outQuad, onComplete = bookFxEnded } )
			
		end
				
	end
	
end

--====================================================================--
-- MOVE TO CHANGE BOOK PAGE
--====================================================================--

moveBookPage = function( event )

	------------------
	-- If is not book, return without do anything
	------------------
 
 	if not isBook then
 		return true
 	end
 	
 	------------------
	-- If is changing scene, return without do anything
	------------------

 	if isChangingScene then
 		return true
 	end
 	
 	------------------
 	-- Verify event
 	------------------
 	
	if event.phase == "moved" then
	
		------------------
		-- Move pages while touching
		------------------
	
		if event.xStart > event.x then
			prevView.x = -_W - ( event.xStart - event.x )
			currView.x =   0 - ( event.xStart - event.x )
			nextView.x =  _W - ( event.xStart - event.x )
		else
			prevView.x = -_W + ( event.x - event.xStart )
			currView.x =   0 + ( event.x - event.xStart )
			nextView.x =  _W + ( event.x - event.xStart )			
		end
		
	elseif event.phase == "ended" then
	
		------------------
		-- If page reach limit then change
		------------------
	
		local limit = 0.2
		--
		if currView.x < -_W * limit then
			director:changeBookPage( "next" )
		elseif currView.x > _W * limit then
			director:changeBookPage( "prev" )
		else
			director:changeBookPage( getCurrBookPageNum() )
		end
		
	end
		
end

--====================================================================--
-- GO TO BOOK PAGE
--====================================================================--

function director:goToPage( params, target, fade )

	------------------
	-- Test parameters
	------------------
	
	if type( params ) ~= "table" then
		fade = target
		target = params
		params = nil
	end
	--
	if type( target ) ~= "number" then
		showError( "The page name must be a number. page = " .. tostring( target ) )
		return false
	end
	--
	if target < 1 then
		showError( "Cannot change to page lower then 1. page = " .. tostring( target ) )
		return false
	end
	
	------------------
	-- Fade
	------------------
	
	local fadeFx = display.newRect( -_W, -_H, _W * 3, _H * 3 )
	fadeFx:setFillColor( 0, 0, 0 )
	fadeFx.alpha = 0
	fadeFx.isVisible = false
	effectView:insert( fadeFx )
	--
	local fxEnded = function( e )
	
		------------------
		-- Remove Fade
		------------------
		
		fadeFx:removeSelf()
		fadeFx = nil
		
	end
	
	------------------
	-- Go to page
	------------------
	
	local change = function( e )
	
		-- First page
		if target == 1 then

			------------------
			-- Rebuild Group
			------------------
	
			rebuildGroup( "prev" )
			
			------------------
			-- Unload Scene
			------------------
			
			if prevScene ~= currScene and prevScene ~= nextScene then
				unloadScene( prevScene )
			end
			
			------------------
			-- Load Scenes
			------------------
			
			if bookPages[ 1 ] then
				loadCurrScene( bookPages[ 1 ].page, params or bookPages[ 1 ].params )
				currBookPage = 1
			end
			--
			if bookPages[ 2 ] then
				loadNextScene( bookPages[ 2 ].page, bookPages[ 2 ].params )
			end

		-- Last page
		elseif target == getBookPageCount() then
		
			------------------
			-- Load Scenes
			------------------

			if bookPages[ target ] then
				loadCurrScene( bookPages[ target ].page, params or bookPages[ target ].params )
				currBookPage = target
			end
			--
			if bookPages[ target - 1 ] then
				loadPrevScene( bookPages[ target - 1 ].page, bookPages[ target - 1 ].params )
			end

			------------------
			-- Rebuild Group
			------------------
	
			rebuildGroup( "next" )
			
			------------------
			-- Unload Scene
			------------------
			
			if prevScene ~= nextScene and currScene ~= nextScene then
				unloadScene( nextScene )
			end

		-- Somewhere in the middle
		else

			------------------
			-- Load Scenes
			------------------
		
			if bookPages[ target-1 ] then
				loadPrevScene( bookPages[ target - 1 ].page, bookPages[ target - 1 ].params )
			end
			--
			if bookPages[ target ] then
				loadCurrScene( bookPages[ target ].page, params or bookPages[ target ].params )
				currBookPage = target
			end
			--
			if bookPages[ target + 1 ] then
				loadNextScene( bookPages[ target + 1 ].page, bookPages[ target + 1 ].params )
			end

		end
		
		------------------
		-- Search for the localGroup.start() function
		------------------
		
		if currScreen then
			if currScreen.start then
				
				------------------
				-- Start Page
				------------------
				
				local handler, message = pcall( currScreen.start )
				--
				if not handler then
					showError( "Failed to start page of object '" .. currScene .. "' - Please verify the localGroup.start() function.", message )
					return false
				end
			
			end
		end
		
		------------------
		-- Complete Fade
		------------------
		
		local showFx = transition.to( fadeFx, { alpha = 0, time = fxTime, onComplete = fxEnded } )
		
	end
	
	------------------
	-- Execute Fade
	------------------
	
	if fade then
		fadeFx.isVisible = true
		local showFx = transition.to( fadeFx, { alpha = 1, time = fxTime, onComplete = change } )
	else
		change()
	end
	
end

--====================================================================--
-- TURN TO BOOK OR SCENES
--====================================================================--

function director:turnToBook()
	isBook = true
end
--
function director:turnToScenes()

	------------------
	-- Toggle Books
	------------------

	isBook = false
	
	------------------
	-- Rebuild Group
	------------------

	rebuildGroup( "prev" )
	
	------------------
	-- Unload Scene
	------------------
	
	if prevScene ~= currScene and prevScene ~= nextScene then
		unloadScene( prevScene )
	end

	------------------
	-- Rebuild Group
	------------------

	rebuildGroup( "next" )
	
	------------------
	-- Unload Scene
	------------------
	
	if prevScene ~= nextScene and currScene ~= nextScene then
		unloadScene( nextScene )
	end
	
	------------------
	-- Finish
	------------------
	
	prevScreen = nil
	nextScreen = nil
	prevScene = "main"
	nextScene = "main"
	
end