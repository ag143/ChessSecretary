-- TODO: Add location TL,TR, BL, BR

local widget = require( "widget" )

helpWidget = {}
	
helpWidget.asked4Help = false
helpWidget.doneWithHelp = false
helpWidget.helpScreen = display.newGroup()
helpWidget.helpButton = nil
helpWidget.backButton = nil
helpWidget.size = 15
helpWidget.scrollView = nil
helpWidget.titleText = nil
helpWidget.helpText = nil

local helpScreenBkgnd = display.newRect( 0, 0, display.actualContentWidth, display.actualContentHeight, 18 )
helpScreenBkgnd:setFillColor( {
	type = 'gradient',
	color1 = { 1, 1, 1, 1 }, 
	color2 = { .8, .8, .8, .4 },
	direction = "down"
} )
helpScreenBkgnd.anchorX = 0
helpScreenBkgnd.anchorY = 0
helpWidget.helpScreen:insert( helpScreenBkgnd )

helpWidget.TransitionOut = function( direction, time )
	-- help on, back off
	transition.to( helpWidget.helpButton, { x = display.contentWidth-(helpWidget.size+5), alpha=1, time = time*1.05, rotation=0, transition = easing.outQuad } )
	transition.to( helpWidget.backButton, { x = display.contentWidth-(helpWidget.size+5), alpha=0, time = time*1.05, rotation=180, transition = easing.outQuad } )
	helpWidget.helpButton:setEnabled( true )
	helpWidget.backButton:setEnabled( false )
	
	-- Transition Screen out
	local multiple = 1.5
	if direction == 'left' then
		multiple = multiple*-1
	end
	transition.to( helpWidget.helpScreen, { x = display.contentWidth * multiple, alpha=0, time = time, transition = easing.outQuad } )
end

helpWidget.TransitionIn = function( time )
	-- Transition Screen In
	transition.to( helpWidget.helpScreen, { x = 0, alpha=1, time = time, transition = easing.outQuad } )
	-- help off, back on
	transition.to( helpWidget.helpButton, { x = helpWidget.size+5, alpha=0, time = time*1.05, rotation=180, transition = easing.outQuad } )
	transition.to( helpWidget.backButton, { x = helpWidget.size+5, alpha=1, time = time*1.05, rotation=0, transition = easing.outQuad } )
	helpWidget.helpButton:setEnabled( false )
	helpWidget.backButton:setEnabled( true )
end

local function DoneWithHelp()
	helpWidget.doneWithHelp = true
	--helpWidget.helpScreen.isVisible = falses
	helpWidget.TransitionOut( 'right', transitionTime )
	--helpWidget.backButton.alpha = 0.01
	helpWidget.scrollView:remove( helpWidget.helpText )
	--helpWidget.helpText = nil
end

	-- Add controls to Help Screen
local function scrollListener( event )
	local direction = event.direction
	
	-- If the scrollView has reached it's scroll limit
	if event.limitReached and ( "left" == direction or "right" == direction ) then
		DoneWithHelp()
	end
	return true
end



