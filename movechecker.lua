local checker = {}

checker.invalidMove = 0
checker.capCol = ''
checker.capRow = 0
checker.capColIdx = 0
checker.whitePawns = { 'a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2'}
checker.whitePieces = 
{ 
	Ra = 'a1', 
	Nb = 'b1', 
	Bc = 'c1', 
	Q  = 'd1',
	K  = 'e1',
	Bf = 'f1',
	Ng = 'g1',
	Rh = 'h1',
}
checker.blackPawns = { 'a7', 'b7', 'c7', 'd7','e7','f7','g7','h7'}
checker.blackPieces = 
{ 
	Ra = 'a8', 
	Nb = 'b8', 
	Bc = 'c8', 
	Q  = 'd8',
	K  = 'e8',
	Bf = 'f8',
	Ng = 'g8',
	Rh = 'h8',
}
checker.columns = { 'a','b','c','d','e','f','g','h' }
checker.pieces = { 'Ra', 'Nb', 'Bc', 'Q', 'K', 'Bf', 'Ng', 'Rh' }

checker.board = --Rows
{
	a = { 'w_Ra', 'w_a', ' ',' ',' ',' ', 'l_a', 'l_Ra' },
	b = { 'w_Nb', 'w_b', ' ',' ',' ',' ', 'l_b', 'l_Nb' },
	c = { 'w_Bc', 'w_c', ' ',' ',' ',' ', 'l_c', 'l_Bc' },
	d = { 'w_Q',  'w_d', ' ',' ',' ',' ', 'l_d', 'l_Q' },
	e = { 'w_K',  'w_e', ' ',' ',' ',' ', 'l_e', 'l_K' },
	f = {	'w_Bf', 'w_f', ' ',' ',' ',' ', 'l_f', 'l_Bf' },
	g = { 'w_Ng', 'w_g', ' ',' ',' ',' ', 'l_g', 'l_Ng' },
	h = { 'w_Rh', 'w_h', ' ',' ',' ',' ', 'l_h', 'l_Rh' },
}

local function ValidateBoard()
	-- White Pawns
	local pawnArray = checker.whitePawns
	for p=1,#pawnArray do
		if pawnArray[p] ~= '' then
			local col = pawnArray[p]:sub( 1, 1 )
			local row = tonumber(pawnArray[p]:sub( 2 ))
			local pawn = 'w_' .. checker.columns[p]
			--print( row, col, pawn, checker.board[row][col] )
			if checker.board[col][row] ~= pawn then
				print( 'Bad White pawn on board for ' .. checker.columns[p] )
				return false
			end
		end
	end
	
	-- Black Pawns
	pawnArray = checker.blackPawns
	for p=1,#pawnArray do
		if pawnArray[p] ~= '' then
			local col = pawnArray[p]:sub( 1, 1 )
			local row = tonumber(pawnArray[p]:sub( 2 ))
			local pawn = 'l_' .. checker.columns[p]
			--print( row, col, pawn, checker.board[row][col] )
			if checker.board[col][row] ~= pawn then
				print( 'Bad Black pawn on board for ' .. checker.columns[p] )
				return false
			end
		end
	end
end

local function PrintBoard()
	edge =  ''
	for col=1,57 do
		edge = edge .. '-'
	end
	print( edge )
	for col=1,8 do
		rowpieces = '|'
		for row=1,8 do
			--print( checker.columns[row], col,checker.board[checker.columns[row]][col] )
			onSquare = checker.board[checker.columns[row]][col]
			if onSquare:len() == 1 then
				rowpieces = rowpieces .. '      '
			elseif onSquare:len() == 3 then
				rowpieces = rowpieces .. ' ' .. onSquare .. '  ' 
			else
				rowpieces = rowpieces .. ' ' .. onSquare .. ' '
			end
			rowpieces = rowpieces .. '|'			
		end
		print( rowpieces )
		print( edge )
	end
end

