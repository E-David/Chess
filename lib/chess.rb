require "./chess/version"

module Chess
	require_relative "./chess/square.rb"
	require_relative "./chess/board.rb"
	require_relative "./chess/player.rb"
	require_relative "./chess/pawn.rb"
	require_relative "./chess/game.rb"
end

x = Chess::Board.new
x.grid.each {|row| row.each { |square| square.to_s} }