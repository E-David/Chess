module Chess
	class Board
		attr_accessor :grid, :previous_move
		def initialize(input = {})
			@grid = input.fetch(:grid, default_board)
			@previous_move = []
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

		def display_board
			grid.each do |row|
				display = ""
				row.each do |square|
					piece_display = square.value.class.name == "String" ? square.color : square.value.text_char
					display += "  #{piece_display}  "
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
			all_pieces.select { |piece| piece.color == color && piece.piece_name != "King" }
		end

		def enemy_pieces(color)
			all_pieces.select { |piece| piece.color != color }
		end

		def get_king(color)
			king = ""
			all_pieces.each { |piece| king = piece if (is_specified_piece?("King",piece.position) && piece.color == color) }
			king
		end

		def get_all_check_pieces(color,king)
			enemy_pieces(color).select { |piece| piece.valid_moves.include?(king.position) }
		end

		#King is separated because check move would say checking King would be in check if it moved. Fix later.
		def get_valid_check_pieces(color,king)
			get_all_check_pieces(color,king).select do |piece| 
				(is_specified_piece?("King",piece.position) || check_move(piece.position,king.position)) == true
			end
		end

		def get_check_piece_positions(color)
			check_piece_positions = []
			get_valid_check_pieces(color).each { |piece| check_piece_positions << piece.position }
			check_piece_positions
		end

		def get_check_paths(color)
			king = get_king(color)
			check_paths = []
			get_valid_check_pieces(color,king).each { |piece| check_paths << get_path(piece.position,king.position) }
			check_paths.each { |path| path.delete_if { |x| x == king.position } }
		end

		def check?(color)
			get_check_paths(color).count >= 1
		end
			#Uses the & method to find common elements (an intersection) between given path and ally piece valid moves
			#then checks if the ally piece can move to this intersection. 
			#Finally, returns all piece positions that can block the check path
		def block_check_path(color)
			blocking_pieces = []
			get_check_paths(color).each do |path|
				ally_pieces(color).each do |piece|
					intersections = piece.valid_moves & path
					if intersections.size >= 1
						intersections.each do |intersection| 
							if check_move(piece.position,intersection) == true
								blocking_pieces << piece.position if move_puts_in_check?(piece.position,intersection,color) == false
							end
						end
					end
				end
			end
			blocking_pieces
		end

		def possible_moves(coord)
			piece = get_piece(coord)
			piece.valid_moves.select { |move| check_move(piece.position,move) }
		end
		
		def possible_king_moves(king)
			king.valid_moves.select do |move| 
				check_move(king.position,move) == true
			end
		end

		def valid_king_moves(color)
			king_moves = []
			king = get_king(color)
			original_position = king.position
			possible_king_moves(king).each do |king_move|
				king_moves << king_move if move_puts_in_check?(king.position,king_move,color) == false
			end
			king_moves
		end

		def eliminate_check_piece(color)
			eliminating_pieces = []
			get_check_piece_positions(color).each do |check_piece_position|
				ally_pieces(color).each do |ally_piece|
					if check_move(ally_piece.position,check_piece_position) == true
						if move_puts_in_check?(ally_piece.position,check_piece_position,color) == false
							eliminating_pieces << ally_piece.position
						end
					end
				end
			end
			eliminating_pieces
		end

		def load_move(move)
			square = get_square(move).clone
			square.value = square.value.clone
			@previous_move << square
		end

		def reset
			until @previous_move.empty?
				move = @previous_move.pop
				set_square(move.coordinate,move.value)
			end
		end

		def move_puts_in_check?(move_from,move_to,color)
			[move_from,move_to].each { |move| load_move(move) }
			move_piece(move_from,move_to)
			check = check?(color)
			reset
			check
		end

		#code for working game,but change it ASAP
		def castling_puts_in_check?(king_move_from,king_move_to,rook_move_from,rook_move_to,color)
			[king_move_from,king_move_to,rook_move_from,rook_move_to].each { |move| load_move(move) }
			move_piece(king_move_from,king_move_to)
			move_piece(rook_move_from,rook_move_to)
			check = check?(color)
			reset
			check
		end

		def checkmate?(color)
			if eliminate_check_piece(color).empty? && valid_king_moves(color).empty? && block_check_path(color).empty?
				return true
			else
				stop_check(color)
			end
		end

		def stop_check(color)
			if !eliminate_check_piece(color).empty?
				puts "you can eliminate the checking piece with: #{ chessify_moves(eliminate_check_piece(color)) }"
			end

			if !valid_king_moves(color).empty?
				puts "you can move your king out of check here: #{ chessify_moves(valid_king_moves(color)) }"
			end

			if !block_check_path(color).empty?
				puts "you can block one checking piece with: #{ chessify_moves(block_check_path(color)) } "
			end
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
			chessify_moves(legal_moves)
		end

		def chessify_moves(array)
			array.map { |move| move.chessify_coordinates.join }.sort
		end

		def move_piece(coordinate_from,coordinate_to)
			piece = get_piece(coordinate_from)
			piece_class = Chess.const_get(piece.piece_name)
			en_passant(coordinate_from,coordinate_to) if en_passant_move?(coordinate_from,coordinate_to)
			set_square(coordinate_to, piece_class.new(piece.color,coordinate_to,piece.move_number+=1))
			erase_square(coordinate_from)
		end

		def erase_square(coordinate_from)
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

		def is_specified_piece?(name,coordinate)
			piece = get_piece(coordinate)
			return false if piece == ""
			piece.piece_name == name
		end

		# check if piece is moving diagonally. If yes, returns if destination is occupied and an enemy
		# if no, basically calls vertical_path method, but doesn't add move unless move is unoccupied
		def pawn_path(move_from,move_to)
			path = [move_from]
			row = move_from[1]
			if (move_from[0] != move_to[0] && move_from[1] != move_to[1])
				if is_ally?(move_from,move_to) == false && 
				(is_unoccupied?(move_to) == false || en_passant_move?(move_from,move_to) == true)
					path << move_to
				end
			else 
				until row == move_to[1]
					row > move_to[1] ? row -= 1 : row += 1
					if is_unoccupied?([move_from[0],row]) == false
						break
					end
					path << [move_from[0],row]
				end
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
			if is_specified_piece?("Knight",move_from) 
				path = [move_to]
			elsif is_specified_piece?("Pawn",move_from)
				path = pawn_path(move_from,move_to)
			elsif (move_from[0] != move_to[0] && move_from[1] != move_to[1])
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

		def get_en_passant_piece(move_from,move_to)
			ally_piece = get_piece(move_from)
			col = move_to[0]
			row = move_to[1]
			ally_piece.color == "black" ? row -= 1 : row += 1
			get_piece([col,row])
		end

		def en_passant_move?(move_from,move_to)
			return false if !is_specified_piece?("Pawn",move_from)
			enemy_piece = get_en_passant_piece(move_from,move_to)
			return false if enemy_piece == ""
			if  is_specified_piece?("Pawn",enemy_piece.position)
				enemy_piece.move_number == 1
			end
		end

		def en_passant(move_from,move_to)
			enemy_piece = get_en_passant_piece(move_from,move_to)
			erase_square(enemy_piece.position)
		end

		def is_castling?(move_from,move_to)
			return false if !is_specified_piece?("King",move_from) || (move_from[0] - move_to[0]).abs != 2 
			king = get_piece(move_from)
			rook = get_castling_rook(move_from,move_to)
			return false if !is_specified_piece?("Rook",rook.position)
		end

		def can_castle?(move_from,move_to)
			king = get_piece(move_from)
			rook = get_castling_rook(move_from,move_to)
			(king.move_number == 0 && rook.move_number == 0)
		end

		def get_castling_rook(move_from,move_to)
			col = move_from[0]
			row = move_from[1]
			(col - move_to[0] ) > 0 ? col -= 4 : col += 3
			get_piece([col,row])
		end

		def get_casling_rook_move_to(king,rook)
			rook_col = rook[0]
			rook_row = rook[1]
			king[0] > rook_col ? rook_col += 3 : rook_col -= 2
			[rook_col,rook_row]
		end

		def castling_move_piece(move_from,move_to)
			king = get_piece(move_from)
			rook = get_castling_rook(move_from,move_to)
			rook_move_from = rook.position
			rook_move_to = get_casling_rook_move_to(king.position,rook.position)
			if move_unhindered?(rook_move_from,rook_move_to) == false
				return "Rook is blocked by another piece" 
			elsif
				castling_puts_in_check?(move_from,move_to,rook_move_from,rook_move_to,king.color) == true
				return "Move would put King in check" 
			else
				move_piece(move_from,move_to)
				move_piece(rook_move_from,rook_move_to)
			end
		end

		def check_move(move_from, move_to)
			color = get_piece(move_from).color
			return "Invalid move" if is_valid_move?(move_from,move_to) == false
			return "Target destination is an ally" if is_ally?(move_from,move_to) == true
			return "Move is blocked by another piece" if move_unhindered?(move_from,move_to) == false
			return "Move would put your King in check" if move_puts_in_check?(move_from,move_to,color) == true
			return "Cannot castle" if is_castling?(move_from,move_to) && can_castle?(move_from,move_to) == false
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
			return :stalemate if stalemate?(color)
			false
		end

		def winner?(color)
			if check?(color)
				checkmate?(color) == true
			end
		end

		def stalemate?(color)
			if check?(color) == false
				valid_moves_exist?(color) == false
			end
		end

		private

		def default_board
			Array.new(9) { Array.new(9) { Square.new } }
		end
	end
end