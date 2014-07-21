local widget = require( "widget" )
local moveCheck = require( "movechecker" )

local editor = {}
editor.filename = ''
moveNum = 1
local maxMoveNum = 0
local moveColor = 1 -- 1 == w, 2 == b
local currMove = ''
local moveList = {}

local butnWt = display.contentWidth/8
local butnHt = display.contentHeight*2/24
if butnHt > butnWt then
	butnHt = butnWt
end
local baseY = display.contentHeight-butnHt

editor.editScreen = nil
local editScreenBkgnd = nil
local numberbuttons = {}
local letterbuttons = {}
local piecebuttons = {}
local kingbuttons = {}
local movebuttons = {}
local doneButton
editor.editDone = false

local moveDisplay
local moveListDisplay
local LEFT_PADDING = 10
local ROW_HEIGHT = 20
local MLDisplayHeight = display.actualContentHeight/2.75
local MLD_Top = display.actualContentHeight/2.1 - MLDisplayHeight

--print( MLD_Top + MLDisplayHeight )
--print( display.contentHeight - (butnHt*7) )
if MLD_Top + MLDisplayHeight > display.contentHeight - (butnHt*7) then
	MLDisplayHeight = display.contentHeight - (butnHt*7) - MLD_Top
	--print( MLD_Top + MLDisplayHeight )
end


local MLD_NumRows = MLDisplayHeight / (ROW_HEIGHT+2)
local MLD_TopRow = 0

local function FormatMove( num )
	local currMoveStr = ''
	
	if num == moveNum then
		currMoveStr = currMoveStr .. num .. '>'
	else
		currMoveStr = currMoveStr .. num .. '.'
	end
	if moveList[num] ~= nil then
		--print( currMoveStr )
		if moveList[num][1] ~= nil then
			if num == moveNum and moveColor == 1 then
				currMoveStr = currMoveStr .. ' (' .. moveList[num][1] .. ') '
			else
				currMoveStr = currMoveStr .. ' ' .. moveList[num][1]
			end
			--print( 'White ' .. currMoveStr )
			if moveList[num][2] ~= nil then
				if num == moveNum and moveColor == 2 then
					currMoveStr = currMoveStr .. ', (' .. moveList[num][2] .. ') '
				else
					currMoveStr = currMoveStr .. ', ' .. moveList[num][2]
				end
				--print( 'Black ' .. currMoveStr )
			end
		end
	end
	return currMoveStr
end

local function ScrollToRow( num )
	--print( num, MLD_TopRow )
	if num <= moveListDisplay:getNumRows() then
		if num - MLD_TopRow > MLD_NumRows then
			-- Need to scroll down
			--print( 'Scroll down ... ' )
			MLD_TopRow = num - MLD_NumRows
			if MLD_TopRow < 0 then
				MLD_TopRow = 0
			end
		elseif num < MLD_TopRow+3 then
			-- Need to scroll up
			--print( 'Scroll up ... ' )
			MLD_TopRow = num - 3
			if MLD_TopRow < 0 then
				MLD_TopRow = 0
			end
		--else
		end
		moveListDisplay:scrollToY( { y=-1*(MLD_TopRow)*(ROW_HEIGHT+2), time=0 } )			
	end
	--print( num, MLD_TopRow )
	moveListDisplay:reloadData()
end

local function onMoveListRowRender( event )
	local phase = event.phase
	local row = event.row
	
	-- in graphics 2.0, the group contentWidth / contentHeight are initially 0, and expand once elements are inserted into the group.
	-- in order to use contentHeight properly, we cache the variable before inserting objects into the group

	local groupContentHeight = row.contentHeight

	--print(  FormatMove(row.index) )
	local rowTitle = display.newText( row, FormatMove(row.index), 0, 0, native.systemFontBold, 14 )

	-- in Graphics 2.0, the row.x is the center of the row, no longer the top left.
	rowTitle.x = LEFT_PADDING

	-- we also set the anchorX of the text to 0, so the object is x-anchored at the left
	rowTitle.anchorX = 0

	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	--print( row.contentHeight )
	--print( moveListDisplay:getContentPosition() )
	--print( display.actualContentHeight/3 )
end

