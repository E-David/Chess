module Chess
	class Piece
		attr_reader :color, :position
		def initialize(color, position)
			@color = color
			@position = position
		end
	end

		class Pawn < Piece
			attr_reader :valid_moves, :position
			def initialize(color, position)
				super(color, position)
				@valid_moves = validate_move
			end

			def to_s
				string = ""
				string += "#{self.color}"
				string += "#{self.valid_moves}"
				return string
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
				color == "black" && position[1] == 1 || color == "white" && position[1] == 6
			end

			#creates new array of each possible movement plus the current position
			def available_moves
				possible_moves.map! { |move| [move,position].transpose.map { |t| t.reduce(:+) } }
			end

			def validate_move
				available_moves.select { |move| move.all? { |x| x >= 0 && x <= 7 } }
			end
		end
end