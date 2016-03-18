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
<<<<<<< HEAD
			white_first = [white,black,white,black,white,black,white,black]
			black_first = white_first.reverse
			[white_first,black_first,white_first,black_first,white_first,black_first,white_first,black_first,]
		end
	end
end
=======
			#top_row = Array.new(8) { 4 * white,black }
		end
	end
end


white = "white"
black = "black"
top_row = [white,black,white,black,white,black,white,black]
board = [top_row,top_row.reverse]
p board
>>>>>>> create-board-class
