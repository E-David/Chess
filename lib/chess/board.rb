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

		def all_pieces
			all_pieces = []
			grid.each do |row|
				filled_squares = []
				filled_squares = row.select { |square| square.value != ""}
				filled_squares.each { |square| all_pieces << square.value}
			end
			all_pieces
		end

		def all_moves
			all_moves = []
			all_pieces.each { |piece| piece.valid_moves.each { |move| all_moves << move if !all_moves.include?(move)}}
			all_moves.sort
		end

		def get_kings
			king_positions = []
			all_pieces.each { |piece| king_positions << piece.position if piece.piece_name == "King" }
			king_positions
		end

		def check(king_position)
			attacking_pieces = all_pieces.select { |piece| piece.valid_moves.include?(king_position) }
			attacking_pieces.any? { |piece| check_move(piece.position,king_position) == true }
		end

		def checkmate(king)
			king.valid_moves.any? { |move| check(move) == false } ? "YOU DON'T LOSE" : "YOU LOSE"
		end

		def game_done(king)
			king_position = king.position
			if check(king_position)
				p "UH OH"
				p checkmate(king)
			end
		end

		def is_unoccupied?(coordinate)
			get_square(coordinate).value == ""
		end

		def is_enemy?(move_from,move_to)
			get_piece(move_from).color != get_piece(move_to).color
		end

		def is_valid_move?(move_from,move_to)
			piece = get_piece(move_from)
			if piece.piece_name == "Pawn"
				pawn_diagonal_check(move_from,move_to) 
			else
				piece.valid_moves.include?(move_to)
			end
		end

		def is_knight?(coordinate)
			piece = get_piece(coordinate)
			return piece.piece_name == "Knight"
		end

		# 1. check if movement is in a different row ([0]) and column ([1]), supplied by is_valid_move? method
		# 2. If not, pawn is going forward, check that move is valid and unhindered
		def pawn_diagonal_check(move_from,move_to)
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				is_enemy?(move_from,move_to)
			else
				get_piece(move_from).valid_moves.include?(move_to) && is_unoccupied?(move_to)
			end
		end

		def path_check(move_from,move_to,direction)
			row = move_from[0]
			col = move_from[1]
			unhindered = true
			case direction
			when "horizontal"
				until col == move_to[1]
					col > move_to[1] ? col -= 1 : col += 1
					if is_unoccupied?([row,col]) == false && col != move_to[1]
						unhindered = false
						break
					end
				end
			when "vertical"
				until row == move_to[0]
					row > move_to[0] ? row -= 1 : row += 1
					if is_unoccupied?([row,col]) == false && row != move_to[0]
						unhindered = false
						break
					end
				end
			when "diagonal"
				until (row == move_to[0]) && (col == move_to[1])
					row > move_to[0] ? row -= 1 : row += 1
					col > move_to[1] ? col -= 1 : col += 1
					if is_unoccupied?([row,col]) == false && col != move_to[1] && row != move_to[0]
						unhindered = false
						break
					end
				end
			end
			return unhindered
		end

		def direction_check(move_from, move_to)
			return true if is_knight?(move_from)
			return path_check(move_from,move_to,"diagonal") if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
			return path_check(move_from,move_to,"vertical") if move_from[0] != move_to[0] 
			return path_check(move_from,move_to,"horizontal") if move_from[1] != move_to[1]
			raise "Movement Error"
		end

		def check_move(move_from, move_to)
			return "Invalid move" if is_valid_move?(move_from,move_to) == false
			return "Target destination is an ally" if (is_unoccupied?(move_to) == false && is_enemy?(move_from,move_to) == false)
			return "Move is blocked by another piece" if (direction_check(move_from,move_to) == false)
			true
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