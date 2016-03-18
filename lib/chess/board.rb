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
			white_first = [white,black,white,black,white,black,white,black]
			black_first = white_first.reverse
			[white_first,black_first,white_first,black_first,white_first,black_first,white_first,black_first,]
		end
	end
end