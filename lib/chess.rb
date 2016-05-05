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
x.coordinate_board
p x.get_square([7,1])