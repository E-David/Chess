module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
		end

		def coordinate_board
			grid.each_with_index do |row,row_index| 
				row.each_with_index do |square,column_index|
					square.coordinate = [row_index,column_index]
				end
			end
		end

		def colorize_board
			grid.flatten.each_with_index { |square, index| index.odd? ? square.color = "black" : square.color = "white" }
		end

		def get_square(coordinate)
			grid[coordinate[0]][coordinate[1]]
		end

		def get_piece(coordinate)
			get_square(coordinate).value
		end

		def set_square(coordinate,piece)
			get_square(coordinate).value = piece
		end

		def is_unoccupied?(coordinate)
			get_square(coordinate).value == ""
		end

		def is_enemy?(move_from,move_to)
			get_square(move_from).color != get_square(move_to).color
		end

		def is_valid_move?(move_from, move_to)
			valid_moves = get_piece(move_from).valid_moves
			valid_moves.include? (move_to)
		end

		def horizontal_movement_check(move_from, move_to)
			row = move_from[0]
			col = move_from[1]
			until col == move_to[1]
				col > move_to[1] ? col -= 1 : col += 1
				break if is_unoccupied?([row,col]) == false
			end
			return is_unoccupied?([row,col])
		end

		def vertical_movement_check(move_from, move_to)
			row = move_from[0]
			col = move_from[1]
			until row == move_to[0]
				row > move_to[0] ? row -= 1 : row += 1
				break if is_unoccupied?([row,col]) == false
			end
			return is_unoccupied?([row,col])
		end

		def diagonal_movement_check(move_from, move_to)
			row = move_from[0]
			col = move_from[1]
			until (row == move_to[0]) && (col == move_to[1])
				row > move_to[0] ? row -= 1 : row += 1
				col > move_to[1] ? col -= 1 : col += 1
				break if is_unoccupied?([row,col]) == false
			end
			return is_unoccupied?([row,col])
		end

		def direction_check(move_from, move_to)
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				return diagonal_movement_check(move_from,move_to)
			else
				move_from[0] != move_to[0] ? (return vertical_movement_check) : (return horizontal_movement_check)
			end
		end

		def check_move(move_from, move_to)
			if is_valid_move?(move_from, move_to)
				if (is_unoccupied?(move_to) || is_enemy?(move_from,move_to))
					true
				else
					false
				end
			end
		end

		def game_over
			return :winner if winner?
			return :draw if draw?
			false
		end

		private

		def default_board
			Array.new(8) { Array.new(8) { Square.new } }
		end
	end
end