local function ValidateCaptureInfo( currMove, moveColor )
	capSq = currMove:match( '.*x(.*)' )
	checker.capCol = ''
	checker.capRow = 0
	checker.capColIdx = 0
	if capSq ~= nil then
		checker.capCol = capSq:sub( 1, 1 )
		checker.capRow = tonumber( capSq:sub( 2, 2 ) )
		for i=1,8 do
			if capCol == checker.columns[i] then
				checker.capColIdx = i
				break
			end
		end
		local oppColor = 'w_'
		if moveColor == 1 then
			oppColor = 'l_'
		end
		if checker.board[col][row]:find( oppColor ) == 1 then
			return true, true 
		else
			return true, false 
		end
	end
	return false
end

local function CheckPawnMove( currMove, moveColor )
	return true
end

local function CheckKnightMove( currMove, moveColor )
	return true
end

local function CheckBishopMove( currMove, moveColor )	
	return true
end

local function CheckQueenMove( currMove, moveColor )
	return true
end

local function CheckRookMove( currMove, moveColor )
	return true
end

local function CheckCastleMove( currMove, moveColor )
	return true
end

local function CheckKingMove( currMove, moveColor )
	return true
end

local function MovePawnOnBoard( currMove, moveColor )
	--print( currMove )
	newLoc = currMove:gsub( '+', '' )
	--print( newLoc )
	capCol = currMove:match( '.x' )
	capColIdx = 0
	if capCol ~= nil then
		capCol = capCol:gsub( 'x', '' )
		for i=1,8 do
			if capCol == checker.columns[i] then
				capColIdx = i
				break
			end
		end
	end
	newLoc = newLoc:gsub( '.x', '' )
	newcol = newLoc:sub( 1, 1 )
	newrow = tonumber( newLoc:sub( 2, 2 ) )
	local usingpawns
	local pawnoffset
	local pawnstart
	local pawnfirstmove
	if moveColor == 1 then
		usingpawns = checker.whitePawns
		pawnoffset = 1
		pawnstart = 2
		pawnfirstmove = 2
	else
		usingpawns = checker.blackPawns
		pawnoffset = -1
		pawnstart = 7
		pawnfirstmove = -2
	end
	for i=1,#usingpawns do
		curLoc = usingpawns[i]
		curcol = curLoc:sub( 1, 1 )
		currow = tonumber( curLoc:sub( 2, 2 ) )
		--print( curcol, currow, capCol, capColIdx, newcol, newrow )
		if capCol ~= nil then
			if capCol == curcol then print( 'Same Col' ) end
			if newrow == currow+pawnoffset then print( 'Good Row Offset' ) end
			if newcol == checker.columns[capColIdx+1] or 
				 newcol == checker.columns[capColIdx-1] then print( 'Good Col Offset' ) end
			
			if capCol == curcol and newrow == currow+pawnoffset and 
			   ( newcol == checker.columns[capColIdx+1] or 
				 newcol == checker.columns[capColIdx-1] ) then

				if moveColor == 1 then
					checker.whitePawns[i] = newLoc
				else
					checker.blackPawns[i] = newLoc
				end
				checker.board[newcol][newrow] = checker.board[curcol][currow]
				checker.board[curcol][currow] = ' '
				break
			end
		else
			if newcol == curcol and 
			   ( newrow == currow+pawnoffset or 
				 ( currow == pawnstart and newrow == currow+pawnfirstmove ) ) then
				 
				if moveColor == 1 then
					checker.whitePawns[i] = newLoc
				else
					checker.blackPawns[i] = newLoc
				end
				checker.board[newcol][newrow] = checker.board[curcol][currow]
				checker.board[curcol][currow] = ' '
				break
			end
		end
	end
end

local function MoveKnightOnBoard( currMove, moveColor )
end

local function MoveBishopOnBoard( currMove, moveColor )
end

local function MoveQueenOnBoard( currMove, moveColor )
end

