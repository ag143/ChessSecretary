local editor = require( 'editscreen' )
editor.editScreen.isVisible = false

local gameList = require( 'gamelist' )

gameList.widgetGroup.isVisible = true
local state = 'selectgame'

--editor.editScreen.isVisible = true
--state = 'editgame'

local function appState(event)
	if state == 'selectgame' then
		if gameList.selectedFile ~= '' then
			gameList.widgetGroup.isVisible = false
			state = 'editgame'
			editor.editDone = false
			editor.filename = gameList.selectedFile
			editor.LoadGame()
			editor.editScreen.isVisible = true
			--print( 'Going to Edit Mode ' .. gameList.selectedFile )
			--print( editor.editDone )
		end
	elseif state == 'editgame' then
		if editor.editDone == true then
			editor.editScreen.isVisible = false
			state = 'selectgame'
			gameList.selectedFile = ''
			gameList.FindFiles()
			gameList.widgetGroup.isVisible = true
			gameList.TransitionToList()
			--print( 'Going to List Mode ' .. gameList.selectedFile )
			--print( editor.editDone )
		end
	end
end

Runtime:addEventListener( "enterFrame", appState );

--local options =
--{
--	to = "john.doe@somewhere.com",
--	subject = "My High Score",
--	body = editor.GatherMoves(),
--}
--native.showPopup("mail", options)
