--Global Variables
version = 1.22
moveCheckVersion = 2.0
smartKBVersion = 1.20
isSimulator = "simulator" == system.getInfo("environment")
isAndroid = "Android" == system.getInfo( "platformName" )
bannerEnd = 53
appOriginY = display.screenOriginY + bannerEnd
titleBarHeight = 32
transitionTime = 500
forceHelp = false

moveList = {}
gameInfo = 
{
	Event = '',
	Site = '',
	Date = '',
	Round = '',
	White = '',
	Black = '',
	Result = '',
	WhiteELO = '',
	BlackELO = '',
	Source = 'ChessNotes',
}

gameInfoType = 
{
	Event = 'default',
	Site = 'default',
	Date = 'default',
	Round = 'number',
	White = 'default',
	Black = 'default',
	Result = 'radio',
	WhiteELO = 'number',
	BlackELO = 'number',
}

--~ function PrintTable( t, l, max )
--~ 	for k,v in pairs( t ) do
--~ 		if l < max then
--~ 			if type( v ) == 'table' then
--~ 				l = l + 1
--~ 				print( string.rep( '\t', l ) .. k )
--~ 				PrintTable(v, l, max)
--~ 				l = l - 1
--~ 			end
--~ 		end
--~ 		print( string.rep( '\t', l ), k, v )
--~ 	end	
--~ end

function GetMoveListPGN()
	local allMoves = ''
	for i=1,#moveList do
		allMoves = allMoves .. i
			allMoves = allMoves .. '. ' .. moveList[i][1]
			if moveList[i][2] ~= nil then
				allMoves = allMoves ..  ' ' .. moveList[i][2] .. '\n'
			end
	end
	return allMoves
end

function LoadGame( filename )
	for i=1,#moveList do
		moveList[i] = nil
	end
	for heading, info in pairs(gameInfo) do
		if heading ~= 'Source' then
			gameInfo[heading] = ''	
		end
	end

	local filePath = system.pathForFile( filename, system.DocumentsDirectory )
	file = io.open( filePath, "r" )
	if file then
		local moveNum = 1
		for line in file:lines() do
			local s,e, heading, info = line:find( '^%[([^ ]*) "([^"]*)"%]$' )
			if heading then -- game info
				gameInfo[heading] = info	
				--print( '[' .. heading .. ' "' .. info .. '"]' )
			else -- moves
				local s,e, wMove, bMove = line:find( '%d%. ([^ ]*) (.*)$' )
				if wMove ~= nil then
					if moveList[moveNum] == nil then
						moveList[moveNum] = {}
					end
					moveList[moveNum][1] = wMove
				end
				
				if bMove ~= nil then
					moveList[moveNum][2] = bMove
					moveNum = moveNum + 1
				end
			end	
		end
        io.close( file )
	end
end

local function GetGameInfo( infoType, defaultInfo )
	if gameInfo[infoType] ~= nil then
		return( '[' .. infoType .. ' "' .. gameInfo[infoType] .. '"]\n' )
	else
		return( '[' .. infoType .. ' "' .. defaultInfo .. '"]\n' )
	end
end

function GetSaveGameText()
	local saveText = ''
 	for heading, info in pairs(gameInfo) do
		--print( heading, info )
		saveText = saveText .. GetGameInfo( heading, info )
 	end
	saveText = saveText .. GetMoveListPGN()
	return saveText
end

function SaveGame( filename )
	local filePath = system.pathForFile( filename, system.DocumentsDirectory )
	--print( filePath )
	file = io.open( filePath, "w" )
	file:write( GetSaveGameText() )
	io.close( file )
end


--~ local adNetwork = "inneractive"
--~ local appID = nil
--~ local ads = require "ads"
--~ -- initialize ad network:
--~ ads.init( adNetwork, appID )

--~ local ads = require "ads"
--~ ads.init( "crossinstall", "QlCk", nil )

local ads = nil
if not isSimulator then
	ads = require "ads"
	ads.init( 'admob', 'ca-app-pub-2270148772893486/6750641653' )
