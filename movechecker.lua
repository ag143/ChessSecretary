local checker = {}

checker.invalidMove = 0
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
checker.board = --Rows
{
	a = {	'w_Ra', 'w_a', ' ',' ',' ',' ', 'l_a', 'l_Ra' },
	b = {	'w_Nb', 'w_b', ' ',' ',' ',' ', 'l_b', 'l_Nb' },
	c = {	'w_Bc', 'w_c', ' ',' ',' ',' ', 'l_c', 'l_Bc' },
	d = {	'w_Q',  'w_d', ' ',' ',' ',' ', 'l_d', 'l_Q' },
	e = {	'w_K',  'w_e', ' ',' ',' ',' ', 'l_e', 'l_K' },
	f = {	'w_Bf', 'w_f', ' ',' ',' ',' ', 'l_f', 'l_Bf' },
	g = {	'w_Ng', 'w_g', ' ',' ',' ',' ', 'l_g', 'l_Ng' },
	h = {	'w_Rh', 'w_h', ' ',' ',' ',' ', 'l_h', 'l_Rh' },
}

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

local function MovePawnOnBoard( currMove, moveColor )
	print( currMove )
	newLoc = currMove:gsub( '+', '' )
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
		print( curcol, currow, capCol, capColIdx, newcol, newrow )
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

checker.GetValidButtonList = function( currMove, moveColor )
	local numbers = {}
	local letters = {}
	local pieces = {}
	local kings = {}

	for i=1,8 do
		numbers[i] = 1
		letters[i] = 1
		if i < 7 then
			pieces[i] = 1
			if i < 4 then
				kings[i] = 1
			end
		end
	end
	
	--pawn move?
	if currMove:match( '^[abcdefgh]' ) ~= nil then
		print( 'Pawn Move' )
		-- can't move pieces
		pieces[1] = 0.5
		pieces[2] = 0.5
		pieces[5] = 0.5
		pieces[6] = 0.5
		-- can't move king stuff
		kings[1] = 0.5
		kings[2] = 0.5
		kings[3] = 0.5
		print( currMove )
		if string.len(currMove) == 1 then
			--just selected the file
			print( 'Just File' )
			-- all rows and files are invalid
			for i=1,8 do
				letters[i] = 0.5
				numbers[i] = 0.5
			end
			-- check and capture are possible
			pieces[3] = 1
			pieces[4] = 1
			--find where any pawn on the file can go
			if moveColor == 1 then
				--white pawn
				for i=1,#checker.whitePawns do
					--print( checker.whitePawns[i], currMove )
					--print( checker.whitePawns[i]:find(currMove) )
					if checker.whitePawns[i]:find(currMove) == 1 then
						row = tonumber( string.sub( checker.whitePawns[i], 2, 2 ) )
						--print( row )
						if row == 2 then
							numbers[4] = 1
							print( '4' )
						end
						numbers[row+1] = 1
						--print( row + 1 )
					end
				end
			else
				--black pawn
				for i=1,#checker.blackPawns do
					if checker.blackPawns[i]:find(currMove) == 1 then
						row = tonumber( string.sub( checker.blackPawns[i], 2, 2 )  )
						if row == 7 then
							numbers[5] = 1
							--print( '5' )
						end
						numbers[row - 1] = 1
						--print( i - 1 )
					end
				end
			end
		else
			
		end
	end
	return numbers, letters, pieces, kings
end

checker.CheckCurrMove = function( currMove, moveColor )
	print( 'Checking Move' .. currMove )
	if currMove == '' then
		native.showAlert( "Error", "Invalid Move", { "OK", "Ignore", "Always Ignore" }, onInvalidMoveNotification )
		if invalidMove == 0 then
			return false
		end
	end
	PrintBoard()
	-- pawn move?
	if currMove:match( '^[abcdefgh]' ) ~= nil then
		MovePawnOnBoard( currMove, moveColor )
	end
	PrintBoard()
	return true
end

return checker