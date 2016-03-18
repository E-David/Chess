module Chess
	class Pawn
		attr_reader :color, :position, :alive
		def initialize(color, position, alive = 1)
			@color = color
			@position = position
			@alive = alive
		end
	end
end