--Global Variables
version = 1.02
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
	Source = 'ChessSec',
	EventDate = '',
	TimeSpend = '',
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
			if line:find('^%[.*%]$' ) then -- game info
				local s,e, heading, info = line:find( '^%[([^" ]*)"([^"]*)"%]$' )
				if s ~= nil then
					gameInfo[heading] = info	
					--print( '[' .. heading .. ' "' .. info .. '"]' )
				end
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
	print( filePath )
	file = io.open( filePath, "w" )
	WriteGameInfo( 'Event', '' )
	WriteGameInfo( 'Site', '' )
	WriteGameInfo( 'Date', '' )
	WriteGameInfo( 'Round', '' )
	WriteGameInfo( 'White', '' )
	WriteGameInfo( 'Black', '' )
	WriteGameInfo( 'Result', '' )
	WriteGameInfo( 'WhiteElo', '' )
	WriteGameInfo( 'BlackElo', '' )
	WriteGameInfo( 'Source', 'ChessSec' )
	WriteGameInfo( 'EventDate', '' )
	WriteGameInfo( 'TimeSpend', '' )
	local moves = GetMoveListPGN()
	--moves = string:gsub( moves, '\n', ' ' )
	file:write( moves )
	io.close( file )
	--print( editor.GatherMoves() )
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
	local a4h = help.AskedForHelp() 
--~ 	if a4h then 
--~ 		lastState = state
--~ 		state = "help" 
--~ 	end
--~ 	if state == 'help' then
--~ 		local title
--~ 		local helpText
--~ 		--if lastState
--~ 		--help.ShowHelp( )
--~ 		if help.doneWithHelp then
--~ 		end
--~ 	else
	if state == 'selectgame' then
		if gameList.selectedFile ~= '' then
			gameList.RemoveInfo()
			gameList.screens.isVisible = false
			state = 'editgame'
			editor.editDone = false
			editor.filename = gameList.selectedFile
			LoadGame( editor.filename )
			editor.EditGame()
			editor.screens.isVisible = true
			--print( 'Going to Edit Mode ' .. gameList.selectedFile )
			--print( editor.editDone )
		else
			if a4h then gameList.ShowHelp() end
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

