require_relative "./chess/version"

module Chess
	require_relative "./chess/square.rb"
	require_relative "./chess/board.rb"
	require_relative "./chess/player.rb"
	require_relative "./chess/pawn.rb"
	require_relative "./chess/game.rb"
	require_relative "./chess/core_extensions.rb"
end

x = Chess::Board.new
p x.check_move([1,1],[2,1])
p x.check_move([1,1],[2,0])
p x.check_move([1,1],[2,2])
p x.check_move([2,0],[1,0])
p x.check_move([2,0],[1,1])
p x.check_move([2,1],[1,1])