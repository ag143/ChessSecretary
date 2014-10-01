-- TODO: Add location TL,TR, BL, BR

local widget = require( "widget" )

helpWidget = {}
	
helpWidget.asked4Help = false
helpWidget.doneWithHelp = false
helpWidget.helpScreen = display.newGroup()
helpWidget.helpButton = nil
helpWidget.myCircle = nil

	-- Add controls to Help Screen
local function scrollListener( event )
	local direction = event.direction
	
	-- If the scrollView has reached it's scroll limit
	if event.limitReached and ( "left" == direction or "right" == direction ) then
		helpWidget.doneWithHelp = true
		helpWidget.helpScreen.isVisible = false
		helpWidget.helpButton:setEnabled( true )
		helpWidget.helpButton.alpha = 1.0
		helpWidget.myCircle.alpha = 1.0
	end
			
	return true
end



helpWidget.ShowHelp = function( topY, heading, helpText )

	helpWidget.doneWithHelp = false
	helpWidget.helpScreen.isVisible = true
	helpWidget.helpButton:setEnabled( false )
	helpWidget.helpButton.alpha = 0.1
	helpWidget.myCircle.alpha = 0.1
	
	-- Create a ScrollView
	local scrollView = widget.newScrollView
	{
		left = 0,
		top = topY,
		width = display.contentWidth,
		height = display.contentHeight-topY,
		bottomPadding = 50,
		id = "onBottom",
		horizontalScrollDisabled = false,
		verticalScrollDisabled = false,
		listener = scrollListener,
	}
	helpWidget.helpScreen:insert( scrollView )

	--Create a text object for the scrollViews title
	local titleText = display.newText( heading, display.contentCenterX, 24, native.systemFontBold, 24)
	titleText:setFillColor( 0 )
	helpWidget.helpScreen:insert( titleText )
	scrollView:insert( titleText )

	local instrText1 = display.newText("<<<< Scroll Left/Right to Dismiss >>>>", display.contentCenterX, 60, native.systemFontBold, 16)
	instrText1.y = titleText.y + titleText.contentHeight + 10
	instrText1:setFillColor( 0.9, 0.1, 0.1 )
	helpWidget.helpScreen:insert( instrText1 )
	scrollView:insert( instrText1 )

	local instrText2 = display.newText( '++++ Scroll Up/Down to Read ++++', display.contentCenterX, 60, native.systemFontBold, 16)
	instrText2.y = instrText1.y + instrText1.contentHeight + 5
	instrText2:setFillColor( 0.0, 0.2, 0.9 )
	helpWidget.helpScreen:insert( instrText2 )
	scrollView:insert( instrText2 )

	--Create a text object containing the large text string and insert it into the scrollView
	local lotsOfTextObject = display.newText( helpText, display.contentCenterX, 0, 300, 0, native.systemFont, 14)
	lotsOfTextObject:setFillColor( 0 ) 
	lotsOfTextObject.anchorY = 0.0		-- Top
	--------------------------------lotsOfTextObject:setReferencePoint( display.TopCenterReferencePoint )
	lotsOfTextObject.y = instrText2.y + instrText2.contentHeight + 10


	helpWidget.helpScreen:insert( lotsOfTextObject )
	scrollView:insert( lotsOfTextObject )
	
end

helpWidget.ShowHelpButton = function( size )
	bufferedSize = size+5
	helpWidget.myCircle = display.newCircle( display.contentWidth - bufferedSize, display.contentHeight - bufferedSize, size )
	helpWidget.myCircle:setFillColor( 0.6, 0.9, 0.4, 0.6 )
	helpWidget.myCircle.strokeWidth = bufferedSize/10
	helpWidget.myCircle:setStrokeColor( 0, 0.9, 0 )
	
	-- Function to handle button events
	local function handleButtonEvent( event )
		if ( "ended" == event.phase ) then
			helpWidget.asked4Help = true
		end
	end

	helpWidget.helpButton = widget.newButton
	{			
		label = '?',
		emboss = false,
		width = bufferedSize*2,
		height = bufferedSize*2,
		labelColor = { default={ 0, 0, 0 }, over={ 1, 0, 0 } },
		fillColor = { default={ 1, 1, 1, 0 }, over={ 1, 1, 1, 0 } },
		onEvent = handleButtonEvent,
	}
	helpWidget.helpButton.x = display.contentWidth - bufferedSize*2
	helpWidget.helpButton.y = display.contentHeight - bufferedSize*2
	helpWidget.helpButton.anchorX = 0
	helpWidget.helpButton.anchorY = 0
end

helpWidget.AskedForHelp = function()
	a4h = helpWidget.asked4Help
	helpWidget.asked4Help = false
	return a4h
end

helpWidget.helpScreen.isVisible = false
return helpWidget