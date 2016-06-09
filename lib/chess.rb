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
x.set_square([2,4], Chess::Pawn.new("black",[2,4]))
king = x.get_king("white")[0]
puts x.check_move([2,4],[3,4])