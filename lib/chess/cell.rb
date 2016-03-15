module Chess
	class Cell
		attr_accessor :value, :color
		def initialize(value = "", color= "")
			@value = value
			@color = color
		end
	end
end
			