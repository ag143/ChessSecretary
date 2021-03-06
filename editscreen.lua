local widget = require( "widget" )
--local moveCheck = nil
--if version >= moveCheckVersion then
--		moveCheck = require( "movechecker" )
--end



local editor = {}
editor.filename = ''
local editMode = "edit"

moveNum = 1
local maxMoveNum = 0
local moveColor = 1 -- 1 == w, 2 == b
local currMove = ''

local butnWt = display.contentWidth/8
local butnHt = display.contentHeight*2/24
if butnHt > butnWt then
	butnHt = butnWt
end
local baseY = display.contentHeight-butnHt

editor.screens = nil
local editScreen = nil
local editScreenBkgnd = nil
local numberbuttons = {}
local letterbuttons = {}
local piecebuttons = {}
local kingbuttons = {}
local movebuttons = {}
local doneButton
local bkspButton
editor.editDone = false

local moveDisplay
local moveListDisplay
local LEFT_PADDING = 10
local ROW_HEIGHT = 20
local MLD_Top = appOriginY + butnHt
local MLDisplayHeight = display.actualContentHeight - butnHt*7 

--print( MLD_Top + MLDisplayHeight )
--print( display.contentHeight - (butnHt*7) )
if MLD_Top + MLDisplayHeight > display.contentHeight - (butnHt*6) then
	MLDisplayHeight = display.contentHeight - (butnHt*6) - MLD_Top
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
					currMoveStr = currMoveStr .. string.rep( ' ', 14-string.len(currMoveStr) ) .. '(' .. moveList[num][2] .. ') '
				else
					currMoveStr = currMoveStr .. string.rep( ' ', 14-string.len(currMoveStr) ) .. moveList[num][2]
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
	local rowTitle = display.newText( row, FormatMove(row.index), 0, 0, native.systemFontBold, 16 )

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
	top = MLD_Top+3,
	width = display.actualContentWidth/2,
	height = MLDisplayHeight-1,
	hideBackground = true,
	topPadding = 5,
	onRowRender = onMoveListRowRender,
	onRowTouch = onMoveListRowTouch,
}
--print( display.contentHeight, display.topStatusBarContentHeight )

local function AddMove( fromFile )
		if  ( version < moveCheckVersion and currMove ~= '' ) then
		    --or moveCheck.CheckCurrMove( currMove, moveColor ) then
			
			if fromFile and moveColor == 1 then
				moveListDisplay:insertRow(
				{
					isCategory = false,
					rowHeight = ROW_HEIGHT,
					rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 0.5, 0, 0.2 } },
					lineColor = { 0.5, 0.5, 0.5, 0 }
				} )
			else
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
			end
			if moveColor == 1 then
				if not fromFile then
					moveList[moveNum][1] = currMove
				end
				moveColor = 2
			else
				if not fromFile then
					moveList[moveNum][2] = currMove
				end
				moveColor = 1
				moveNum = moveNum + 1
				if maxMoveNum < moveNum then
					maxMoveNum = moveNum
				end
			end
			if not fromFile then
				if moveNum <= maxMoveNum and 
				   moveList[moveNum] ~= nil and
				   moveList[moveNum][moveColor] ~= nil then
					currMove = moveList[moveNum][moveColor]
				else
					currMove = ''
				end
			end
			--print( moveNum, currMove, maxMoveNum )
			UpdateMoveDisplay()
			ChangeButtonColors()
			ScrollToRow( moveNum )
		end
end

editor.EditGame = function()
	moveNum = 1
	maxMoveNum = 0
	moveColor = 1 -- 1 == w, 2 == b
	currMove = ''
	transition.to( editScreen, { alpha=1, time = 400, transition = easing.outExpo } )
	moveListDisplay:deleteAllRows()
	while moveNum <= #moveList do
		currMove = moveList[moveNum][moveColor]
		--print( moveNum, moveColor, currMove )
		if currMove ~= nil and currMove ~= '' then
			AddMove( true )
		end
	end
	currMove = ''
	UpdateMoveDisplay()
	ChangeButtonColors()
end

function ChangeButtonColors()
	--print( 'change colors' .. moveColor )
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
	if moveColor == 1 then
		moveDisplay:setFillColor( 0.1,0.1,0.1 )
		moveDisplayBkgnd:setFillColor( 1, 1, 1 )
		bkspButton:setFillColor( 0, 0, 0, 0.2 )
	else
		moveDisplay:setFillColor( 1, 1, 1 )
		moveDisplayBkgnd:setFillColor( 0.1,0.1,0.1 )
		bkspButton:setFillColor( 1, 1, 1, 0.9 )
	end	
end

function EnableButtons( numbers, letters, pieces, kings )
	for i=1,#numberbuttons do
		numberbuttons[i].alpha = numbers[i]
	end
	for i=1,#letterbuttons do
		letterbuttons[i].alpha = letters[i]
	end
	for i=1,#piecebuttons do
		piecebuttons[i].alpha = pieces[i]
	end
	for i=1,#kingbuttons do
		kingbuttons[i].alpha = kings[i]
	end
