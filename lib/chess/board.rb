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
			valid_check_pieces.each do |piece|
				direction_check(piece.position,king.position)
			end
			check_paths
		end

		def check?(color)
			get_check_paths(color).count >= 1
		end

		def can_block_check?(color)
			check_paths = get_check_paths(color)
			ally_pieces = ally_pieces(color)
			ally_pieces.each do |piece|
				check_paths.each do |path|
					if piece.valid_moves.include?(path)
						puts piece
					end
				end
			end			
			p check_paths
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

		def is_enemy?(move_from,move_to)
			get_piece(move_from).color != get_piece(move_to).color
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

		# 1. check if movement is in a different row ([0]) and column ([1])
		# 2. If not, pawn is going forward, check that move is valid and unhindered
		def pawn_diagonal_check(move_from,move_to)
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				is_enemy?(move_from,move_to)
			end
		end

		def horizontal_path(move_from, move_to)
			path = []
			until move_from[1] == move_to[1]
					move_from[1] > move_to[1] ? move_from[1] -= 1 : move_from[1] += 1
					path << [move_from]
					if is_unoccupied?([move_from]) == false
						break
					end
				end
			path
		end

		def vertical_path(move_from, move_to)
			path = []
			until move_from[0] == move_to[0]
					move_from[0] > move_to[0] ? move_from[0] -= 1 : move_from[0] += 1
					path << [move_from]
					if is_unoccupied?([move_from]) == false
						break
					end
				end
			path
		end

		def diagonal_path(move_from, move_to)
			path = []
			until (move_from[0] == move_to[0]) && (move_from[1] == move_to[1])
				move_from[0] > move_to[0] ? move_from[0] -= 1 : move_from[0] += 1
				move_from[1] > move_to[1] ? move_from[1] -= 1 : move_from[1] += 1
				path << [move_from]
				if is_unoccupied?([move_from]) == false
					break
				end
			end
			path
		end

		def direction_check(move_from, move_to)
			direction = ""
			if is_knight?(move_from) 
				direction = "knight"
			elsif (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				direction = "diagonal"
			elsif move_from[0] != move_to[0]
				direction = "vertical"
			elsif move_from[1] != move_to[1]
				direction = "horizontal"
			else
				puts "Movement Error"
			end
			direction
		end

		def move_unhindered?(move_from,move_to,direction)
			final_move = []
			case direction
			when "knight"
				final_move = move_to
			when "pawn"
				final_move = move_to if pawn_diagonal_check(move_from,move_to)
			when "horizontal"
				final_move = horizontal_path(move_from,move_to).last
			when "vertical"
				final_move = vertical_path(move_from,move_to).last
			when "diagonal"
				final_move = diagonal_path(move_from,move_to).last
			else
				puts "Movement Error"
			end
			final_move == move_to
		end

		def check_move(move_from, move_to)
			return true if is_unoccupied?(move_to)
			direction = direction_check(move_from, move_to)
			return "Invalid move" if is_valid_move?(move_from,move_to) == false
			return "Target destination is an ally" if (is_enemy?(move_from,move_to) == false)
			return "Move is blocked by another piece" if (move_unhindered?(move_from,move_to,direction) == false)
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