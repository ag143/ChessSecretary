-- TODO: Add location TL,TR, BL, BR

local widget = require( "widget" )

helpWidget = {}
	
helpWidget.asked4Help = false

helpWidget.ShowHelpButton = function( size )
	bufferedSize = size+5
	myCircle = display.newCircle( display.contentWidth - bufferedSize, display.contentHeight - bufferedSize, size )
	myCircle:setFillColor( 0.6, 0.9, 0.4, 0.6 )
	myCircle.strokeWidth = bufferedSize/10
	myCircle:setStrokeColor( 0, 0.9, 0 )
	
	-- Function to handle button events
	local function handleButtonEvent( event )
		if ( "ended" == event.phase ) then
			helpWidget.asked4Help = true
		end
	end

	helpButton = widget.newButton
	{			
		label = '?',
		emboss = true,
		width = bufferedSize*2,
		height = bufferedSize*2,
		labelColor = { default={ 0, 0, 0 }, over={ 1, 0, 0 } },
		onEvent = handleButtonEvent,
	}
	helpButton.x = display.contentWidth - bufferedSize*2
	helpButton.y = display.contentHeight - bufferedSize*2
	helpButton.anchorX = 0
	helpButton.anchorY = 0
end

helpWidget.AskedForHelp = function()
	a4h = helpWidget.asked4Help
	helpWidget.asked4Help = false
	return a4h
end

return helpWidget