end

-- Create a background to go behind our tableView
local bkgndH = 500
local background = display.newImageRect( "background.png", 320, bkgndH )
background.anchorX = 0
background.anchorY = 0
background.y = display.contentHeight - bkgndH + appOriginY
--gamelist.screens:insert( background )

local editor = require( 'editscreen2' )

local gameList = require( 'gamelist' )
gameList.screens.isVisible = true

local help = require( 'helpwidget' )
help.ShowHelpButton(15)

local state = 'selectgame'
local lastState = state

local function appState(event)
	if help.AskedForHelp() or forceHelp then 
		forceHelp = false
		lastState = state
		state = 'help' 
		local title
		local helpText
		if lastState == 'selectgame' then
			title, helpText = gameList.GetHelpInfo()
			transition.to( gameList.screens, { x = -display.contentWidth * 1.5, alpha=0, time = transitionTime, transition = easing.outQuad } )
			--gameList.screens.isVisible = false
		elseif lastState == 'editgame' then
			title, helpText = editor.GetHelpInfo()
			transition.to( editor.screens, { x = -display.contentWidth * 1.5, alpha=0, time = transitionTime, transition = easing.outQuad } )
			--editor.screens.isVisible = false
		end
		help.ShowHelp( appOriginY, title, helpText )
	end
	if state == 'help' then
		if help.doneWithHelp then
			state = lastState
			lastState = 'help'
			if state == 'selectgame' then
				transition.to( gameList.screens, { x = 0, alpha=1, time = transitionTime, transition = easing.outQuad } )
				--gameList.screens.isVisible = true
			elseif state == 'editgame' then
				transition.to( editor.screens, { x = 0, alpha=1, time = transitionTime, transition = easing.outQuad } )
				--editor.screens.isVisible = true
			end
		end
	elseif state == 'selectgame' then
		if gameList.selectedFile ~= '' then
			--gameList.screens.isVisible = false
			transition.to( gameList.screens, { x = -display.contentWidth * 1.5, alpha=0, time = transitionTime, transition = easing.outQuad } )
			transition.to( editor.screens, { x = 0, alpha=1, time = transitionTime, transition = easing.outQuad } )
			state = 'editgame'
			editor.editDone = false
			editor.filename = gameList.selectedFile
			editor.EditGame()
			editor.screens.isVisible = true
			--print( 'Going to Edit Mode ' .. gameList.selectedFile )
			--print( editor.editDone )
		end
	elseif state == 'editgame' then
		if editor.editDone == true then
			transition.to( editor.screens, { x = display.contentWidth * 1.5, alpha=0, time = transitionTime, transition = easing.outQuad } )
			transition.to( gameList.screens, { x = 0, alpha=1, time = transitionTime, transition = easing.outQuad } )
			--editor.screens.isVisible = false
			state = 'selectgame'
			gameList.selectedFile = ''
			gameList.FindFiles()
			gameList.screens.isVisible = true
			gameList.TransitionToList()
			--print( 'Going to List Mode ' .. gameList.selectedFile )
			--print( editor.editDone )
		else
			if a4h then editor.ShowHelp() end
		end
	end
end

if not isSimulator then
	--ads.show( "banner", { x=0, y=0, interval=30, testMode=true } )	-- standard interval for "inneractive" is 60 seconds
	ads.show( "banner", { x=0, y=0 } )
end

local function onKeyEvent( event )
	local phase = event.phase
	local keyName = event.keyName
	--print( event.phase, event.keyName )

	if ( "back" == keyName and phase == "up" ) then
		if state == 'help' then
			return helpWidget.handleAndroidBackButton()
		elseif state == 'selectgame' then
			return gameList.handleAndroidBackButton()
		elseif state == 'editgame' then
			return editor.handleAndroidBackButton()
		end
	end
end

--add the key callback
Runtime:addEventListener( "key", onKeyEvent )
Runtime:addEventListener( "enterFrame", appState );