end


-- Function to handle button events
local function handleButtonEvent( event )
	if ( "ended" == event.phase ) then
		--print( 'Button ' .. event.target:getLabel() .. ' was pressed and released' )
		if event.target.alpha == 1 then
			if currMove:len() < 8 then
				currMove = currMove .. event.target:getLabel()
			else
				moveDisplay:setFillColor( 1, 0, 0 )
			end
			UpdateMoveDisplay( currMove )
		end
	end    
end

local function Done( event )
	if editor.editDone == false then
	
		if string.find( editor.filename, '.pgn' ) == nil then
			editor.filename = editor.filename..'.pgn'
		end
		SaveGame( editor.filename )
		
		editor.filename = ''
		editor.editDone = true
		moveListDisplay:deleteAllRows()
		transition.to( editScreen, { alpha=0, time = 400, transition = easing.outQuad } )
	end
end

local function EnterMove( event )
	if ( "ended" == event.phase ) then
		AddMove( false )
	end
end

local function BkspMove( event )
	if ( "ended" == event.phase ) then
		if currMove:len() == 8 then
			if moveColor == 1 then
				moveDisplay:setFillColor( 0.1,0.1,0.1 )
			else
				moveDisplay:setFillColor( 1, 1, 1 )
			end	
		end
		if currMove == '0-0' or currMove == '0-0-0' then
			currMove = ''
		else
			currMove = string.sub( currMove, 1, string.len(currMove)-1)
		end
		UpdateMoveDisplay( currMove )
		ChangeButtonColors()
	end
end

local function PrevMove( event )
	if ( "ended" == event.phase ) then
		if moveNum > 1 then
			moveNum = moveNum - 1
			currMove = moveList[moveNum][1]
			moveColor = 1
			UpdateMoveDisplay( currMove )
			ChangeButtonColors()
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
			ChangeButtonColors()
			ScrollToRow( moveNum )
		end
		--print( moveNum, moveColor, maxMoveNum )
	end
end
 
--local move = { '','','<<','<','>','>>','','' }
local letters = { 'a','b','c','d','e','f','g','h' }
local pieces = { 'N','B','x','#','+','Q','R' }

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

-- Setup all Screens for Edit Mode
editor.screens = display.newGroup()

-- Setup the Edit Screen
editScreen = display.newGroup()
editor.screens:insert( editScreen )

-- Add controls to Edit Screen
editScreenBkgnd = display.newRect( 0, 0, display.actualContentWidth, display.actualContentHeight, 18 )
editScreenBkgnd:setFillColor( wbGradient )
editScreenBkgnd.anchorX = 0
editScreenBkgnd.anchorY = 0
editScreen:insert( editScreenBkgnd )
--display.contentCenterX - display.actualContentWidth/4
moveDisplayBkgnd = display.newRect( display.contentCenterX - display.actualContentWidth/4 + 15, baseY - butnHt*5+5, display.contentWidth / 2.0-30, butnHt/1.25, 18 )
moveDisplayBkgnd:setFillColor( 0.75, 0.75, 0.75 )
moveDisplayBkgnd.anchorX = 0
moveDisplayBkgnd.anchorY = 0
editScreen:insert( moveDisplayBkgnd )

local moveDisplayOptions = 
{
    --parent = textGroup,
    text = "",     
    x = display.contentCenterX - display.actualContentWidth/4 + 5, --display.contentWidth / 2.0,
    y = baseY - butnHt*5 + 5,
    width = display.contentWidth / 3.0,
	height = butnHt/1.25,
    font = native.systemFontBold,   
    fontSize = 18,
    align = "center"  --new alignment parameter
}
moveDisplay = display.newText( moveDisplayOptions )
editScreen:insert( moveDisplay )
	
local size = butnHt/3
bkspButton = widget.newButton
{			
	label = '   x',
	emboss = false,
	width = size,
	height = size,
	labelColor = { default={ 0, 0, 0 }, over={ 1, 1, 1 } },
	--properties for a polygon button...
	x = display.actualContentWidth/4 + display.contentWidth / 3.0 + 10,
	y = baseY - butnHt*4.45, --display.contentHeight - size*1.5,
	shape="polygon",
	vertices = { 
		0, size*.75, 
		size, 0, 
		size*2.25, 0, 
		size*2.25, size*1.5,
		size, size*1.5,
	},
	fillColor = { default={ 0, 0, 0, 0.2 }, over={ 0, 0, 0, 0.5 } },
	strokeColor = { default={ 0, 0, 0, 0.5 }, over={ 0, 0, 0, 0.2 } },
	strokeWidth = 2,
	fontSize = 14,
	labelYOffset = -1, 
	onEvent = BkspMove,
}
editScreen:insert( bkspButton )

buttonInfo.onEvent = handleButtonEvent
buttonInfo.height = butnHt

