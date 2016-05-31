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

		def all_pieces
			all_pieces = []
			grid.each { |row| row.each { |square| all_pieces << square.value if square.value != "" }}
			all_pieces
		end

		def get_king(color)
			all_pieces.select { |piece| piece.piece_name == "King" && piece.color == color }
		end

		def check(king)
			king.check_moves.any? do |move| 
				if is_enemy?(king.position,move)
					if is_valid_move?(move,king.position)
						direction_check(move,king.position)
					end					
				end
			end
		end

		def set_square(coordinate,piece)
			get_square(coordinate).value = piece
		end

		def is_unoccupied?(coordinate)
			get_square(coordinate).value == ""
		end

		def is_enemy?(move_from,move_to)
			return false if is_unoccupied?(move_to)
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

		def is_knight?(coordinate)
			piece = get_piece(coordinate)
			return piece.piece_name == "Knight"
		end

		def is_pawn?(coordinate)
			piece = get_piece(coordinate)
			return piece.piece_name == "Pawn"
		end

		# 1. check if movement is in a different row ([0]) and column ([1]), supplied by is_valid_move? method
		# 2. If not, pawn is going forward, check that move is valid and unhindered
		def pawn_diagonal_check(move_from,move_to)
			pawn = get_piece(move_from)
			return false if pawn.valid_moves.include?(move_to) == false
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				is_enemy?(move_from,move_to)
			else
				is_unoccupied?(move_to)
			end
		end

		def horizontal_path(row_from,col_from,col_to)
			unhindered = true
			until col_from == col_to
					col_from > col_to ? col_from -= 1 : col_from += 1
					if is_unoccupied?([row_from,col_from]) == false && col_from != col_to
						unhindered = false
						break
					end
				end
			return unhindered
		end

		def vertical_path(row_from,col_from,row_to)
			unhindered = true
			until row_from == row_to
					row_from > row_to ? row_from -= 1 : row_from += 1
					if is_unoccupied?([row_from,col_from]) == false && row_from != row_to
						unhindered = false
						break
					end
				end
			return unhindered
		end

		def diagonal_path(row_from,col_from,row_to,col_to)
			unhindered = true
			until (row_from == row_to) && (col_from == col_to)
				row_from > row_to ? row_from -= 1 : row_from += 1
				col_from > col_to ? col_from -= 1 : col_from += 1
				if is_unoccupied?([row_from,col_from]) == false && col_from != col_to && row_from != row_to
					unhindered = false
					break
				end
			end
			return unhindered
		end

		def direction_check(move_from, move_to)
			row_from = move_from[0]
			col_from = move_from[1]
			row_to = move_to[0]
			col_to = move_to[1]
			return true if is_knight?(move_from)
			return diagonal_path(row_from,col_from,row_to,col_to) if (row_from != row_to && col_from != col_to)
			return vertical_path(row_from,col_from,row_to) if row_from != row_to 
			return horizontal_path(row_from,col_from,row_to) if col_from != col_to
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