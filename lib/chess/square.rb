module Chess
	class Square
		attr_accessor :value, :color, :coordinate
		def initialize(value="", color="", coordinate=[])
			@value = value
			@color = color
			@coordinate = coordinate
		end

		def to_s
			string = ""
			string += "coordinates: #{self.coordinate}"
			string += ", square color: #{self.color}"
			return string
		end
	end
end