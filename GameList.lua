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
local out = false
local editButton = nil
local emailButton = nil
local backButton = nil
local buttonHeight = 40

-- Image sheet options and declaration
local options = {
    width = 50,
    height = 50,
    numFrames = 2,
    sheetContentWidth = 100,
    sheetContentHeight = 50
}
local whiteWinSheet = graphics.newImageSheet( "WhiteWin.png", options )
local blackWinSheet = graphics.newImageSheet( "BlackWin.png", options )
local drawSheet = graphics.newImageSheet( "Draw.png", options )

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

local titleGradient = {
	type = 'gradient',
	color1 = { 189/255, 203/255, 220/255, 255/255 }, 
	color2 = { 89/255, 116/255, 152/255, 255/255 },
	direction = "down"
}

-- Create toolbar to go at the top of the screen
local titleBar = display.newRect( 0, 0, display.contentWidth-40, titleBarHeight )
titleBar:setFillColor( titleGradient )
titleBar.anchorX = 0
titleBar.y = appOriginY + titleBarHeight * 0.5
local topUsableY = appOriginY + titleBarHeight

-- create embossed text to go on toolbar
local titleText = display.newEmbossedText( "My Games", (display.contentWidth-40)/2, titleBar.y, native.systemFontBold, 20 )

-- create a shadow underneath the titlebar (for a nice touch)
local shadow = display.newImage( "shadow.png" )
shadow.anchorX = 0.0	-- TopLeft anchor points
shadow.anchorY = 0.0
shadow.x, shadow.y = 0, titleBar.y + titleBarHeight * 0.5
shadow.xScale = ( display.contentWidth - 40 ) / shadow.contentWidth
shadow.alpha = 0.45

gamelist.screens:insert( titleBar )
gamelist.screens:insert( titleText )
gamelist.screens:insert( shadow )

--~ -- Create a background to go behind our tableView
--~ local bkgndH = 500
--~ local background = display.newImageRect( "background.png", 320, bkgndH )
--~ background.anchorX = 0
--~ background.anchorY = 0
--~ background.y = display.contentHeight - bkgndH + appOriginY
--~ gamelist.screens:insert( background )

--Create a group to hold widgets & images for the game list
listScreen = display.newGroup()
gamelist.screens:insert( listScreen )

--Create a group to hold widgets & images for the game info
infoScreen = display.newGroup()
gamelist.screens:insert( infoScreen )

local itemSelected = ''

gamelist.TransitionToList = function()

	transition.to( infoScreen, { alpha=0, time = 400, transition = easing.outQuad } )
	transition.to( listScreen, { alpha=1, time = 400, transition = easing.outExpo } )

