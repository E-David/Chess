module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
			colorize_board
			coordinate_board
			set_up_board
		end

		def coordinate_board
			grid.each_with_index do |row,row_index| 
				row.each_with_index do |square,column_index|
					square.x_coord = row_index
					square.y_coord = column_index
				end
			end
		end

		def colorize_board
			grid.flatten.each_with_index { |square, index| index.odd? ? square.color = "black" : square.color = "white" }
		end

		def set_up_board
			pawn = Pawn.new("white",[6,1])
			set_square(0,1,pawn)
		end

		def get_square(x,y)
			grid[x][y]
		end

		def set_square(x,y,piece)
			get_square(x,y).value = piece
		end

		def is_occupied?
			self.value != ""
		end

		def is_enemy?(x_coord,y_coord)
			square = get_square(x_coord,y_coord)
			self.color == square.value.color
		end


		def game_over
			return :winner if winner?
			return :draw if draw?
			false
		end

		private

		def default_board
			Array.new(7) { Array.new(7) { Square.new("","",0,0) } }
		end
	end
end