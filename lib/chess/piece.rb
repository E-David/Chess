module Chess
	class Piece
		attr_reader :color, :piece_name
		attr_accessor :position
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
			col = position[0]
			(1..8).each { |row| move_list << [col,row]}
			move_list
		end

		def vertical_moves
			move_list = []
			row = position[1]
			(1..8).each { |col| move_list << [col,row]}
			move_list
		end

		def diagonal_moves
			move_list = []
			col = position[0]
			row = position[1]
			[[-1,-1],[-1,1],[1,-1],[1,1]].each do |move|
			new_move = apply_move_to_position(move,[col,row])
				until new_move[0] > 8 || new_move[1] > 8 || new_move[0] < 1 || new_move[1] < 1
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
			string += "Piece Name: #{self.piece_name}"
			string += ", Color: #{self.color}"
			return string
		end
	end

		class Pawn < Piece
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265F" : "\u2659"
				@text_char = 	color == "black" ? "bP" : "wP"
				@valid_moves = validate_move
				@move_number = move_number
			end

			def possible_moves
				possible_moves = []
				if color == "black"
					possible_moves += [[0,1],[-1,1],[1,1]]
					possible_moves += [[0,2]] if first_move?
				elsif color == "white"
					possible_moves += [[0,-1],[1,-1],[-1,-1]]
					possible_moves += [[0,-2]] if first_move?
				end
				return possible_moves
			end

			def first_move?
				color == "black" && position[1] == 2 || color == "white" && position[1] == 7
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move
				valid_moves = available_moves.select { |move| move.all? { |x| x >= 1 && x <= 8 } }
			end
		end

		class Rook < Piece
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265C" : "\u2656"
				@text_char	  = color == "black" ? "bR" : "wR"
				@valid_moves = possible_moves
				@move_number = move_number
			end

			def possible_moves
				horizontal_moves + vertical_moves
			end
		end

		class Knight < Piece
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265E" : "\u2658"
				@text_char	  = color == "black" ? "bN" : "wN"
				@valid_moves = validate_move
				@move_number = move_number
			end

			def possible_moves
				possible_moves = knight_moves
				return possible_moves
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move
				valid_moves = available_moves.select { |move| move.all? { |x| x >= 1 && x <= 8 } }
			end
		end
		
		class Bishop < Piece
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265D" : "\u2657"
				@text_char	  = color == "black" ? "bB" : "wB"
				@valid_moves = possible_moves
				@move_number = move_number
			end

			def possible_moves
				possible_moves = diagonal_moves
				return possible_moves
			end
		end

		class Queen < Piece
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265B" : "\u2655"
				@text_char	  = color == "black" ? "bQ" : "wQ"
				@valid_moves = possible_moves
				@move_number = move_number
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
			attr_reader :valid_moves, :unicode_char, :text_char
			attr_accessor :position, :move_number
			def initialize(color, position, move_number=0)
				super(color, position)
				@unicode_char = color == "black" ? "\u265A" : "\u2654"
				@text_char	  = color == "black" ? "bK" : "wK"
				@move_number = move_number
				@valid_moves = validate_move(available_moves)
			end

			def possible_moves
				possible_moves = [[0,-1],[1,-1],[1,0],[1,1],[0,1],[-1,1],[-1,0],[-1,-1]]
				if move_number == 0
					#used for castling. If king hasn't moved, it can move to the left or the right two spaces.
					possible_moves << [2,0]
					possible_moves << [-2,0]
				end
				possible_moves
			end

			def available_moves
				possible_moves.map! { |move| apply_move_to_position(move,position) }
			end

			def validate_move(moves)
				moves.select { |move| move.all? { |x| x >= 1 && x <= 8 } }
			end
		end
end