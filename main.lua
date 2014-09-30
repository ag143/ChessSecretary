--Global Variables
version = 1.04
moveCheckVersion = 2.0
isSimulator = "simulator" == system.getInfo("environment")
isAndroid = "Android" == system.getInfo( "platformName" )
bannerEnd = 53
appOriginY = display.screenOriginY + bannerEnd


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
	WhiteElo = '',
	BlackElo = '',
	Source = 'ChessNotes',
}

gameInfoType = 
{
	Event = 'string',
	Site = 'string',
	Date = 'date',
	Round = 'number',
	White = 'string',
	Black = 'string',
	Result = 'string',
	WhiteElo = 'number',
	BlackElo = 'number',
	Source = 'locked',
}

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

local function WriteGameInfo( infoType, defaultInfo )
	if gameInfo[infoType] ~= nil then
		file:write( '[' .. infoType .. ' "' .. gameInfo[infoType] .. '"]\n' )
	else
		file:write( '[' .. infoType .. ' "' .. defaultInfo .. '"]\n' )
	end
end

function SaveGame( filename )
	local filePath = system.pathForFile( filename, system.DocumentsDirectory )
	--print( filePath )
	file = io.open( filePath, "w" )
	--print( 'SAVE GAME' )
 	for heading, info in pairs(gameInfo) do
		--print( heading, info )
		WriteGameInfo( heading, info )
 	end
	local moves = GetMoveListPGN()
	file:write( moves )
	io.close( file )
end


local adNetwork = "inneractive"
local appID = nil
local ads = require "ads"
-- initialize ad network:
ads.init( adNetwork, appID )

local editor = require( 'editscreen' )
editor.screens.isVisible = false

local gameList = require( 'gamelist' )
gameList.screens.isVisible = true

local help = require( 'helpwidget' )
help.ShowHelpButton(15)

local state = 'selectgame'
local lastState = state

local function appState(event)
	if help.AskedForHelp()  then 
		lastState = state
		state = "help" 
		local title
		local helpText
		if lastState == 'selectgame' then
			title, helpText = gameList.GetHelpInfo()
		elseif lastState == 'editgame' then
			title, helpText = editor.GetHelpInfo()
		end
		help.ShowHelp( appOriginY, title, helpText )
	end
	if state == 'help' then
		if help.doneWithHelp then
			state = lastState
			lastState = 'help'
		end
	elseif state == 'selectgame' then
		if gameList.selectedFile ~= '' then
			gameList.RemoveInfo()
			gameList.screens.isVisible = false
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
			editor.screens.isVisible = false
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
	ads.show( "banner", { x=0, y=0, interval=30, testMode=true } )	-- standard interval for "inneractive" is 60 seconds
end
Runtime:addEventListener( "enterFrame", appState );