local function MoveRookOnBoard( currMove, moveColor )
end

local function MoveCastleOnBoard( currMove, moveColor )
end

local function MoveKingOnBoard( currMove, moveColor )
end

-- Handler that gets notified when the alert closes
local function onInvalidMoveNotification( event )
	--print( "index => ".. event.index .. "    action => " .. event.action )
	local action = event.action
	if "clicked" == event.action then
		checker.invalidMove = event.index
	elseif "cancelled" == event.action then
		checker.invalidMove = 1
	end
end

local function GetValidButtonsForPawnMove( currMove, numbers, letters, pieces, specials )
	if currMove:match( '^[abcdefgh]$' ) ~= nil or
	   currMove:match( '^[abcdefgh]x[abcdefgh]$' ) ~= nil then
		-- just column entered or column and capture column
		print( 'Just Column' )
		for i=1,8 do
			-- enable numbers
			numbers[i] = 1
		end
		-- enable 'x' for pawn capture if there is not already an 'x'
		if currMove:find( 'x' ) == nil then
			specials[5] = 1
		end
	elseif currMove:match( '^[abcdefgh]x$' ) ~= nil then
		-- pawn capture move begun
		for i=1,8 do
			-- turn on the letter before and after capture colums letter
			print( currMove, checker.columns[i] )
			if currMove:match( '^'..checker.columns[i] ) then
				
				if i -1 > 0 then
					letters[i-1] = 1
				end
				if i + 1 < 9 then
					letters[i+1] = 1
				end
				break
			end
		end		
	elseif currMove:match( '^[abcdefgh][1234567]$' ) ~= nil or
		currMove:match( '^[abcdefgh]x[abcdefgh][12345678]$' ) ~= nil then
		-- pawn move complete, promotion if reached 1 or 8
		if currMove:match( '[18]' ) then
			specials[7] = 1
		else
			-- allow check, checkmate
			specials[4] = 1
			specials[6] = 1
		end
	elseif currMove:find( '=' ) ~= nil then
		if currMove:match( '[RNBQ]' ) == nil then
			for i=1,8 do
				-- allow promotion to piece
				pieces[i] = 1
			end
			-- can't promote to King!!
			pieces[5] = 0.5
		elseif currMove:match( '[+#]' ) == nil then
			-- Allow check or checkmate after promotion if not already entered
			specials[4] = 1
			specials[6] = 1
		end
	end
end

local function GetValidButtonsForKingQueenOrBishopMove( currMove, numbers, letters, pieces, specials )
	if currMove:match( '^[KQB]$' ) ~= nil or 
	   currMove:match( '^[KQB]x$' ) then
		for i=1,8 do
			-- enable letters
			letters[i] = 1
		end
		-- enable 'x' for capture if there is not already an 'x'
		if currMove:find( 'x' ) == nil then
			specials[5] = 1
		end
	elseif currMove:match( '^[KQB][abcdefgh]$' ) ~= nil or 
	        currMove:match( '^[KQB]x[abcdefgh]$' ) then
		for i=1,8 do
			-- enable numbers
			numbers[i] = 1
		end
	elseif ( currMove:match( '^[KQB][abcdefgh][12345678]$' ) ~= nil or 
	          currMove:match( '^[KQB]x[abcdefgh][12345678]$' ) ) and
		    currMove:match( '[+#]' ) == nil and 
			currMove:find( 'K' ) == nil then
		-- Allow check or checkmate if not already entered and not King Move
		specials[4] = 1
		specials[6] = 1
	end
end

