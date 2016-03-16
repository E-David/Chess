module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
		end

		private

		def default_board
			white = Cell.new("", "white")
			black = Cell.new("", "black")
			#top_row = Array.new(8) { 4 * white,black }
		end
	end
end


white = "white"
black = "black"
top_row = [white,black,white,black,white,black,white,black]
board = [top_row,top_row.reverse]
p board