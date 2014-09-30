local widget = require( "widget" )
local lfs = require( "lfs" )

local gamelist = {}
gamelist.files = {}
gamelist.selectedFile = ''
gamelist.screens = nil

local newFile = false
labelInfo = {}
infoButtons = {}
local lastFileIndex=1
local mode = "gamelist"
-- 
-- Abstract: List View sample app
--  
-- Version: 2.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2013 Corona Labs Inc. All Rights Reserved.
--
-- Demonstrates how to create a list view using the widget's Table View Library.
-- A list view is a collection of content organized in rows that the user
-- can scroll up or down on touch. Tapping on each row can execute a 
-- custom function.
--
-- Supports Graphics 2.0
------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar ) 

-- Import the widget library
local widget = require( "widget" )

-- create a constant for the left spacing of the row content
local LEFT_PADDING = 10
local halfW = display.contentCenterX
local halfH = display.contentCenterY

--Set the background to white
display.setDefault( "background", 255/255 )

gamelist.screens = display.newGroup()

--Create a group to hold widgets & images for the game list
listScreen = display.newGroup()
gamelist.screens:insert( listScreen )

--Create a group to hold widgets & images for the game info
infoScreen = display.newGroup()
gamelist.screens:insert( infoScreen )

local titleGradient = {
	type = 'gradient',
	color1 = { 189/255, 203/255, 220/255, 255/255 }, 
	color2 = { 89/255, 116/255, 152/255, 255/255 },
	direction = "down"
}

-- Create toolbar to go at the top of the screen
local titleBar = display.newRect( halfW, 0, display.contentWidth, 32 )
titleBar:setFillColor( titleGradient )
titleBar.y = appOriginY + titleBar.contentHeight * 0.5
local topUsableY = appOriginY + titleBar.contentHeight

-- create embossed text to go on toolbar
local titleText = display.newEmbossedText( "My Games", halfW, titleBar.y, native.systemFontBold, 20 )

-- create a shadow underneath the titlebar (for a nice touch)
local shadow = display.newImage( "shadow.png" )
shadow.anchorX = 0.0	-- TopLeft anchor points
shadow.anchorY = 0.0
shadow.x, shadow.y = 0, titleBar.y + titleBar.contentHeight * 0.5
shadow.xScale = display.contentWidth / shadow.contentWidth
shadow.alpha = 0.45

local itemSelected = ''

-- Forward reference for our edit button & tableview
local list, editButton, backButton

gamelist.RemoveInfo = function()
	for hiderow=1,#infoButtons do
		if infoButtons[hiderow].heading ~= 'Game' then
			if( infoButtons[hiderow].infodisplay:getLabel() == 'Not Specified' ) then
				gameInfo[infoButtons[hiderow].heading] = ''
			else
				gameInfo[infoButtons[hiderow].heading] = infoButtons[hiderow].infodisplay:getLabel()
			end
		end
		transition.to( labelInfo[hiderow], { alpha = 0, time = 400, transition = easing.outQuad } )
		transition.to( infoButtons[hiderow].infodisplay, { alpha = 0, time = 400, transition = easing.outQuad } )
		if( infoButtons[hiderow].infoinput ) then
			infoButtons[hiderow].infoinput:removeSelf()
			infoButtons[hiderow].infoinput = nil
		end
	end
	mode = "gamelist"
end