local function GetValidButtonsForKnightOrRookMove( currMove, numbers, letters, pieces, specials )
	if currMove:match( '^[NR]$' ) ~= nil then -- letters or numbers or x
		for i=1,8 do
			-- enable letters
			letters[i] = 1
			-- enable numbers
			numbers[i] = 1
		end
		specials[5 ] = 1
	elseif currMove:match( '^[NR][abcdefgh]$' ) ~= nil then -- numbers or x
		for i=1,8 do
			-- enable numbers
			numbers[i] = 1
		end
		specials[5 ] = 1			
	elseif currMove:match( '^[NR][12345678]$' ) ~= nil then -- letters or x
		for i=1,8 do
			-- enable letters
			letters[i] = 1
		end
		specials[5 ] = 1			
	elseif currMove:match( '^[NR][abcdefgh]x$' ) ~= nil or --letters
	        currMove:match( '^[NR][12345678]x$' ) ~= nil or -- letters
		    currMove:match( '^[NR]x$' ) then -- letters
		for i=1,8 do
			-- enable letters
			letters[i] = 1
		end
	elseif currMove:match( '^[NR][abcdefgh]x[abcdefgh]$' ) ~= nil or --numbers
		    currMove:match( '^[NR][12345678]x[abcdefgh]$' ) ~= nil or -- numbers
			currMove:match( '^[NR][12345678][abcdefgh]$' ) ~= nil or -- numbers
			currMove:match( '^[NR]x[abcdefgh]$' ) ~= nil then -- numbers
		for i=1,8 do
			-- enable numbers
			numbers[i] = 1
		end
	elseif currMove:match( '^[NR][abcdefgh][12345678]$' ) ~= nil or -- specials
			currMove:match( '^[NR]x[abcdefgh][12345678]$' ) ~= nil or -- specials
		    currMove:match( '^[NR][abcdefgh]x[abcdefgh][12345678]$' ) ~= nil or --specials
			currMove:match( '^[NR][12345678][abcdefgh][12345678]$' ) ~= nil or -- specials
			currMove:match( '^[NR][12345678]x[abcdefgh][12345678]$' ) ~= nil and -- specials
			currMove:match( '[#+]' ) == nil then
		-- Allow check or checkmate if not already entered and not King Move
		specials[4] = 1
		specials[6] = 1
	end
end

checker.GetValidButtonList = function( currMove, moveColor )
	local numbers = {}
	local letters = {}
	local pieces = {}
	local specials = {}

	-- Turn everything off
	for i=1,8 do
		numbers[i] = 0.5
		letters[i] = 0.5
		pieces[i] = 0.5
		specials[i] = 0.5
	end

	if currMove == '' then
		-- blank move
		for i=1,8 do
			-- enable letters (pawn move)
			letters[i] = 1
			-- enable pieces (piece move)
			pieces[i] = 1
			-- enable specials (castling move)
			if i == 1 or i == 8 then
				specials[i] = 1
			end
		end
	elseif currMove:match( '^[abcdefgh]' ) ~= nil then
		--pawn move 
		print( 'Pawn Move: ' .. currMove )	
		GetValidButtonsForPawnMove( currMove, numbers, letters, pieces, specials )
			
	elseif currMove:match( '^Q' ) ~= nil then
		print( 'Queen Move: ' .. currMove )
		GetValidButtonsForKingQueenOrBishopMove( currMove, numbers, letters, pieces, specials )
	elseif currMove:match( '^R' ) ~= nil then
		print( 'Rook Move: ' .. currMove )
		GetValidButtonsForKnightOrRookMove( currMove, numbers, letters, pieces, specials )
	elseif currMove:match( '^B' ) ~= nil then
		print( 'Bishop Move: ' .. currMove )
		GetValidButtonsForKingQueenOrBishopMove( currMove, numbers, letters, pieces, specials )
	elseif currMove:match( '^N' ) ~= nil then
		print( 'Knight Move: ' .. currMove )
		GetValidButtonsForKnightOrRookMove( currMove, numbers, letters, pieces, specials )
	elseif currMove:match( '^K' ) ~= nil then
		print( 'King Move: ' .. currMove )
		GetValidButtonsForKingQueenOrBishopMove( currMove, numbers, letters, pieces, specials )
	elseif currMove:match( '^0' ) ~= nil then
		print( 'Castling Move' )
	end
	return numbers, letters, pieces, specials