-- Create a background to go behind our tableView
local background = display.newImage( editScreen, "notepad.png", display.contentCenterX - display.actualContentWidth/4, MLD_Top+3, true )
background.height = MLDisplayHeight-1
background.width = display.actualContentWidth/2
background.anchorX = 0
background.anchorY = 0

editScreen:insert( moveListDisplay )

-- Setup the keyboard
buttonInfo.height = butnHt

-- Number and Letter buttons
for i=1,8 do
	buttonInfo.left = (i-1) * butnWt
	
	-- Number Buttons
	buttonInfo.top = baseY-butnHt
	buttonInfo.label = i
	numberbuttons[i] = widget.newButton(buttonInfo)
	editScreen:insert( numberbuttons[i] )

	-- Letter Buttons
	buttonInfo.top = baseY - (2*butnHt)
	buttonInfo.label = letters[i]
	letterbuttons[i] = widget.newButton(buttonInfo)
	editScreen:insert( letterbuttons[i] )
end

for i=1,7 do
	-- Piece Buttons
	buttonInfo.left = (i-1) * butnWt
	buttonInfo.top = baseY - (3*butnHt)
	buttonInfo.label = pieces[i]
	if pieces[i] == '#' then
		buttonInfo.defaultFile = "rtbuttond.png"
		buttonInfo.overFile = "rtbuttono.png"	
		buttonInfo.width = butnWt*2
	else
		if i > 4 then
			buttonInfo.left = i * butnWt
		end
		buttonInfo.defaultFile = "sqbuttond.png"
		buttonInfo.overFile = "sqbuttono.png"	
		buttonInfo.width = butnWt
	end
	piecebuttons[#piecebuttons+1] = widget.newButton(buttonInfo)
	editScreen:insert( piecebuttons[#piecebuttons] )
end

buttonInfo.defaultFile = "sqbuttond.png"
buttonInfo.overFile = "sqbuttono.png"	
buttonInfo.width = butnWt

-- MoveButtons
	buttonInfo.top = baseY

	buttonInfo.left = 2 * butnWt
	buttonInfo.label = '<<'
	buttonInfo.onEvent = PrevMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( movebuttons[#movebuttons] )

	buttonInfo.left = 5 * butnWt
	buttonInfo.label = '>>'
	buttonInfo.onEvent = NextMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( movebuttons[#movebuttons] )
	
--KingButtons
	buttonInfo.defaultFile = "rtbuttond.png"
	buttonInfo.overFile = "rtbuttono.png"	
	buttonInfo.width = butnWt*2
	
	buttonInfo.left = 3 * butnWt
	buttonInfo.label = 'Enter'
	buttonInfo.onEvent = EnterMove
	movebuttons[#movebuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( movebuttons[#movebuttons] )

	buttonInfo.top = baseY - butnHt*4
	
	buttonInfo.onEvent = handleButtonEvent
	
	buttonInfo.label = '0-0'
	buttonInfo.left = butnWt
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( kingbuttons[#kingbuttons] )

	buttonInfo.label = 'K'
	buttonInfo.left = butnWt * 3
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( kingbuttons[#kingbuttons] )
	
	buttonInfo.label = '0-0-0'
	buttonInfo.left = butnWt * 5
	kingbuttons[#kingbuttons+1] = widget.newButton(buttonInfo)	
	editScreen:insert( kingbuttons[#kingbuttons] )
	
--Done Button
	buttonInfo.top = appOriginY
	buttonInfo.label = 'Save'
	buttonInfo.left = butnWt * 3
	buttonInfo.onEvent = Done
	doneButton = widget.newButton(buttonInfo)	
	editScreen:insert( doneButton )


function UpdateMoveDisplay()
	moveDisplay.text = currMove
	--moveDisplay.x = display.contentWidth / 2.0
	moveDisplay.y = baseY - butnHt*4.5 + 5
	--moveDisplay.align = 'center'
	moveDisplay.anchorX = 0
	--moveDisplay.anchorY = 0
--	if version >= moveCheckVersion then
--		EnableButtons( moveCheck.GetValidButtonList( currMove, moveColor ) )
--	end
end

local gameedithelptext = [[
This screen shows you the list of moves that were made in the game. It also displays the move that is currently being added or edited.

The screen has a keyboard that you can use to enter or edit the moves made in the game.
The keyboard and current move display change color to indicate which side would move next.

The keyboard has the following keys:

K; King

Q: Queen

R: Rook

B: Bishop

N: Knight

0-0: King side castling

x: Capture

+: Check

#: Checkmate

0-0-0: Queen side castling

a-h: used to specify pawns
a-h and 1-8 are used to indicate a start or ending square of a move.

<<: Go to previous move

>>: Go to next move

Enter: Enter the move into the move list

<x: Backspace, clear the last entered key in the move currently being edited

Save: Save the current state of the game and go back to the list of games


]]

editor.GetHelpInfo = function()
	return "Game Edit Help" , gameedithelptext
end

editor.handleAndroidBackButton = function()
	Done()
	return true
end

transition.to( editor.screens, { x = display.contentWidth * 1.5, alpha=0, time = 0, transition = easing.outQuad } )
return editor