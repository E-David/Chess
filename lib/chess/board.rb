module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
		end

		def get_square(x,y)
			grid[x][y]
		end

		def set_square(x,y,piece)
			get_square(x,y).value = piece
		end

		def game_over
			return :winner if winner?
			return :draw if draw?
			false
		end

		private

		def default_board
			white = Cell.new("", "white")
			black = Cell.new("", "black")
			white_first = [white,black,white,black,white,black,white,black]
			black_first = white_first.reverse
			[white_first,black_first,white_first,black_first,white_first,black_first,white_first,black_first,]
		end
	end
end
