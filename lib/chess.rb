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
x.set_square([0,2], Chess::King.new("white",[0,2]))
king = x.get_king("white")[0]
p x.check(king)