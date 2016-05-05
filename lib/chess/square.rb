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
			string += "coordinates: [#{self.coordinate}]"
			string += ", color: #{self.color}"
			string += ", piece: #{self.value.class}" if self.value != ""
			string += ", piece_details: #{self.value.valid_moves}" if self.value != ""
			p string
		end
	end
end
			