local function onMoveListRowTouch( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		-- Update the item selected text
		moveNum = row.index
		moveColor = 1
		
		if moveList[moveNum][moveColor] ~= nil then
			currMove = moveList[moveNum][moveColor]
			UpdateMoveDisplay()
			ScrollToRow( moveNum )
		end
	end
end


moveListDisplay = widget.newTableView
{
	left = display.contentCenterX - display.actualContentWidth/4,
	top = MLD_Top,
	width = display.actualContentWidth/2,
	height = MLDisplayHeight,
	hideBackground = true,
	onRowRender = onMoveListRowRender,
	onRowTouch = onMoveListRowTouch,
}
--print( display.contentHeight, display.topStatusBarContentHeight )

editor.GatherMoves = function()
	local allMoves = ''
	for i=1,#moveList do
		allMoves = allMoves .. i
--~ 		if i == moveNum then
--~ 			allMoves = allMoves .. '> '
--~ 			if moveColor == 1 then
--~ 				allMoves = allMoves .. '( ' .. moveList[i][1] .. ' )'
--~ 				if moveList[i][2] ~= nil then
--~ 					allMoves = allMoves ..  ' ' .. moveList[i][2] .. '\n'
--~ 				end
--~ 			else
--~ 				allMoves = allMoves .. moveList[i][1]
--~ 				if moveList[i][2] ~= nil then
--~ 					allMoves = allMoves ..  ' ( ' .. moveList[i][2] .. ' )\n'
--~ 				end
--~ 			end
--~ 		else
			allMoves = allMoves .. '. ' .. moveList[i][1]
			if moveList[i][2] ~= nil then
				allMoves = allMoves ..  ' ' .. moveList[i][2] .. '\n'
			end
--		end
	end
	--print( allMoves )
	return allMoves
end


local lfs = require "lfs"

local function SaveGame()
	if string.find( editor.filename, '.pgn' ) == nil then
		editor.filename = editor.filename..'.pgn'
	end
	local filePath = system.pathForFile( editor.filename, system.DocumentsDirectory )
	print( filePath )
	file = io.open( filePath, "w" )
	file:write( '[Event ""]\n' )
	file:write( '[Site ""]\n' )
	file:write( '[Date ""]\n' )
	file:write( '[Round ""]\n' )
	file:write( '[White ""]\n' )
	file:write( '[Black ""]\n' )
	file:write( '[Result ""]\n' )
	file:write( '[WhiteElo ""]\n' )
	file:write( '[BlackElo ""]\n' )
	file:write( '[Source "ChessSec"]\n' )
	file:write( '[EventDate ""]\n' )
	file:write( '[TimeSpend ""]\n' )
	local moves = editor.GatherMoves()
	--moves = string:gsub( moves, '\n', ' ' )
	file:write( moves )
	io.close( file )
	--print( editor.GatherMoves() )
end

editor.LoadGame = function()
	moveNum = 1
	maxMoveNum = 0
	moveColor = 1 -- 1 == w, 2 == b
	currMove = ''
	for i=1,#moveList do
		moveList[i] = nil
	end
	moveListDisplay:deleteAllRows()
	local filePath = system.pathForFile( editor.filename, system.DocumentsDirectory )
	print( filePath )
	print( display.actualContentWidth, display.actualContentHeight - display.topStatusBarContentHeight )
	file = io.open( filePath, "r" )
	if file then
		for line in file:lines() do
			--print( 'Line ' .. line )
			if line:find('^%[.*%]$' ) then
				--print( 'Header Line ' .. line )
			else
				local s,e, wMove, bMove = line:find( '%d%. ([^ ]*) (.*)$' )
				--print( line)
				--print(wMove)
				--print(bMove)
				-- TODO: Use EnterMove instead
				if wMove ~= nil then
					if moveList[moveNum] == nil then
						moveList[moveNum] = {}
						moveListDisplay:insertRow(
						{
							isCategory = false,
							rowHeight = ROW_HEIGHT,
							rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 0.5, 0, 0.2 } },
							lineColor = { 0.5, 0.5, 0.5, 0 }
						} )
						--print( 'Adding Row' )
					end
					moveList[moveNum][moveColor] = wMove
					currMove = wMove
					UpdateMoveDisplay( currMove )
					moveColor = 2

					if bMove ~= nil then
						moveList[moveNum][moveColor] = bMove
						currMove = bMove
						UpdateMoveDisplay( currMove )
						moveNum = moveNum + 1
						maxMoveNum = moveNum
						moveColor = 1
					end
				end
				--print( moveNum, moveColor )
			end
		end	
		currMove = ''
		UpdateMoveDisplay()
		ScrollToRow( moveNum-1 )
		io.close( file )
	end