--~ 	--The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
--~ 	transition.to( list, { x = list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
--~ 	transition.to( newGameButton, {alpha = 1, time = 400, transition = easing.outExpo } )
--~ 	--transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
--~ 	transition.to( editButton, { alpha = 0, time = 400, transition = easing.outQuad } )
--~ 	transition.to( emailButton, { alpha = 0, time = 400, transition = easing.outQuad } )
--~ 	transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	for hiderow=1,#infoButtons do
--~ 		transition.to( infoButtons[hiderow].infodisplay, { alpha = 0, time = 400, transition = easing.outQuad } )
--~ 		transition.to( labelInfo[hiderow], { alpha = 0, time = 400, transition = easing.outQuad } )
		if( infoButtons[hiderow].infoinput ) then
			infoButtons[hiderow].infoinput:removeSelf()
			infoButtons[hiderow].infoinput = nil
		end
	end
	mode = "gamelist"
end

gamelist.TransitionToItem = function()
	--Transition out the list, transition in the item selected text and the edit button
	gamelist.LoadInfo()
	transition.to( infoScreen, { alpha=1, time = 400, transition = easing.outExpo } )
	transition.to( listScreen, { alpha=0, time = 400, transition = easing.outQuad } )

--~ 	-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
--~ 	transition.to( list, { x = - list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
--~ 	transition.to( newGameButton, { alpha = 0, time = 400, transition = easing.outExpo } )
--~ 	--transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
--~ 	transition.to( editButton, { alpha = 1, time = 400, transition = easing.outQuad } )
--~ 	transition.to( emailButton, { alpha = 1, time = 400, transition = easing.outQuad } )
--~ 	transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
--~ 	gamelist.LoadInfo()
--~ 	for hiderow=1,#infoButtons do
--~ 		transition.to( infoButtons[hiderow].infodisplay, { alpha = 1, time = 400, transition = easing.outQuad } )
--~ 		transition.to( labelInfo[hiderow], { alpha = 1, time = 400, transition = easing.outQuad } )
--~ 	end
	mode = "gameinfo"
end

local transitionOut = function( currentIndex )
	for hiderow=1,#infoButtons do
		if hiderow == currentIndex then
			transition.to( labelInfo[hiderow], { y=topUsableY + (display.contentHeight/20), time = 400, transition = easing.outQuad } )
			if isSimulator and infoButtons[hiderow].heading ~= 'Result' then
				transition.to( infoButtons[hiderow].infodisplay, { y=topUsableY + (display.contentHeight/20), alpha = 0.2, time = 400, transition = easing.outQuad } )
			else
				transition.to( infoButtons[hiderow].infodisplay, { y=topUsableY + (display.contentHeight/20), alpha = 0, time = 400, transition = easing.outQuad } )
				if infoButtons[hiderow].heading == 'Result' then
					transition.to( infoButtons[hiderow].inforesult, { time = 400, alpha = 1, transition = easing.outQuad } )
					for rbs=1, #infoButtons[hiderow].infoRadios do
						transition.to( infoButtons[hiderow].infoRadios[rbs], { y=topUsableY + (display.contentHeight/20), time = 400, transition = easing.outQuad } )
					end
				else
					transition.to( infoButtons[hiderow].infoinput, { y=topUsableY + (display.contentHeight/20), time = 400, transition = easing.outQuad } )
				end
			end
		else
			transition.to( labelInfo[hiderow], { x=-labelInfo[hiderow].contentWidth*.5, alpha = 0, time = 400, transition = easing.outQuad } )
			transition.to( infoButtons[hiderow].infodisplay, { x=display.contentWidth, alpha = 0, time = 400, transition = easing.outQuad } )
		end
	end
	transition.to( editButton, { y=display.contentHeight+buttonHeight*2, alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { y=display.contentHeight+buttonHeight*2, alpha = 0, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { y=display.contentHeight+buttonHeight*2, alpha = 0, time = 400, transition = easing.outQuad } )
	out = true
end

local transitionIn = function( currentIndex )
	for hiderow=1,#infoButtons do
		if hiderow == currentIndex then
			transition.to( labelInfo[hiderow], { y=topUsableY + (hiderow*(display.contentHeight/20)), time = 400, transition = easing.outQuad } )
			transition.to( infoButtons[hiderow].infodisplay, { y=topUsableY + (hiderow*(display.contentHeight/20)), alpha = 1, time = 400, transition = easing.outQuad } )
			if infoButtons[hiderow].heading == 'Result' then
				transition.to( infoButtons[hiderow].inforesult, { time = 400, alpha = 0, transition = easing.outQuad } )
				for rbs=1, #infoButtons[hiderow].infoRadios do
					transition.to( infoButtons[hiderow].infoRadios[rbs], { y=topUsableY + (hiderow * display.contentHeight/20), time = 400, transition = easing.outQuad } )
				end
			end
		else
			transition.to( labelInfo[hiderow], { x=10, alpha = 1, time = 400, transition = easing.outQuad } )
			transition.to( infoButtons[hiderow].infodisplay, { x=display.contentWidth/3, alpha = 1, time = 400, transition = easing.outQuad } )
		end
	end
	transition.to( editButton, { y=display.contentHeight-buttonHeight*1.5, alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( emailButton, { y=display.contentHeight-buttonHeight*1.5, alpha = 1, time = 400, transition = easing.outQuad } )
	transition.to( backButton, { y=display.contentHeight-buttonHeight*1.5, alpha = 1, time = 400, transition = easing.outQuad } )
	out = false
end

-------------------------------------------
-- Handle the textField keyboard input
--
function NewInfoButton( iX, index, iWidth, iHeight, infoText, headingText )
	local infoButton = {}
	infoButton.infoinput = nil
	infoButton.infodisplay = nil
	infoButton.heading = headingText
	infoButton.index = index
	infoButton.inforesult = nil
	infoButton.infoRadios = {}
	
	local CapitalizeFirstLetters = function( inputStr )
		inputStr = string.gsub( inputStr, "^(%a)", function (s)
           return string.upper(s)
         end)
		inputStr = string.gsub( inputStr, " (%a)", function (s)
           return ' '..string.upper(s)
         end)
		return inputStr
	end
		
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
				infoButton.infodisplay:setLabel( CapitalizeFirstLetters( infoButton.infoinput.text ) )
				--gameInfo[infoButton.heading] = infoButton.infoinput.text
			end
			
			-- Hide keyboard
			native.setKeyboardFocus( nil )
			--print(' Now removing infoinput' )
			infoButton.infoinput:removeSelf()
			infoButton.infoinput = nil
			transitionIn(infoButton.index)
--~ 		elseif infoButton.heading == 'Date' then
--~ 			local len = string.len( infoButton.infoinput.text )
--~ 			if  len == 4 or len == 7 then
--~ 				infoButton.infoinput.text = infoButton.infoinput.text .. '.'
--~ 			end
--~ 			infoButton.infoinput.text = string.gsub( infoButton.infoinput.text, '%.%.', '%.' )
		end
	end
	
	infoButton.InfoResult = function( event )
		infoButton.infodisplay:setLabel( event.target.id )
		transitionIn(infoButton.index)
	end
	
	local onInfoButtonRelease = function()
		if isSimulator and infoButton.heading ~= 'Result' then
			if out then
				transitionIn(infoButton.index)
			else
				transitionOut(infoButton.index)
			end	
			infoButton.infodisplay:setLabel( CapitalizeFirstLetters( 'changed' ) )
		else
			if infoButton.heading == 'Result'  then
				if infoButton.inforesult == nil then
					-- Create a group for the radio button set
					infoButton.inforesult = display.newGroup()
					infoButton.infoRadios = {}

					-- Create two associated radio buttons (inserted into the same display group)
					local options = 
					{
						left = (2*display.contentWidth/3)-50,
						top = infoButton.infodisplay.y,
						style = "radio",
						id = '1-0',
						initialSwitchState = false,
						onRelease = infoButton.InfoResult,
						sheet = whiteWinSheet,
						frameOff = 2,
						frameOn = 1,
					}
					local wwButton = widget.newSwitch( options )
					infoButton.infoRadios[#infoButton.infoRadios+1] = wwButton
					infoScreen:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					infoButton.inforesult:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					options.sheet = blackWinSheet
					options.left = 2*display.contentWidth/3
					options.id = '0-1'
					options.initialSwitchState = false
					local bwButton = widget.newSwitch( options )
					infoButton.infoRadios[#infoButton.infoRadios+1] = bwButton
					infoScreen:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					infoButton.inforesult:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					options.sheet = drawSheet
					options.left = 50+2*display.contentWidth/3
					options.id = '1/2-1/2'
					options.initialSwitchState = false
					local drButton = widget.newSwitch( options )
					infoButton.infoRadios[#infoButton.infoRadios+1] = drButton
					infoScreen:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					infoButton.inforesult:insert( infoButton.infoRadios[#infoButton.infoRadios] )
					infoScreen:insert( infoButton.inforesult )
				end
				for rbs=1, #infoButton.infoRadios do
					local setOn = ( infoButton.infodisplay:getLabel() == infoButton.infoRadios[rbs].id)
					if setOn then
						infoButton.infoRadios[rbs]:setState( { isOn=setOn } )
					end
				end
				transitionOut(infoButton.index)
			else
				local inputFontSize = 20
--~ 				if ( isAndroid ) then
--~ 					inputFontSize = inputFontSize - 4
--~ 				end

				infoButton.infoinput = native.newTextField( infoButton.infodisplay.x, infoButton.infodisplay.y, infoButton.infodisplay.width, infoButton.infodisplay.height )
				infoButton.infoinput.anchorX = 0
				infoButton.infoinput.anchorY = 0
				infoButton.infoinput.font = native.newFont( native.systemFontBold, inputFontSize )		
				if infoButton.infodisplay:getLabel() ~= 'Not Specified' then
					infoButton.infoinput.text = infoButton.infodisplay:getLabel()
				elseif infoButton.heading == 'Date' then
					infoButton.infoinput.placeholder = 'YYYY.MM.DD'
				end
				infoButton.infoinput.inputType = gameInfoType[headingText]
				transitionOut(infoButton.index)
				native.setKeyboardFocus( infoButton.infoinput )
				--local handlerName = headingtext .. 'Handler'
				infoButton.infoinput:addEventListener( "userInput", infoButton.InfoEntry )
			end
		end
	end
	
	local infoDisplayOption = 
	{
		x = iX,
		y = topUsableY + (infoButton.index*(display.contentHeight/20)),
		width = iWidth,
		height = iHeight,
		--anchorX = 0,
		--anchorY = 0,
		label = infoText, 
		labelYOffset = -1,
		emboss = false,
		shape="roundedRect",
		cornerRadius = 10,
		fontSize = 16,
		font = native.systemFont,
		labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
		fillColor = { default={ 1, 1, 1, 0.2 }, over={ 1, 1, 1, 0.2 } },
		--strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
		--strokeWidth = 1,	
		onRelease = onInfoButtonRelease
	}
	if gameInfoType[headingText] == nil then
		infoDisplayOption.fillColor = { default={ .95, .95, .95, 0.8 }, over={ 1, 1, 1, 0.4 } }
	end
	infoButton.infodisplay = widget.newButton( infoDisplayOption )
	if gameInfoType[headingText] == nil then
		infoButton.infodisplay:setEnabled( false )
	end
	infoButton.infodisplay.alpha = 1
	infoButton.infodisplay.anchorX = 0
	infoButton.infodisplay.anchorY = 0.13
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
		infoButtons[inforow] = NewInfoButton(  display.contentWidth/3, 
								    inforow,
								    2*display.contentWidth/3, 
								    height, infotext, headingtext ) 
		infoScreen:insert( infoButtons[inforow].infodisplay )
	end
	infoButtons[inforow].infodisplay:setLabel( infotext )
		
	if labelInfo[inforow] == nil then
		labelInfo[inforow] = display.newText( headingtext, 0,0, display.contentWidth/2.1, height, native.systemFont, 16 )
		labelInfo[inforow]:setFillColor( 0.2, 0.2, 0.2 )
		labelInfo[inforow].x = 10
		labelInfo[inforow].y = topUsableY + (inforow*(display.contentHeight/20))
		labelInfo[inforow].anchorX = 0    
		labelInfo[inforow].anchorY = 0
		infoScreen:insert( labelInfo[inforow] )
	end
	labelInfo[inforow].text = headingtext
end

local infoDataOrder = 
{
	'Source',
	'Date',
	'Site',
	'Event',
	'Round',
	'Result',
	'White',
	'WhiteELO',
	'Black',
	'BlackELO',
}

gamelist.LoadInfo = function()
	LoadGame( itemSelected )
	local inforow = 1
	gamelist.DisplayInfo( inforow, 'Game',  itemSelected )
	--inforow = inforow + 1
	for heading, info in pairs(gameInfo) do
		for index=1, #infoDataOrder do
			if heading == infoDataOrder[index] then
				inforow = index + 1
				break
			end
		end
		gamelist.DisplayInfo( inforow, heading, info )
		--inforow = inforow + 1
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
	
	if "press" == phase or "release" == phase then
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
	height = display.contentHeight - topUsableY - buttonHeight * 2.0,
	--maskFile = "background.png",
	hideBackground = true,
	onRowRender = onRowRender,
	onRowTouch = onRowTouch,
}
--print( list.height )

--Insert widgets/images into a group
listScreen:insert( list )

--Handle the edit button release event
local function onNewRelease()
	system.vibrate()
	-- Update the item selected text
	newFile = true
	itemSelected = 'Game' .. lastFileIndex .. '.pgn'
	lastFileIndex = lastFileIndex + 1
	gamelist.TransitionToItem()
end

local function GrabAndHideInput()
	for hiderow=1,#infoButtons do
		if infoButtons[hiderow].heading ~= 'Game' then
			--print( infoButtons[hiderow].heading, infoButtons[hiderow].infodisplay:getLabel() )
			if infoButtons[hiderow].infodisplay:getLabel() == 'Not Specified' then
				gameInfo[infoButtons[hiderow].heading] = ''
			else
				gameInfo[infoButtons[hiderow].heading] = infoButtons[hiderow].infodisplay:getLabel()
			end
		end
		if( infoButtons[hiderow].infoinput ) then
			infoButtons[hiderow].infoinput:removeSelf()
			infoButtons[hiderow].infoinput = nil
		end
	end
end

--Handle the edit button release event
local function onEditRelease()
	system.vibrate()
	GrabAndHideInput()
	if newFile == true then
		gamelist.files[#gamelist.files + 1] = gamelist.selectedFile
		list:insertRow({ rowHeight = 40,  rowColor = { default={ 1, 1, 1, 0 }, over={ 1, 1, 1, 0.2 } }})
		newFile = false
	end
	gamelist.selectedFile = itemSelected
	gamelist.TransitionToList()
end

--Handle the edit button release event
local function onBackRelease()
	system.vibrate()
	--Transition in the list, transition out the item selected text and the edit button
	GrabAndHideInput()
	SaveGame( itemSelected )
	itemSelected = '' 
	gamelist.FindFiles()
	gamelist.TransitionToList()
end

--Create the New Game button
newGameButton = widget.newButton
{
	label = "NewGame", 
	labelYOffset = - 1,
    emboss = false,
    --properties for a rounded rectangle button...
    shape="roundedRect",
	width = display.contentWidth / 3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 6,
	fontSize = 16,
	onRelease = onNewRelease,
}
newGameButton.alpha = 1
newGameButton.x = display.contentWidth * 0.5
newGameButton.y = display.contentHeight - buttonHeight * 1.5
listScreen:insert( newGameButton )

local function onCreditsRelease( event )
	system.vibrate()
	mode = 'credits'
	forceHelp = true
end

creditsButton = widget.newButton
{
	label = "Credits", 
	labelYOffset = - 1,
    emboss = false,
    --properties for a rounded rectangle button...
    shape="roundedRect",
	width = display.contentWidth / 3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 6,
	fontSize = 16,
	onRelease = onCreditsRelease,
}
creditsButton.alpha = 1
creditsButton.x = display.contentWidth * 0.18
creditsButton.y = display.contentHeight - buttonHeight * 1.5
listScreen:insert( creditsButton )

local function onFeedbackRelease( event )
	system.vibrate()
	-- compose an HTML email with two attachments
	local emailBody = '------------- APP INFO -------------\n'
	emailBody = emailBody .. 'Version: ' .. tostring( version ) .. '\n'
	emailBody = emailBody .. 'Platform: ' .. system.getInfo( "platformName" ) .. '\n'
	emailBody = emailBody .. '------------- ### #### -------------\n\n'
	
	local options =
	{
		to = { 'boardworksgames+chessnotes@gmail.com' },
		--cc = { "john.smith@somewhere.com", "jane.smith@somewhere.com" },
		subject = 'ChessNotes: Feedback',
		isBodyHtml = false,
		--body = "<html><body>I scored over <b>9000</b>!!! Can you do better?</body></html>",
		body = emailBody,
--	   attachment =
--	   {
--		  { baseDir=system.ResourceDirectory, filename="email.png", type="image" },
--		  { baseDir=system.ResourceDirectory, filename="coronalogo.png", type="image" },
--	   },
	}
	local result = native.showPopup( "mail", options )
	print( options.body )
	if not result then
		print( "Mail Not supported/setup on this device" )
		native.showAlert( "Alert!",	"Mail not supported/setup on this device.", { "OK" })
	end
	-- NOTE: options table (and all child properties) are optional
end



feedbackButton = widget.newButton
{
	label = "Feedback", 
	labelYOffset = - 1,
    emboss = false,
    --properties for a rounded rectangle button...
    shape="roundedRect",
	width = display.contentWidth / 3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 6,
	fontSize = 16,
	onRelease = onFeedbackRelease,
}
feedbackButton.alpha = 1
feedbackButton.x = display.contentWidth * 0.82
feedbackButton.y = display.contentHeight - buttonHeight * 1.5
listScreen:insert( feedbackButton )


--Create the edit button
editButton = widget.newButton
{
	label = "Notate", 
    emboss = false,
	shape="roundedRect",
	width = display.contentWidth/3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 5,	
	onRelease = onEditRelease
}
editButton.alpha = 1
editButton.x = display.contentWidth * 0.5
editButton.y = display.contentHeight - buttonHeight * 1.5
infoScreen:insert( editButton )

backButton = widget.newButton
{
	label = "Back", 
    emboss = false,
	shape="roundedRect",
	width = display.contentWidth/3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 5,	
	onRelease = onBackRelease
}
backButton.alpha = 1
backButton.x = display.contentWidth * 0.18
backButton.y = display.contentHeight - buttonHeight * 1.5
infoScreen:insert( backButton )

local function onEmailRelease( event )
	system.vibrate()
	-- compose an HTML email with two attachments
	local options =
	{
	   --to = { "sandeep.kharkar@gmail.com" },
	   --cc = { "john.smith@somewhere.com", "jane.smith@somewhere.com" },
	   subject = gamelist.selectedFile,
	   isBodyHtml = false,
	   --body = "<html><body>I scored over <b>9000</b>!!! Can you do better?</body></html>",
	   body = GetSaveGameText(),
--	   attachment =
--	   {
--		  { baseDir=system.ResourceDirectory, filename="email.png", type="image" },
--		  { baseDir=system.ResourceDirectory, filename="coronalogo.png", type="image" },
--	   },
	}
	local result = native.showPopup( "mail", options )
	--print( options.body )
	if not result then
		print( "Mail Not supported/setup on this device" )
		native.showAlert( "Alert!",	"Mail not supported/setup on this device.", { "OK" })
	end
	-- NOTE: options table (and all child properties) are optional
end

--Create the Email button
emailButton = widget.newButton
{
	label = "Email", 
    emboss = false,
	shape="roundedRect",
	width = display.contentWidth/3.5,
	height = buttonHeight,
    cornerRadius = 10,
    labelColor = { default={ 0, 0, 0, 1 }, over={ .1, 0.1, 0.1, 1 } },
    fillColor = { default={ 1, 1, 1, 0.6 }, over={ 1, 1, 1, 0.6 } },
    strokeColor = { default={ 1, 0.85, 0.3, 1 }, over={ 0, 0, 0, 1 } },
    strokeWidth = 5,	
	onRelease = onEmailRelease
}
emailButton.alpha = 1
emailButton.x = display.contentWidth * 0.82
emailButton.y = display.contentHeight - buttonHeight * 1.5
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
	--list:reloadData()
	--print( lastFileIndex )
end

local creditstext = [[
Programming & Art

Sandeep Kharkar
  Co-Owner Boardworks LLC
______________

Keyboard Click Sound:

Created by "lebcraftlp"  
  http://lebtv.tk/ 

The original audio was edited to remove silence before and after the click sound.
	
Creative Commons License
  http://bit.ly/1jmalQx
______________

Beta Test and Feedback:

Blake Walker 
  Chess Coach 
  Software QA Professional

Dave Haslam
  Co-Owner Boardworks LLC

Pallavi Ranade 
  Software Engineer
  Chess Parent

Anoushka Kharkar
  Chess Kid

Vismaya Kharkar
  "Kill the King!" 
______________

App Framework:

Corona Labs
  http://coronalabs.com/



]]

local gamelisthelptext = [[
This screen lists the current games that you have saved. Here, you can choose to add a new game or edit a current game. Scroll up and down by swiping up or down on your phone.

To add a new game use the "New Game" button. Games are named automatically and sequentially and cannot be renamed at this time.

To edit a game that you have saved touch the row on which the game is listed. This will take you to the Game Information screen.


]]


local gameinfohelptext = [[
This screen shows you information about the selected game. 

From this screen you can choose to edit the Move List of the game by selecting the "Edit" button.

You can send a copy of the PGN file for this game using the "Email" button. You need an email account and a default email app to do this. Your phone also needs to have an active internet connection (wireless or cellular).

On this screen you can also edit information about the game. To edit any of the information select the current value of that field and type in the new information. The following information is stored for each game in addition to moves that were made in the game:

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

To return to the Game List screen use the "Back" button.


]]

gamelist.GetHelpInfo = function()
	if mode == 'gamelist' then
		return "Game List Help" , gamelisthelptext
	elseif mode == 'credits' then
		return 'Credits', creditstext
	end
	
	for hiderow=1,#infoButtons do
		if( infoButtons[hiderow].infoinput ) then
			native.setKeyboardFocus( nil )
			infoButtons[hiderow].infoinput:removeSelf()
			infoButtons[hiderow].infoinput = nil
		end
		transitionIn(hiderow)
	end
	
	return "Game Info Help" , gameinfohelptext
end


gamelist.handleAndroidBackButton = function()
	if mode == 'gameinfo' then
		currentRow = 0
		for hiderow=1,#infoButtons do
			if infoButtons[hiderow].infoinput  then
				native.setKeyboardFocus( nil )
				infoButtons[hiderow].infoinput:removeSelf()
				infoButtons[hiderow].infoinput = nil
				currentRow = hiderow
			elseif infoButtons[hiderow].inforesult then
				currentRow = hiderow
			end
		end	
		if currentRow then 			
			transitionIn(currentRow)
		end
		onBackRelease()
		return true
	end
	return false
end

gamelist.FindFiles()
gamelist.TransitionToList()

return gamelist