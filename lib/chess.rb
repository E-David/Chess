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
x.load_previous_move([1,1])
x.load_previous_move([5,5])
p x.get_piece([1,1])
p x.get_piece([5,5])
x.move_piece([1,1],[5,5])
p x.get_piece([1,1])
p x.get_piece([5,5])
x.reset
p x.get_piece([1,1])
p x.get_piece([5,5])
