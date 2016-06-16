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
x.set_square([2,3], Chess::King.new("black",[2,3]))
x.set_square([3,0], Chess::Queen.new("black",[3,0]))
#puts x.check_move([3,4],[2,3])
p x.check_move([3,4],[2,3])