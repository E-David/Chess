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
x.display_board
=begin
x = Chess::Board.new
x.load_original_squares([5,5])
p x.previous_move
x.set_square([5,5],   Chess::King.new("black",[5,5]))
p x.previous_move
=end