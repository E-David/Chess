module Chess
	class Piece
		attr_reader :color, :position, :piece_name
		def initialize(color, position=[])
			@color = color
			@position = position
			@piece_name = self.class.name.gsub(/(Chess::)/,"")
		end

		#creates new array of each possible movement plus the current position
		def apply_move_to_position(move,position)
			[position,move].transpose.map { |t| t.reduce(:+) }
		end

		def horizontal_moves
			move_list = []
			row = position[0]
			(0..7).each { |col| move_list << [row,col]}
			move_list
		end

		def vertical_moves
			move_list = []
			col = position[1]
			(0..7).each { |row| move_list << [row,col]}
			move_list
		end

		def diagonal_moves
			move_list = []
			row = position[0]
			col = position[1]
			[[-1,-1],[-1,1],[1,-1],[1,1]].each do |move|
			new_move = apply_move_to_position(move,[row,col])
				until new_move[0] > 7 || new_move[1] > 7 || new_move[0] < 0 || new_move[1] < 0
					move_list << new_move if move_list.include?(new_move) == false
					new_move = apply_move_to_position(move,new_move)
				end
			end
			move_list
		end

		def knight_moves
			move_list = []
			[[2,1],[2,-1],[1,2],[1,-2],[-2,1],[-2,-1],[-1,2],[-1,-2]].each do |move| 
				move_list << apply_move_to_position(move,position)
			end
		end

		def to_s
			string = ""
			string += "piece name: #{self.piece_name}"
			string += ", piece color: #{self.color}"
			#string += ", piece valid moves #{self.valid_moves}"
			return string
		end
	end

		class Pawn < Piece
			attr_reader :valid_moves, :position, :unicode_char
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265F" : "\u2659"
				@valid_moves = validate_move
			end

			def possible_moves
				possible_moves = []
				if color == "black"
					possible_moves += [[1,0],[1,-1],[1,1]]
					possible_moves += [[2,0]] if first_move?
				elsif color == "white"
					possible_moves += [[-1,0],[-1,1],[-1,-1]]
					possible_moves += [[-2,0]] if first_move?
				end
				return possible_moves
			end

			def first_move?
				color == "black" && position[0] == 1 || color == "white" && position[0] == 6
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move
				valid_moves = available_moves.select { |move| move.all? { |x| x >= 0 && x <= 7 } }
			end
		end

		class Rook < Piece
			attr_reader :valid_moves, :position, :unicode_char
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265C" : "\u2656"
				@valid_moves = possible_moves
			end

			def possible_moves
				horiz = horizontal_moves
				vertic = vertical_moves
				possible_moves = horiz + vertic
				return possible_moves
			end
		end

		class Knight < Piece
			attr_reader :valid_moves, :position, :unicode_char
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265E" : "\u2658"
				@valid_moves = validate_move
			end

			def possible_moves
				possible_moves = knight_moves
				return possible_moves
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move
				valid_moves = available_moves.select { |move| move.all? { |x| x >= 0 && x <= 7 } }
			end
		end
		
		class Bishop < Piece
			attr_reader :valid_moves, :position, :unicode_char
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265D" : "\u2657"
				@valid_moves = possible_moves
			end

			def possible_moves
				possible_moves = diagonal_moves
				return possible_moves
			end
		end

		class Queen < Piece
			attr_reader :valid_moves, :position, :unicode_char
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265B" : "\u2655"
				@valid_moves = possible_moves
			end

			def possible_moves
				horiz = horizontal_moves
				vertic = vertical_moves
				diag = diagonal_moves
				possible_moves = horiz + vertic + diag
				return possible_moves
			end
		end
		
		class King < Piece
			attr_reader :valid_moves, :position, :unicode_char, :check_moves
			def initialize(color, position)
				super(color, position)
				@unicode_char = color == "black" ? "\u265A" : "\u2654"
				@valid_moves = validate_move(available_moves)
				@check_moves = possible_check_moves
			end

			def possible_moves
				possible_moves = [[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1]]
				return possible_moves
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move(moves)
				moves.select { |move| move.all? { |x| x >= 0 && x <= 7 } }
			end

			def possible_check_moves
				horiz = horizontal_moves
				vertic = vertical_moves
				diag = diagonal_moves
				knight = knight_moves
				possible_check_moves = horiz + vertic + diag + knight
				return validate_move(possible_check_moves)
			end
		end
end