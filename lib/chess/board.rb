module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
		end

		def test_board
			set_square([1,1], Pawn.new("black",[1,1]))
			set_square([2,1], Pawn.new("white",[2,1]))
			set_square([2,0], Pawn.new("white",[2,0]))
			set_square([2,2], Pawn.new("white",[2,2]))
			set_square([1,3], Pawn.new("white",[1,3]))
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
			unhindered = true
			until col == move_to[1]
				col > move_to[1] ? col -= 1 : col += 1
				if is_unoccupied?([row,col]) == false && col != move_to[1]
					unhindered = false
					break
				end
			end
			return unhindered
		end

		def vertical_movement_check(move_from, move_to)
			row = move_from[0]
			col = move_from[1]
			unhindered = true
			until row == move_to[0]
				row > move_to[0] ? row -= 1 : row += 1
				if is_unoccupied?([row,col]) == false && row != move_to[0]
					unhindered = false
					break
				end
			end
			return unhindered
		end

		def diagonal_movement_check(move_from, move_to)
			row = move_from[0]
			col = move_from[1]
			unhindered = true
			until (row == move_to[0]) && (col == move_to[1])
				row > move_to[0] ? row -= 1 : row += 1
				col > move_to[1] ? col -= 1 : col += 1
				if is_unoccupied?([row,col]) == false && col != move_to[1] && row != move_to[0]
					unhindered = false
					break
				end
			end
			return unhindered
		end

		def direction_check(move_from, move_to)
			return diagonal_movement_check(move_from,move_to) if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
			return vertical_movement_check(move_from,move_to) if move_from[0] != move_to[0] 
			return horizontal_movement_check(move_from,move_to) if move_from[1] != move_to[1]
			raise "Movement Error"
		end

		def check_move(move_from, move_to)
			message = "good move"
			unless is_valid_move?(move_from, move_to)
				message = "Invalid move"
				
			end
			unless !is_enemy?(move_from,move_to)
				message = "Allied piece"
				
			end
			unless direction_check(move_from,move_to)
				message = "Hindered movement"
				
			end
			p message
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