gamelist.TransitionToList = function()
	--The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
	transition.to( list, { x = list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( newGameButton, {alpha = 1, time = 400, transition = easing.outExpo } )
	--transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( editButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	for hiderow=1,#infoButtons do
		transition.to( infoButtons[hiderow].infodisplay, { alpha = 0, time = 400, transition = easing.outQuad } )
		transition.to( labelInfo[hiderow], { alpha = 0, time = 400, transition = easing.outQuad } )
		if( infoButtons[hiderow].infoinput ) then
			infoButtons[hiderow].infoinput:removeSelf()
			infoButtons[hiderow].infoinput = nil
		end
	end
	mode = "gamelist"
end

gamelist.TransitionToItem = function()
	--Transition out the list, transition in the item selected text and the edit button

	-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
	transition.to( list, { x = - list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( newGameButton, { alpha = 0, time = 400, transition = easing.outExpo } )
	--transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
	transition.to( editButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	gamelist.LoadInfo()
	for hiderow=1,#infoButtons do
		transition.to( infoButtons[hiderow].infodisplay, { alpha = 1, time = 400, transition = easing.outQuad } )
		transition.to( labelInfo[hiderow], { alpha = 1, time = 400, transition = easing.outQuad } )
	end
	mode = "gameinfo"
end

-------------------------------------------
-- Handle the textField keyboard input
--
function NewInfoButton( iX, iY, iWidth, iHeight, infoText, headingText )
	local infoButton = {}
	infoButton.infoinput = nil
	infoButton.infodisplay = nil
	infoButton.heading = headingText
	
	infoButton.InfoEntry = function( event )

		--native.showAlert( 'Phase', event.phase, { "OK" }, nil )

		if  ( "ended" == event.phase ) or ( "submitted" == event.phase ) then
			--native.showAlert( infoButton.heading, infoButton.infoinput.text, { "OK" }, nil )
			-- This event is called when the user stops editing a field: for example, when they touch a different field
			-- This event occurs when the user presses the "return" key (if available) on the onscreen keyboard
			if( infoButton.infoinput.text == '' ) then
				infoButton.infodisplay:setLabel( 'Not Specified' )
				--gameInfo[infoButton.heading] = ''
			else
				infoButton.infodisplay:setLabel( infoButton.infoinput.text )
				--gameInfo[infoButton.heading] = infoButton.infoinput.text
			end
			


			-- Hide keyboard
			native.setKeyboardFocus( nil )
			--print(' Now removing infoinput' )
			infoButton.infoinput:removeSelf()
			infoButton.infoinput = nil
		end
	end
	
	local onInfoButtonRelease = function()

		if isSimulator then
			infoButton.infodisplay:setLabel( 'Changed' )
		else
			local inputFontSize = 14
			if ( isAndroid ) then
				inputFontSize = inputFontSize - 4
			end

			infoButton.infoinput = native.newTextField( infoButton.infodisplay.x, infoButton.infodisplay.y, infoButton.infodisplay.width*0.9, infoButton.infodisplay.height )
			infoButton.infoinput.anchorX = 0
			infoButton.infoinput.anchorY = 0
			infoButton.infoinput.font = native.newFont( native.systemFontBold, inputFontSize )		
			if infoButton.infodisplay:getLabel() ~= 'Not Specified' then
				infoButton.infoinput.text = infoButton.infodisplay:getLabel()
			end
			native.setKeyboardFocus( infoButton.infoinput )
			--local handlerName = headingtext .. 'Handler'
			infoButton.infoinput:addEventListener( "userInput", infoButton.InfoEntry )
		end
	end
	
	infoButton.infodisplay = widget.newButton
	{
		x = iX,
		y = iY,
		width = iWidth,
		height = iHeight,
		label = infoText, 
		labelYOffset = - 1,
		onRelease = onInfoButtonRelease
	}
	infoButton.infodisplay.alpha = 1
	--infoButton.x = x
	--infoButton.y = y
	infoButton.infodisplay.anchorX = 0
	infoButton.infodisplay.anchorY = 0
	return infoButton
end

gamelist.DisplayInfo = function( inforow, headingtext, infotext )
	-- Simulator (simulate the textField area)
	if infotext == nil or infotext == '' then
		infotext = 'Not Specified'
	end

	height = 30
	if( isAndroid ) then
		height = 40
	end
		
	--print( inforow, infotext )
	if infoButtons[inforow] == nil then 
		infoButtons[inforow] = {}
		infoButtons[inforow] = NewInfoButton(  display.contentWidth/2, 
								    topUsableY + (inforow*(display.contentHeight/20)),
								    display.contentWidth/2, 
								    height, infotext, headingtext ) 
		infoScreen:insert( infoButtons[inforow].infodisplay )
	end
	infoButtons[inforow].infodisplay:setLabel( infotext )
		
	if labelInfo[inforow] == nil then
		labelInfo[inforow] = display.newText( headingtext, 0,0, display.contentWidth/2.1, height, "Arial", 14 )
		labelInfo[inforow]:setFillColor( 0.2, .2, .2 )
		labelInfo[inforow].x = 10
		labelInfo[inforow].y = topUsableY + (inforow*(display.contentHeight/20))
		labelInfo[inforow].anchorX = 0    
		labelInfo[inforow].anchorY = 0
		infoScreen:insert( labelInfo[inforow] )
	end
	labelInfo[inforow].text = headingtext
end

gamelist.LoadInfo = function()
	LoadGame( itemSelected )
	local inforow = 1
	gamelist.DisplayInfo( inforow, 'Game',  itemSelected )
	inforow = inforow + 1
	for heading, info in pairs(gameInfo) do
		gamelist.DisplayInfo( inforow, heading, info )
		inforow = inforow + 1
	end
end

-- Handle row rendering
local function onRowRender( event )
	local phase = event.phase
	local row = event.row
	
	-- in graphics 2.0, the group contentWidth / contentHeight are initially 0, and expand once elements are inserted into the group.
	-- in order to use contentHeight properly, we cache the variable before inserting objects into the group

	local groupContentHeight = row.contentHeight

	local rowTitle = display.newText( row, gamelist.files[row.index], 0, 0, native.systemFontBold, 16 )

	-- in Graphics 2.0, the row.x is the center of the row, no longer the top left.
	rowTitle.x = LEFT_PADDING

	-- we also set the anchorX of the text to 0, so the object is x-anchored at the left
	rowTitle.anchorX = 0

	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	local rowArrow = display.newImage( row, "rowarrow.png", false )

	rowArrow.x = row.contentWidth - LEFT_PADDING

	-- we set the image anchorX to 1, so the object is x-anchored at the right
	rowArrow.anchorX = 1
	rowArrow.y = groupContentHeight * 0.5
end

-- Handle row touch events
local function onRowTouch( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		-- Update the item selected text
		itemSelected = gamelist.files[row.index]
		newFile = false
		gamelist.TransitionToItem()
	end
end

-- Create a tableView
list = widget.newTableView
{
	top = topUsableY,
	width = display.contentWidth, 
	height = display.contentHeight - topUsableY,
	--maskFile = "background.png",
	hideBackground = true,
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
}
--print( list.height )

-- Create a background to go behind our tableView
local bkgndH = 500
local background = display.newImageRect( listScreen, "background.png", 320, bkgndH )
background.anchorX = 0
background.anchorY = 0
background.y = display.contentHeight - bkgndH + appOriginY

--Insert widgets/images into a group
listScreen:insert( list )

listScreen:insert( titleBar )
listScreen:insert( titleText )
listScreen:insert( shadow )

--Handle the edit button release event
local function onNewRelease()
		-- Update the item selected text
		newFile = true
		itemSelected = 'Game' .. lastFileIndex .. '.pgn'
		lastFileIndex = lastFileIndex + 1
		gamelist.TransitionToItem()
end

--Handle the edit button release event
local function onEditRelease()
	--Transition in the list, transition out the item selected text and the edit button
	--print( 'INFO DISPLAY' )
	for hiderow=1,#infoButtons do
		if infoButtons[hiderow].heading ~= 'Game' then
			--print( infoButtons[hiderow].heading, infoButtons[hiderow].infodisplay:getLabel() )
			if infoButtons[hiderow].infodisplay:getLabel() == 'Not Specified' then
				gameInfo[infoButtons[hiderow].heading] = ''
			else
				gameInfo[infoButtons[hiderow].heading] = infoButtons[hiderow].infodisplay:getLabel()
			end
		end
	end
	if newFile == true then
		gamelist.files[#gamelist.files + 1] = gamelist.selectedFile
		list:insertRow({ rowHeight = 40,  rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 1, 1, 0.2 } }})
		newFile = false
	end
	gamelist.selectedFile = itemSelected
end

--Handle the edit button release event
local function onBackRelease()
	--Transition in the list, transition out the item selected text and the edit button
	--print( 'INFO DISPLAY' )
	for hiderow=1,#infoButtons do
		if infoButtons[hiderow].heading ~= 'Game' then
			--print( infoButtons[hiderow].heading, infoButtons[hiderow].infodisplay:getLabel() )
			if infoButtons[hiderow].infodisplay:getLabel() == 'Not Specified' then
				gameInfo[infoButtons[hiderow].heading] = ''
			else
				gameInfo[infoButtons[hiderow].heading] = infoButtons[hiderow].infodisplay:getLabel()
			end
		end
	end
--~ 	print( 'GAME INFO' )
--~ 	for heading, info in pairs(gameInfo) do
--~ 		print( heading, info )
--~ 	end	
	SaveGame( itemSelected )
	itemSelected = '' 
	gamelist.FindFiles()
	gamelist.TransitionToList()
end

local buttonHeight = 40

--Create the New Game button
newGameButton = widget.newButton
{
	width = display.contentWidth / 2,
	height = buttonHeight,
	label = "New Game", 
	labelYOffset = - 1,
	onRelease = onNewRelease,
}
newGameButton.alpha = 1
newGameButton.x = display.contentWidth * 0.5
newGameButton.y = display.contentHeight - newGameButton.contentHeight
listScreen:insert( newGameButton )

--Create the edit button
editButton = widget.newButton
{
	width = display.contentWidth/3,
	height = buttonHeight,
	label = "Edit", 
	labelYOffset = - 1,
	onRelease = onEditRelease
}
editButton.alpha = 0
editButton.x = display.contentWidth * 0.668
editButton.y = display.contentHeight - editButton.contentHeight
editButton.anchorX = 0
infoScreen:insert( editButton )

backButton = widget.newButton
{
	width = display.contentWidth/3,
	height = buttonHeight,
	label = "Back", 
	labelYOffset = - 1,
	onRelease = onBackRelease
}
backButton.alpha = 0
backButton.x = 1
backButton.anchorX = 0
backButton.y = display.contentHeight - backButton.contentHeight
infoScreen:insert( backButton )

local function onEmailRelease( event )
	-- compose an HTML email with two attachments
	local options =
	{
	   to = { "sandeep.kharkar@gmail.com" },
	   --cc = { "john.smith@somewhere.com", "jane.smith@somewhere.com" },
	   subject = gamelist.selectedFile,
	   isBodyHtml = false,
	   --body = "<html><body>I scored over <b>9000</b>!!! Can you do better?</body></html>",
	   body = GetMoveListPGN(),
--	   attachment =
--	   {
--		  { baseDir=system.ResourceDirectory, filename="email.png", type="image" },
--		  { baseDir=system.ResourceDirectory, filename="coronalogo.png", type="image" },
--	   },
	}
	local result = native.showPopup("mail", options)
	
	if not result then
		print( "Mail Not supported/setup on this device" )
		native.showAlert( "Alert!",
		"Mail not supported/setup on this device.", { "OK" }
	);
	end
	-- NOTE: options table (and all child properties) are optional
end

--Create the Email button
emailButton = widget.newButton
{
	width = display.contentWidth/3,
	height = buttonHeight,
	label = "Email", 
	labelYOffset = - 1,
	onRelease = onEmailRelease
}
emailButton.alpha = 0
emailButton.anchorX = 0
emailButton.x = display.contentWidth * 0.334
emailButton.y = display.contentHeight - emailButton.contentHeight
infoScreen:insert( emailButton )

gamelist.FindFiles = function()
	local doc_path = system.pathForFile( "", system.DocumentsDirectory )
	for file=1,#gamelist.files do
		gamelist.files[file] = nil
	end
	gamelist.files = {}
	list:deleteAllRows()
	for file in lfs.dir(doc_path) do
		--file is the current file or directory name
		--print( "Found file: " .. file )
		if file:find( '.pgn' ) then
			gamelist.files[#gamelist.files + 1] = file
			s,e, index = file:find('Game(%d+).pgn$' )
			if index ~= nil and tonumber( index ) >= lastFileIndex then
				lastFileIndex = tonumber( index ) + 1
			end
			list:insertRow({ rowHeight = 40,  rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 1, 1, 0.2 } }})
		end
	end
	--print( lastFileIndex )
end

local gamelisthelptext = [[
This screen lists the current games that you have saved. Here, you can choose to add a new game or edit a current game. Scroll up and down by swiping up or down on your phone.

To add a new game use the "New Game" button. Games are named automatically and sequentially and cannot be renamed at this time.

To edit a game that you have saved touch the row on which the game is listed. This will take you to the Game Information screen.'
]]


local gameinfohelptext = [[
This screen shows you information about the selected game. 

From this screen you can choose to edit the Move List of the game by selecting the "Edit" button.

You can send a copy of the PGN file for this game using the "Email" button. You need an email account and a default email app to do this. Your phone also needs to have an active internet connection (wireless or cellular).

On this screen you can also edit information about the game. To edit any of the unlocked information select the current value of that field and type in the new information. The following information is stored for each game in addition to moves that were made in the game:

Game:  
Name of the game file stored on your phone. This information locked and cannot be changed.

Source:  
Specifies the program that generated the chess game. This information is locked and cannot be changed and is set to "ChessNotes"

Event: 
Name of the tournament where this game was played. This information is optional. For Example: Utah Elementary Scholastic Championship

Site:  
Location where the tournament was played. This information is optional. For Example: University of Utah

Date:  
The date on which the game was played. The date is expected in the YYYY.MM.DD format. This information is optional. For Example: 2014.03.05

Round:  
The round number of this game. This is relevant in a multi-round tournament. For Example: 3

White:  
Name of the player that was playing White pieces. For Example: Vishwanathan Anand

Black:  
Name of the player that was playing Black pieces. For Example: Magnus Carlson

Result: 
Specifes the result of the game. It can be one of three values. 1-0, 0-1, 1/2-1/2 indicating in order - White won, Black won, Draw.

WhiteElo:  
Rating of the player playing White pieces. This is a number between 100 - 2900. For Example: 1400

BlackElo:  
Rating of the player playing Black pieces. This is a number between 100 - 2900. For Example: 1400
]]

gamelist.GetHelpInfo = function()
	if mode == 'gamelist' then
		return "Game List Help" , gamelisthelptext
	end
	return "Game Info Help" , gameinfohelptext
end

gamelist.FindFiles()

return gamelist