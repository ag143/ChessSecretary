local checker = {}

checker.whitePawns = { 'a2', 'b2', 'c2', 'd2','e2','f2','g2','h2'}
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
checker.whitePieces = 
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

--checker.board = --Rows
--{
--	[1] = { 'w_Ra', 'w_Kb','w_Bc','','','','l_a','l_Ra' },
--}


checker.CheckCurrMove = function( currMove)
	print( 'Checking Move' .. currMove )
	if currMove == '' then
		return false
	end
	return true
end

return checker