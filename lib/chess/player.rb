module Chess
	class Player
		attr_accessor :color
		attr_reader  :name
		def initialize(name, color)
			@name = name
			@color = color
		end
	end
end