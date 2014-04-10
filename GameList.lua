local widget = require( "widget" )
local lfs = require "lfs"

local gamelist = {}
gamelist.files = {}
gamelist.selectedFile = ''
local newFile = false
local isSimulator = "simulator" == system.getInfo("environment")
labelInfo = {}
textField = {}


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

--Create a group to hold our widgets & images
gamelist.widgetGroup = display.newGroup()

local titleGradient = {
	type = 'gradient',
	color1 = { 189/255, 203/255, 220/255, 255/255 }, 
	color2 = { 89/255, 116/255, 152/255, 255/255 },
	direction = "down"
}

-- Create toolbar to go at the top of the screen
local titleBar = display.newRect( halfW, 0, display.contentWidth, 32 )
titleBar:setFillColor( titleGradient )
titleBar.y = display.screenOriginY + titleBar.contentHeight * 0.5

-- create embossed text to go on toolbar
local titleText = display.newEmbossedText( "My Games", halfW, titleBar.y, native.systemFontBold, 20 )

-- create a shadow underneath the titlebar (for a nice touch)
local shadow = display.newImage( "shadow.png" )
shadow.anchorX = 0.0	-- TopLeft anchor points
shadow.anchorY = 0.0
shadow.x, shadow.y = 0, titleBar.y + titleBar.contentHeight * 0.5
shadow.xScale = display.contentWidth / shadow.contentWidth
shadow.alpha = 0.45

--Text to show which item we selected
local itemSelected = display.newText( "You selected item ", 0, 0, native.systemFontBold, 28 )
itemSelected:setFillColor( 0 )
itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
itemSelected.y = display.contentCenterY
gamelist.widgetGroup:insert( itemSelected )

-- Forward reference for our edit button & tableview
local list, editButton, backButton