end

checker.CheckCurrMove = function( currMove, moveColor )
	print( 'Checking Move ' .. currMove )
	if currMove == '' then
		native.showAlert( "Error", "Invalid Move", { "OK", "Ignore", "Always Ignore" }, onInvalidMoveNotification )
		if invalidMove == 0 then
			return false
		end
	end
	hasCap, isValid = ValidateCaptureInfo( currMove, moveColor )
	if hasCap and not isValid then
		return false
	end
	ValidateBoard()
	PrintBoard()
	-- pawn move?
	if currMove:match( '^[abcdefgh]' ) ~= nil then
		print( 'Pawn Move' )
		if CheckPawnMove( currMove, moveColor ) then
			MovePawnOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^N' ) ~= nil then
		print( 'Knight Move' )
		if CheckKnightMove( currMove, moveColor ) then
			MoveKnightOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^B' ) ~= nil then
		print( 'Bishop Move' )
		if CheckBishopMove( currMove, moveColor ) then
			MoveBishopOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^Q' ) ~= nil then
		print( 'Queen Move' )
		if CheckQueenMove( currMove, moveColor ) then
			MoveQueenOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^R' ) ~= nil then
		print( 'Rook Move' )
		if CheckRookMove( currMove, moveColor ) then
			MoveRookOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^0' ) ~= nil then
		print( 'Castle Move' )
		if CheckCastleMove( currMove, moveColor ) then
			MoveCastleOnBoard( currMove, moveColor )
			return true
		end
	elseif currMove:match( '^K' ) ~= nil then
		print( 'King Move' )
		if CheckKingMove( currMove, moveColor ) then
			MoveKingOnBoard( currMove, moveColor )
			return true
		end
	end
	--PrintBoard()
	return false
end

return checker



		-- can't move pieces
--~ 		pieces[1] = 0.5
--~ 		pieces[2] = 0.5
--~ 		pieces[5] = 0.5
--~ 		pieces[6] = 0.5
--~ 		-- can't move king stuff
--~ 		kings[1] = 0.5
--~ 		kings[2] = 0.5
--~ 		kings[3] = 0.5
--~ 		print( currMove )
--~ 		if string.len(currMove) == 1 then
--~ 			--just selected the file
--~ 			print( 'Just File' )
--~ 			-- all rows and files are invalid
--~ 			for i=1,8 do
--~ 				letters[i] = 0.5
--~ 				numbers[i] = 0.5
--~ 			end
--~ 			-- check and capture are possible
--~ 			pieces[3] = 1
--~ 			pieces[4] = 1
--~ 			--find where any pawn on the file can go
--~ 			if moveColor == 1 then
--~ 				--white pawn
--~ 				for i=1,#checker.whitePawns do
--~ 					--print( checker.whitePawns[i], currMove )
--~ 					--print( checker.whitePawns[i]:find(currMove) )
--~ 					if checker.whitePawns[i]:find(currMove) == 1 then
--~ 						row = tonumber( string.sub( checker.whitePawns[i], 2, 2 ) )
--~ 						--print( row )
--~ 						if row == 2 then
--~ 							numbers[4] = 1
--~ 							print( '4' )
--~ 						end
--~ 						numbers[row+1] = 1
--~ 						--print( row + 1 )
--~ 					end
--~ 				end
--~ 			else
--~ 				--black pawn
--~ 				for i=1,#checker.blackPawns do
--~ 					if checker.blackPawns[i]:find(currMove) == 1 then
--~ 						row = tonumber( string.sub( checker.blackPawns[i], 2, 2 )  )
--~ 						if row == 7 then
--~ 							numbers[5] = 1
--~ 							--print( '5' )
--~ 						end
--~ 						numbers[row - 1] = 1
--~ 						--print( i - 1 )
--~ 					end
--~ 				end
--~ 			end
--~ 		else
--~ 			
--~ 		end
