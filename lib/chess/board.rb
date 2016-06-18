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

		def ally_pieces(color)
			ally_pieces = all_pieces.select { |piece| piece.color == color }
			ally_pieces
		end

		def enemy_pieces(color)
			enemy_pieces = all_pieces.select { |piece| piece.color != color }
			enemy_pieces
		end

		def get_king(color)
			all_pieces.each { |piece| return piece if piece.piece_name == "King" && piece.color == color }
		end

		def get_all_check_pieces(color)
			king = get_king(color)
			enemy_pieces(color).each { |piece| piece.valid_moves.include?(king.position) }
		end

		def get_valid_check_pieces(color)
			all_check_pieces = get_all_check_pieces(color)
			king = get_king(color)
			all_check_pieces.select { |piece| check_move(piece.position,king.position) == true }
		end

		def get_check_paths(color)
			valid_check_pieces = get_valid_check_pieces(color)
			king = get_king(color)
			check_paths = []
			valid_check_pieces.each { |piece| check_paths << get_path(piece.position,king.position) }
			check_paths.each { |path| path.delete_if { |x| x == king.position } }
		end

		def check?(color)
			get_check_paths(color).count >= 1
		end

		def block_check_path(color,path)
			ally_pieces = ally_pieces(color)
			p path
			ally_pieces.select do |piece|
				p piece if !(piece.valid_moves & path).nil?
			end
		end

		def king_trapped?(king)
			open_moves = king.valid_moves.select { |move| check_move(king.position,move) && is_unoccupied?(move) }
			open_moves.empty?
		end

		def set_square(coordinate,piece)
			get_square(coordinate).value = piece
		end

		def is_unoccupied?(coordinate)
			get_square(coordinate).value == ""
		end

		def is_ally?(move_from,move_to)
			return false if is_unoccupied?(move_to)
			get_piece(move_from).color == get_piece(move_to).color
		end

		def is_valid_move?(move_from,move_to)
			piece = get_piece(move_from)
			piece.valid_moves.include?(move_to)
		end

		def is_knight?(coordinate)
			piece = get_piece(coordinate)
			piece.piece_name == "Knight"
		end

		def is_pawn?(coordinate)
			piece = get_piece(coordinate)
			piece.piece_name == "Pawn"
		end

		# check if piece is moving diagonally. If yes, returns if destination is occupied and an enemy
		def pawn_path(move_from,move_to)
			path = [move_from]
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				if is_unoccupied?(move_to) == false && is_ally?(move_from,move_to) == false
					path << [move_to]
				end
			else 
				path = horizontal_path(move_from,move_to)
			end
		end

		def horizontal_path(move_from, move_to)
			path = [move_from]
			column = move_from[1]
			until column == move_to[1]
				column > move_to[1] ? column -= 1 : column += 1
				path << [move_from[0],column]
				if is_unoccupied?([move_from[0],column]) == false
					break
				end
			end
			path
		end

		def vertical_path(move_from, move_to)
			path = [move_from]
			row = move_from[0]
			until row == move_to[0]
					row > move_to[0] ? row -= 1 : row += 1
					path << [row,move_from[1]]
					if is_unoccupied?([row,move_from[1]]) == false
						break
					end
				end
			path
		end

		def diagonal_path(move_from, move_to)
			path = [move_from]
			row = move_from[0]
			column = move_from[1]
			until (row == move_to[0]) && (column == move_to[1])
				row > move_to[0] ? row -= 1 : row += 1
				column > move_to[1] ? column -= 1 : column += 1
				path << [row,column]
				if is_unoccupied?([row,column]) == false
					break
				end
			end
			path
		end

		def get_path(move_from,move_to)
			path = []
			if is_knight?(move_from) 
				path = move_to
			elsif is_pawn?(move_from)
				path = pawn_path(move_from,move_to)
			elsif (move_from[0] != move_to[0] && move_from[1] != move_to[1]) && !is_pawn?(move_from)
				path = diagonal_path(move_from,move_to)
			elsif move_from[1] != move_to[1]
				path = horizontal_path(move_from,move_to)
			elsif move_from[0] != move_to[0]
				path = vertical_path(move_from,move_to)
			else
				puts "Movement Error"
			end
			path
		end

		def move_unhindered?(move_from,move_to)
			path = get_path(move_from,move_to)
			path.last == move_to
		end

		def check_move(move_from, move_to)
			return "Invalid move" if is_valid_move?(move_from,move_to) == false
			return "Target destination is an ally" if is_ally?(move_from,move_to)
			return "Move is blocked by another piece" if move_unhindered?(move_from,move_to) == false
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