gamelist.TransitionToList = function()
	--The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
	transition.to( list, { x = list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( newButton, {alpha = 1, time = 400, transition = easing.outExpo } )
	transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( editButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
        for hiderow=1,#textField do
            transition.to( textField[hiderow], { alpha = 0, time = 400, transition = easing.outQuad } )
            transition.to( labelInfo[hiderow], { alpha = 0, time = 400, transition = easing.outQuad } )
        end
        
end

gamelist.TransitionToItem = function()
	--Transition out the list, transition in the item selected text and the edit button

	-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
	transition.to( list, { x = - list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
	transition.to( newButton, { alpha = 0, time = 400, transition = easing.outExpo } )
	--transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
	transition.to( editButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
	gamelist.LoadInfo()
        for hiderow=1,#textField do
            transition.to( textField[hiderow], { alpha = 1, time = 400, transition = easing.outQuad } )
            transition.to( labelInfo[hiderow], { alpha = 1, time = 400, transition = easing.outQuad } )
        end
end

gamelist.DisplayInfo = function( inforow, headingtext, infotext )
    if isSimulator then
        -- Simulator (simulate the textField area)
        if infotext == nil or infotext == '' then
            infotext = 'Not Specified'
        end
        print( inforow )
        if textField[inforow] == nil then 
            textField[inforow] = display.newText( infotext, 0, 0, "Arial", 24 )
        end
        textField[inforow]:setFillColor( 0.2, .2, .2 )
        textField[inforow].text = infotext
        textField[inforow].x = display.contentWidth/2
        textField[inforow].y = (titleBar.contentHeight * 2.0)+(inforow*(display.contentHeight/20))
        textField[inforow].anchorY = 0
--      print( infotext )
    else
        local tHeight = 30
        if isAndroid then tHeight = 40 end		-- adjust for Android
        textField = native.newTextField( 15, 80, 280, tHeight )
        --textField:addEventListener( "userInput", fieldHandler )
    end	    
    
    if labelInfo[inforow] == nil then
        labelInfo[inforow] = display.newText( headingtext, 0,0, "Arial", 24 )
    end
    labelInfo[inforow]:setFillColor( 0.2, .2, .2 )
    labelInfo[inforow].text = headingtext
    labelInfo[inforow].x = 10
    labelInfo[inforow].y = (titleBar.contentHeight * 2.0)+(inforow*(display.contentHeight/20))
    labelInfo[inforow].anchorX = 0    
    labelInfo[inforow].anchorY = 0

end

gamelist.LoadInfo = function()
	local filePath = system.pathForFile( itemSelected.text, system.DocumentsDirectory )
	print( 'InLoadInfo:  ' .. filePath )
	file = io.open( filePath, "r" )
	if file then
                local inforow = 1
                gamelist.DisplayInfo( inforow, 'Game',  itemSelected.text )
                inforow = inforow + 1
		print( "File Opened" )
		for line in file:lines() do
			if line:find('^%[.*%]$' ) then
				local s,e, heading, info = line:find( '^%[([^"]*)"([^"]*)"%]$' )
				--print( heading, info )
                                gamelist.DisplayInfo( inforow, heading, info )
                                inforow = inforow + 1
			end	
		end
                io.close( file )
	end
end

-- Handle row rendering
local function onRowRender( event )
	local phase = event.phase
	local row = event.row
	
	-- in graphics 2.0, the group contentWidth / contentHeight are initially 0, and expand once elements are inserted into the group.
	-- in order to use contentHeight properly, we cache the variable before inserting objects into the group

	local groupContentHeight = row.contentHeight

	local rowTitle = display.newText( row, gamelist.files[row.index], 0, 0, native.systemFontBold, 24 )

	-- in Graphics 2.0, the row.x is the center of the row, no longer the top left.
	rowTitle.x = LEFT_PADDING

	-- we also set the anchorX of the text to 0, so the object is x-anchored at the left
	rowTitle.anchorX = 0

	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	local rowArrow = display.newImage( row, "rowArrow.png", false )

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
		itemSelected.text = gamelist.files[row.index]
		newFile = false
		gamelist.TransitionToItem()
	end
end

-- Create a tableView
list = widget.newTableView
{
	top = 38,
	width = display.contentWidth, 
	height = display.contentHeight - 38 - display.topStatusBarContentHeight,
	maskFile = "mask-320x448.png",
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
}

--Insert widgets/images into a group
gamelist.widgetGroup:insert( list )

gamelist.widgetGroup:insert( titleBar )
gamelist.widgetGroup:insert( titleText )
gamelist.widgetGroup:insert( shadow )

--Handle the edit button release event
local function onNewRelease()
		-- Update the item selected text
		newFile = true
		itemSelected.text = 'Game' .. #gamelist.files + 1
		gamelist.TransitionToItem()
end

--Handle the edit button release event
local function onEditRelease()
	--Transition in the list, transition out the item selected text and the edit button
	if newFile == true then
		gamelist.files[#gamelist.files + 1] = gamelist.selectedFile
		list:insertRow({ rowHeight = 40 })
		newFile = false
	end
	gamelist.selectedFile = itemSelected.text
end

--Handle the edit button release event
local function onBackRelease()
	--Transition in the list, transition out the item selected text and the edit button
	itemSelected.text = '' 
	gamelist.FindFiles()
	gamelist.TransitionToList()
end

--Create the edit button
newButton = widget.newButton
{
	width = 32,
	height = 32,
	label = "+", 
	labelYOffset = - 1,
	onRelease = onNewRelease
}
newButton.alpha = 1
newButton.x = display.contentWidth - 80
newButton.y = display.screenOriginY + titleBar.contentHeight * 0.5
newButton:setFillColor(1,1,1)
gamelist.widgetGroup:insert( newButton )

--Create the edit button
editButton = widget.newButton
{
	width = 298,
	height = 56,
	label = "Edit", 
	labelYOffset = - 1,
	onRelease = onEditRelease
}
editButton.alpha = 0
editButton.x = display.contentWidth * 0.9
editButton.y = display.contentHeight - editButton.contentHeight
gamelist.widgetGroup:insert( editButton )

backButton = widget.newButton
{
	width = 298,
	height = 56,
	label = "Back", 
	labelYOffset = - 1,
	onRelease = onBackRelease
}
backButton.alpha = 0
backButton.x = display.contentWidth * 0.1
print( backButton.x )
backButton.y = display.contentHeight - backButton.contentHeight
gamelist.widgetGroup:insert( backButton )

--Create the edit button
emailButton = widget.newButton
{
	width = 298,
	height = 56,
	label = "Email", 
	labelYOffset = - 1,
	onRelease = onEmailRelease
}
emailButton.alpha = 0
emailButton.x = display.contentWidth * 0.5
emailButton.y = display.contentHeight - editButton.contentHeight
gamelist.widgetGroup:insert( emailButton )



gamelist.FindFiles = function()
	local doc_path = system.pathForFile( "", system.DocumentsDirectory )
	for file=1,#gamelist.files do
		gamelist.files[file] = nil
	end
	gamelist.files = {}
	list:deleteAllRows()
	for file in lfs.dir(doc_path) do
		--file is the current file or directory name
		print( "Found file: " .. file )
		if file:find( '.pgn' ) then
			gamelist.files[#gamelist.files + 1] = file
			list:insertRow({ rowHeight = 40 })
		end
	end
end

gamelist.FindFiles()

return gamelist