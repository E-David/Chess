module Chess
	class Board
		attr_reader :grid
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
			setup_board
		end

		def to_s
			string = ""
			grid.each do |row| 
				row.each do |square| 
					string += square.to_s
					string += ", " if square.value != ""
					string += square.value.to_s
					string += "\n"
				end
			end
			return string
		end

		def setup_board
			coordinate_board
			colorize_board
			setup_pawns
			setup_back_rows
		end

		def setup_pawns
			(0..7).each do |col| 
				set_square([1,col], Pawn.new("black",[1,col]))
				set_square([6,col], Pawn.new("white",[6,col]))
			end
		end

		def setup_back_rows
			(0..7).each do |col| 
				case col 
				when 0 
					set_square([0,col], Rook.new("black",[0,col])) ; set_square([7,col], Rook.new("white",[7,col]))
				when 1
					set_square([0,col], Knight.new("black",[0,col])) ; set_square([7,col], Knight.new("white",[7,col]))
				when 2
					set_square([0,col], Bishop.new("black",[0,col])) ; set_square([7,col], Bishop.new("white",[7,col]))
				when 3
					set_square([0,col], Queen.new("black",[0,col])) ; set_square([7,col], Queen.new("white",[7,col]))
				when 4
					set_square([0,col], King.new("black",[0,col])) ; set_square([7,col], King.new("white",[7,col]))
				when 5
					set_square([0,col], Bishop.new("black",[0,col])) ; set_square([7,col], Bishop.new("white",[7,col]))
				when 6
					set_square([0,col], Knight.new("black",[0,col])) ; set_square([7,col], Knight.new("white",[7,col]))
				when 7
					set_square([0,col], Rook.new("black",[0,col])) ; set_square([7,col], Rook.new("white",[7,col]))
				end
			end
		end

		def coordinate_board
			grid.each_with_index do |row,row_index| 
				row.each_with_index do |square,column_index|
					square.coordinate = [row_index,column_index]
				end
			end
		end

		def colorize_board
			grid.each_with_index do |row, row_index| 
				row.each_with_index do |square, col_index|
					if row_index.even?
						col_index.even? ? square.color = "black" : square.color = "white"
					else
						col_index.even? ? square.color = "white" : square.color = "black"
					end
				end
			end
		end

		def display_board
			grid.each do |row|
				display = ""
				row.each do |square|
					piece_display = square.value == "" ? "  " : square.value.unicode_char
					display += square.color == "black" ? "I #{piece_display} I" : "| #{piece_display} |"
				end
				puts display
			end
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
			#if get_piece(move_from).piece_name == "Pawn"
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