helpWidget.ShowHelp = function( topY, heading, helpText )

	helpWidget.doneWithHelp = false
	--helpWidget.helpScreen.isVisible = true
	helpWidget.TransitionIn( transitionTime )
	helpWidget.backButton:setEnabled( true )
	helpWidget.backButton.alpha = 1.0
	
	-- Create a ScrollView
	if helpWidget.scrollView == nil then
		helpWidget.scrollView = widget.newScrollView
		{
			left = 0,
			top = appOriginY+titleBarHeight*1.5,
			width = display.contentWidth,
			height = display.contentHeight-appOriginY-titleBarHeight/2,
			bottomPadding = 0,
			id = "onBottom",
			horizontalScrollDisabled = false,
			verticalScrollDisabled = false,
			hideBackground = true,
			listener = scrollListener,
		}
		helpWidget.helpScreen:insert( helpWidget.scrollView )
	end
	
	--Create a text object for the scrollViews title
	if helpWidget.titleText == nil then
		--helpWidget.titleText = display.newText( heading, display.contentCenterX, appOriginY, native.systemFontBold, 24)
		--helpWidget.titleText:setFillColor( 0 )
		--helpWidget.titleText:setFillColor( titleGradient )
		
		local titleGradient = {
			type = 'gradient',
			color2 = { 0, 0.9, 0, 1.0 }, 
			color1 = { 0.6, 0.9, 0.4, 0.9 },
			direction = "down"
		}

		-- Create toolbar to go at the top of the screen
		local titleBar = display.newRect( 50, 0, display.contentWidth-50, titleBarHeight )
		titleBar:setFillColor( titleGradient )
		titleBar.anchorX = 0
		titleBar.y = appOriginY + titleBarHeight * 0.5
		local topUsableY = appOriginY + titleBarHeight
		helpWidget.helpScreen:insert(  titleBar )

		-- create embossed text to go on toolbar
		helpWidget.titleText = display.newEmbossedText( heading, 50+(display.contentWidth-50)/2, titleBar.y, native.systemFontBold, 20 )
		helpWidget.titleText:setFillColor(0,0,0)
		helpWidget.helpScreen:insert( helpWidget.titleText )
		
		-- create a shadow underneath the titlebar (for a nice touch)
		local shadow = display.newImage( "shadow.png" )
		shadow.anchorX = 0.0	-- TopLeft anchor points
		shadow.anchorY = 0.0
		shadow.x, shadow.y = 50, titleBar.y + titleBarHeight * 0.5
		shadow.xScale = ( display.contentWidth - 50 ) / shadow.contentWidth
		shadow.alpha = 0.45
		helpWidget.helpScreen:insert( shadow )
	end
	helpWidget.titleText.text =  heading
	
	--Create a text object containing the large text string and insert it into the scrollView
	if helpWidget.helpText == nil then
		helpWidget.helpText = display.newText( helpText, display.contentCenterX, 0, 300, 0, native.systemFontBold, 18)
		helpWidget.helpText:setFillColor( 0 ) 
		helpWidget.helpText.anchorY = 0.0		-- Top
		helpWidget.helpText.y = topAlignAxis
		--helpWidget.helpText.y = helpWidget.titleText.y + helpWidget.titleText.contentHeight + 10
		helpWidget.helpScreen:insert( helpWidget.helpText )
	end
	helpWidget.helpText.text = helpText
	helpWidget.scrollView:insert( helpWidget.helpText )
	
	helpWidget.scrollView:scrollTo( "top", {0} )
end

helpWidget.ShowHelpButton = function( size )
	helpWidget.size = size
	bufferedSize = size+5	
	-- Function to handle button events
	local function handleButtonEvent( event )
		if ( "ended" == event.phase ) then
			if event.target:getLabel() == '?' then
				helpWidget.asked4Help = true
			else
				DoneWithHelp()
			end
		end
	end

	helpWidget.helpButton = widget.newButton
	{			
		label = '?',
		emboss = false,
		width = bufferedSize*2,
		height = bufferedSize*2,
		labelColor = { default={ 0, 0, 0 }, over={ 1, 0, 0 } },
		--properties for a circle button...
		shape="circle",
		x = display.contentWidth - bufferedSize,
		y = appOriginY+size,
		radius = size,
		fillColor = { default={ 0.6, 0.9, 0.4, 0.9 }, over={ 0, 0.9, 0 } },
		strokeColor = { default={ 0, 0.9, 0 }, over={ 0.6, 0.9, 0.4, 0.6 } },
		strokeWidth = bufferedSize/10,
		onEvent = handleButtonEvent,
	}
	helpWidget.backButton = widget.newButton
	{			
		label = '  <',
		emboss = false,
		width = bufferedSize*2,
		height = bufferedSize*2,
		labelColor = { default={ 0, 0, 0 }, over={ 1, 1, 1 } },
		--properties for a polygon button...
		x = size*1.5,
		y = appOriginY+size,--(titleBarHeight/2), --display.contentHeight - size*1.5,
		shape="polygon",
		vertices = { 
			0, size, 
			size, 0, 
			size*2.25, 0, 
			size*2.25, size*2,
			size, size*2,
		},
		fillColor = { default={ 0.7, 0.0, 0.1, 0.4 }, over={ 0.8, 0.1, 0.1, 0.7 } },
		strokeColor = { default={ 0.8, 0.1, 0.1, 0.7 }, over={ 0.7, 0.0, 0.1, 0.4 } },
		strokeWidth = bufferedSize/8,
		onEvent = handleButtonEvent,
	}
	helpWidget.backButton:setEnabled( false )
	--helpWidget.backButton.alpha = 0.01
	--helpWidget.helpScreen:insert( helpWidget.backButton )
	helpWidget.TransitionOut( 'right', 0 )
end

helpWidget.AskedForHelp = function()
	a4h = helpWidget.asked4Help
	helpWidget.asked4Help = false
	return a4h
end

helpWidget.handleAndroidBackButton = function()
	DoneWithHelp()
	return true
end

return helpWidget