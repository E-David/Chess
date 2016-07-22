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
			label_board_axes
			setup_pawns
			setup_back_rows
		end

		def coordinate_board
			grid.each_with_index do |row,row_index| 
				row.each_with_index do |square,col_index|
					square.coordinate = [col_index,row_index]
				end
			end
		end

		def colorize_board
			grid.each_with_index do |row,row_index| 
				row.each_with_index do |square,col_index|
					if row_index.even?
						col_index.even? ? square.color = "BB" : square.color = "WW"
					else
						col_index.even? ? square.color = "WW" : square.color = "BB"
					end
				end
			end
		end

		def label_board_axes
			grid.each_with_index do |row, row_index| 
				row.each_with_index do |square, col_index|
					if row_index == 0
						col_index == 0 ? square.color = "_" : square.color = ("A".."H").to_a[col_index - 1] * 2
					end

					if col_index == 0
						unless row_index == 0
							square.color = (1..8).to_a.reverse[row_index - 1]
						end
					end
				end
			end
		end

		def setup_pawns
			(1..8).each do |col| 
				set_square([col,2], Pawn.new("black",[col,2]))
				set_square([col,7], Pawn.new("white",[col,7]))
			end
		end

		def setup_back_rows
			(1..8).each do |col| 
				case col 
				when 1 
					set_square([col,1],   Rook.new("black",[col,1])) ; set_square([col,8],   Rook.new("white",[col,8]))
				when 2
					set_square([col,1], Knight.new("black",[col,1])) ; set_square([col,8], Knight.new("white",[col,8]))
				when 3
					set_square([col,1], Bishop.new("black",[col,1])) ; set_square([col,8], Bishop.new("white",[col,8]))
				when 4
					set_square([col,1],  Queen.new("black",[col,1])) ; set_square([col,8],  Queen.new("white",[col,8]))
				when 5
					set_square([col,1],   King.new("black",[col,1])) ; set_square([col,8],   King.new("white",[col,8]))
				when 6
					set_square([col,1], Bishop.new("black",[col,1])) ; set_square([col,8], Bishop.new("white",[col,8]))
				when 7
					set_square([col,1], Knight.new("black",[col,1])) ; set_square([col,8], Knight.new("white",[col,8]))
				when 8
					set_square([col,1],   Rook.new("black",[col,1])) ; set_square([col,8],   Rook.new("white",[col,8]))
				end
			end
		end

		def load_pieces(coordinate, piece_name, piece_color)
			piece_class = Chess.const_get(piece_name)
			set_square(coordinate, piece_class.new(piece_color,coordinate))
		end

		def display_board
			grid.each do |row|
				display = ""
				row.each do |square|
					piece_display = square.value.class.name == "String" ? square.color : square.value.text_char
					display += square.value.class.name == "String" ? "  #{piece_display}  " : "  #{piece_display}  "
				end
				puts display
			end
		end

		#gets [column,row] from provided coordinate
		def get_square(coordinate)
			grid[coordinate[1]][coordinate[0]]
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
			ally_pieces = all_pieces.select { |piece| piece.color == color && piece.piece_name != "King" }
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

		def get_check_piece_positions(color)
			check_piece_positions = []
			get_valid_check_pieces(color).each { |piece| check_piece_positions << piece.position }
			check_piece_positions
		end

		def get_check_paths(color)
			king = get_king(color)
			check_paths = []
			get_valid_check_pieces(color).each { |piece| check_paths << get_path(piece.position,king.position) }
			check_paths.each { |path| path.delete_if { |x| x == king.position } }
		end

		def check?(color)
			get_check_paths(color).count >= 1
		end
			#Uses the & method to find common elements (an intersection) between given path and ally piece valid moves
			#then checks if the ally piece can move to this intersection. 
			#Finally, returns all pieces that can block the check path
		def block_check_path(color)
			can_block = ""
			get_check_paths(color).each do |path|
				ally_pieces(color).each do |piece|
					intersections = piece.valid_moves & path
					if intersections.size >= 1
						intersections.each do |intersection| 
							if check_move(piece.position,intersection) == true
								can_block = true if still_in_check?(piece.position,intersection,color) == false
							end
						end
					end
				end
			end
			can_block
		end

		def possible_moves(coord)
			piece = get_piece(coord)
			piece.valid_moves.select { |move| check_move(piece.position,move) }
		end
		
		def possible_king_moves(king)
			king.valid_moves.select { |move| check_move(king.position,move) && is_unoccupied?(move) }
		end

		def king_trapped(color)
			king = get_king(color)
			original_position = king.position
			possible_king_moves(king).all? do |king_move|
				still_in_check?(king.position,king_move,color) == true
			end
		end

		def eliminate_check_piece(color)
			get_check_piece_positions(color).any? do |check_piece_position|
				ally_pieces(color).any? do |ally_piece|
					if check_move(ally_piece.position,check_piece_position) == true
						still_in_check?(ally_piece.position,check_piece_position,color) == false
					end
				end
			end
		end

		def still_in_check?(move_from,move_to,color)
			check = ""
			original_from_piece = get_piece(move_from)
			original_to_piece = get_piece(move_to)
			move_piece(move_from,move_to)
			check = check?(color)
			set_square(move_from,original_from_piece)
			set_square(move_to,original_to_piece)
			check
		end

		def checkmate?(color)
			!eliminate_check_piece(color) && king_trapped(color) == false && !block_check_path(color)
		end

		def set_square(coordinate,piece="")
			get_square(coordinate).value = piece
			piece.position = coordinate if piece != ""
		end

		def get_legal_moves(coordinate)
			piece = get_piece(coordinate)
			piece.valid_moves.select { |move| check_move(piece.position,move) == true }
		end

		def show_legal_moves(coordinate)
			legal_moves = get_legal_moves(coordinate)
			legal_moves.map { |move| move.chessify_coordinates.join }
		end

		def move_piece(coordinate_from,coordinate_to)
			piece = get_piece(coordinate_from)
			piece_class = Chess.const_get(piece.piece_name)
			set_square(coordinate_to, piece_class.new(piece.color,coordinate_to))
			set_square(coordinate_from)
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
					path << move_to
				end
			else 
				path << move_to if is_unoccupied?(move_to)
			end
			path
		end

		def horizontal_path(move_from, move_to)
			path = [move_from]
			column = move_from[0]
			until column == move_to[0]
				column > move_to[0] ? column -= 1 : column += 1
				path << [column,move_from[1]]
				if is_unoccupied?([column,move_from[1]]) == false
					break
				end
			end
			path
		end

		def vertical_path(move_from, move_to)
			path = [move_from]
			row = move_from[1]
			until row == move_to[1]
					row > move_to[1] ? row -= 1 : row += 1
					path << [move_from[0],row]
					if is_unoccupied?([move_from[0],row]) == false
						break
					end
				end
			path
		end

		def diagonal_path(move_from, move_to)
			path = [move_from]
			col = move_from[0]
			row = move_from[1]
			until (col == move_to[0]) && (row == move_to[1])
				col > move_to[0] ? col -= 1 : col += 1
				row > move_to[1] ? row -= 1 : row += 1
				path << [col,row]
				if is_unoccupied?([col,row]) == false
					break
				end
			end
			path
		end

		def get_path(move_from,move_to)
			path = []
			if is_knight?(move_from) 
				path = [move_to]
			elsif is_pawn?(move_from)
				path = pawn_path(move_from,move_to)
			elsif (move_from[0] != move_to[0] && move_from[1] != move_to[1]) && !is_pawn?(move_from)
				path = diagonal_path(move_from,move_to)
			elsif move_from[1] != move_to[1]
				path = vertical_path(move_from,move_to)
			elsif move_from[0] != move_to[0]
				path = horizontal_path(move_from,move_to)
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

		def valid_moves_exist?(color)
			ally_pieces(color).any? do |piece|
				piece.valid_moves.any? do |move|
					check_move(piece.position,move) == true
				end
			end
		end

		def game_over(color)
			return :winner if winner?(color)
			return :draw if draw?(color)
			false
		end

		def winner?(color)
			if check?(color)
				p checkmate?(color) #== true ? true : (p "#{color} king is in check!")
			end
		end

		def draw?(color)
			check?(color) == false
			valid_moves_exist?(color) == false
		end

		private

		def default_board
			Array.new(9) { Array.new(9) { Square.new } }
		end
	end
end