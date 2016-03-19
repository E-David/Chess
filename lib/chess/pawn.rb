module Chess
	class Pawn
		attr_reader :color, :position, :alive, :possible_movement
		def initialize(color, position, alive = 1)
			@color = color
			@position = position
			@alive = alive
			@possible_movement = [[1,-1],[1,0],[2,0],[1,1]]
		end

		#creates new array of each possible movement plus the current position
		def available_moves
			possible_movement.map! { |move| [move,position].transpose.map { |t| t.reduce(:+) } }
		end
	end
end

x = Chess::Pawn.new("black",[1,0])
p x.available_movess