end

function ChangeButtonColors()
	--print( 'change colors' )
	for i=1,#numberbuttons do
		if moveColor == 2 then
			numberbuttons[i]:setFillColor( 0.15,0.15,0.15 )
		else
			numberbuttons[i]:setFillColor( 1,1,1 )
		end
	end
	for i=1,#letterbuttons do
		if moveColor == 2 then
			letterbuttons[i]:setFillColor( 0.15,0.15,0.15 )
		else
			letterbuttons[i]:setFillColor( 1,1,1 )
		end
	end
	for i=1,#piecebuttons do
		if moveColor == 2 then
			piecebuttons[i]:setFillColor( 0.15,0.15,0.15 )
		else
			piecebuttons[i]:setFillColor( 1,1,1 )
		end
	end
	for i=1,#kingbuttons do
		if moveColor == 2 then
			kingbuttons[i]:setFillColor( 0.15,0.15,0.15 )
		else
			kingbuttons[i]:setFillColor( 1,1,1 )
		end
	end
end

-- Function to handle button events
local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then
		--print( 'Button ' .. event.target:getLabel() .. ' was pressed and released' )
		currMove = currMove .. event.target:getLabel()
		UpdateMoveDisplay( currMove )
	end    
end

local function Done( event )
	if editor.editDone == false then
		SaveGame()
		editor.filename = ''
		editor.editDone = true
		moveListDisplay:deleteAllRows()
	end
end

local function EnterMove( event )
	if ( "ended" == event.phase ) then
		if  moveCheck.CheckCurrMove( currMove ) then
			if moveList[moveNum] == nil then
				moveList[moveNum] = {}
				moveListDisplay:insertRow(
				{
					isCategory = false,
					rowHeight = ROW_HEIGHT,
					rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 0.5, 0, 0.2 } },
					lineColor = { 0.5, 0.5, 0.5, 0 }
				} )
			end
			if moveColor == 1 then
				moveList[moveNum][1] = currMove
				moveColor = 2
			else
				moveList[moveNum][2] = currMove
				moveColor = 1
				moveNum = moveNum + 1
				if maxMoveNum < moveNum then
					maxMoveNum = moveNum
				end
			end
			if moveNum <= maxMoveNum and 
			   moveList[moveNum] ~= nil and
			   moveList[moveNum][moveColor] ~= nil then
				currMove = moveList[moveNum][moveColor]
			else
				currMove = ''
			end
			UpdateMoveDisplay()
			ChangeButtonColors()
			ScrollToRow( moveNum )
		end
	end
end

local function BkspMove( event )
	if ( "ended" == event.phase ) then
		currMove = string.sub( currMove, 1, string.len(currMove)-1)
		UpdateMoveDisplay( currMove )
	end
end

local function PrevMove( event )
	if ( "ended" == event.phase ) then
		if moveNum > 1 then
			moveNum = moveNum - 1
			currMove = moveList[moveNum][1]
			moveColor = 1
			UpdateMoveDisplay( currMove )
			ScrollToRow( moveNum )
		end
		--print( moveNum, moveColor, maxMoveNum )
	end
end

local function NextMove( event )
	if ( "ended" == event.phase ) then
		if maxMoveNum > moveNum then
			moveNum = moveNum + 1
			if moveList[moveNum] ~= nil then
				currMove = moveList[moveNum][1]
			else
				currMove = ''
			end
			moveColor = 1
			UpdateMoveDisplay( currMove )
			ScrollToRow( moveNum )
		end
		--print( moveNum, moveColor, maxMoveNum )
	end
end
 
local move = { '','','<<','<','>','>>','','' }
local letters = { 'a','b','c','d','e','f','g','h' }
local pieces = { '','R','Q','x','+','B','N','' }

