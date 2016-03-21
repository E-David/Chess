module Chess
	class Piece
		attr_reader :color, :position, :move_from, :move_to
		def initialize(color, move_from, move_to)
			@color = color
			@position = position
			@move_from = move_from
			@move_to = move_to
		end

		class Pawn << Piece
			attr_reader :valid_moves
			def initialize
				@valid_moves = valid_moves
			end

			def base_movement
				if color == "black"
					@valid_moves << [1,0]
				elsif color == "white"
					@valid_moves << [-1,0]
				end
			end

			def diagonals
				
			end

			#creates new array of each possible movement plus the current position
			def available_moves
				possible_moves = possible_movement
				possible_moves.map! { |move| [move,position].transpose.map { |t| t.reduce(:+) } }
			end

			def validate_move
				available_moves.select { |move| move.all? { |x| x >= 0 && x <= 7 } }
			end
		end

	end
end

x = Chess::Pawn.new("black",[1,1])
p x.validate_move