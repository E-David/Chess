require_relative "./chess/version"

module Chess
	require_relative "./chess/square.rb"
	require_relative "./chess/board.rb"
	require_relative "./chess/player.rb"
	require_relative "./chess/piece.rb"
	require_relative "./chess/game.rb"
	require_relative "./chess/core_extensions.rb"
end

x = Chess::Board.new
x.set_square([3,4], Chess::King.new("white",[3,4]))
x.set_square([3,0], Chess::Queen.new("black",[3,0]))
x.set_square([4,0], Chess::Queen.new("white",[4,0]))
king = x.get_piece([3,4])
x.king_trapped?("white")