local buttonInfo = 
{
	left = 10,
	top = baseY,
	width = butnWt,
	height = butnHt,
	defaultFile = "sqbuttond.png",
	overFile = "sqbuttono.png",
	labelColor = { default={ 1,1,1 }, over={ 1,1,1 } },
	label = "",
	fontSize = 20,
	onEvent = handleButtonEvent
}

-- Setup the Edit Screen
editor.editScreen = display.newGroup()
editScreenBkgnd = display.newRoundedRect( 0, display.screenOriginY + display.topStatusBarContentHeight, display.actualContentWidth, display.actualContentHeight - display.topStatusBarContentHeight, 18 )
editScreenBkgnd:setFillColor( 0.25, 0.25, 0.25 )
editScreenBkgnd.anchorX = 0
editScreenBkgnd.anchorY = 0
editor.editScreen:insert( editScreenBkgnd )

moveDisplay = display.newText( '', 0, 0, "Arial", 14 )
editor.editScreen:insert( moveDisplay )

-- Create a background to go behind our tableView
local background = display.newImage( editor.editScreen, "bg.png", display.contentCenterX - display.actualContentWidth/4, MLD_Top, true )
background.height = MLDisplayHeight
background.width = display.actualContentWidth/2
background.anchorX = 0; background.anchorY = 0

editor.editScreen:insert( moveListDisplay )

-- Setup the keyboard
buttonInfo.height = butnHt

-- Number and Letter buttons
for i=1,8 do
	buttonInfo.left = (i-1) * butnWt
	
	-- Number Buttons
	buttonInfo.top = baseY-butnHt
	buttonInfo.label = i
	numberbuttons[i] = widget.newButton(buttonInfo)
	editor.editScreen:insert( numberbuttons[i] )

	-- Letter Buttons
	buttonInfo.top = baseY - (2*butnHt)
	buttonInfo.label = letters[i]
	letterbuttons[i] = widget.newButton(buttonInfo)
	editor.editScreen:insert( letterbuttons[i] )

	-- Piece Buttons
	if pieces[i] ~= '' then
		buttonInfo.top = baseY - (3*butnHt)
		buttonInfo.label = pieces[i]
		piecebuttons[#piecebuttons+1] = widget.newButton(buttonInfo)
		editor.editScreen:insert( piecebuttons[#piecebuttons] )
	end
end

-- MoveButtons
	buttonInfo.top = baseY

	buttonInfo.left = 2 * butnWt
	buttonInfo.label = '<<'
	buttonInfo.onEvent = PrevMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( movebuttons[#movebuttons] )

	buttonInfo.left = 3 * butnWt
	buttonInfo.label = '<'
	buttonInfo.onEvent = BkspMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( movebuttons[#movebuttons] )

	buttonInfo.left = 4 * butnWt
	buttonInfo.label = '>'
	buttonInfo.onEvent = EnterMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( movebuttons[#movebuttons] )

	buttonInfo.left = 5 * butnWt
	buttonInfo.label = '>>'
	buttonInfo.onEvent = NextMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( movebuttons[#movebuttons] )
	
--KingButtons
	buttonInfo.defaultFile = "rtbuttond.png"
	buttonInfo.overFile = "rtbuttono.png"	
	buttonInfo.top = baseY - butnHt*4
	buttonInfo.width = butnWt*2
	buttonInfo.onEvent = handleButtonEvent
	
	buttonInfo.label = '0-0'
	buttonInfo.left = butnWt
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( kingbuttons[#kingbuttons] )

	buttonInfo.label = 'K'
	buttonInfo.left = butnWt * 3
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( kingbuttons[#kingbuttons] )
	
	buttonInfo.label = '0-0-0'
	buttonInfo.left = butnWt * 5
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editor.editScreen:insert( kingbuttons[#kingbuttons] )
	
--Done Button
	buttonInfo.top = baseY - butnHt*5
	buttonInfo.label = 'Done'
	buttonInfo.left = butnWt * 3
	buttonInfo.onEvent = Done
	doneButton = widget.newButton(buttonInfo)	
	editor.editScreen:insert( doneButton )


function UpdateMoveDisplay()
	moveDisplay.text = currMove
	moveDisplay.x = display.contentWidth / 2.0
	moveDisplay.y = baseY - butnHt*6
	moveDisplay.anchorY = 0
end

--editor.editScreen.isVisible = false
return editor