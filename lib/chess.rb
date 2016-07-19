require_relative "./chess/version"

module Chess
	require_relative "./chess/square.rb"
	require_relative "./chess/board.rb"
	require_relative "./chess/player.rb"
	require_relative "./chess/piece.rb"
	require_relative "./chess/game.rb"
	require_relative "./chess/core_extensions.rb"
	require_relative "./chess/file_save.rb"
end

Chess::Game.new
#x = Chess::Board.new
#x.load_pieces([5,5], "Rook", "black")
#p x.get_piece([5,5])