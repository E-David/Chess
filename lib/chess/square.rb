module Chess
	class Square
		attr_accessor :value, :color, :x_coord, :y_coord
		def initialize(value, color, x_cord, y_coord)
			@value = value
			@color = color
			@x_coord = x_coord
			@y_coord = y_coord
		end

		def to_s
			string = ""
			string += "position: [#{self.x_coord},#{self.y_coord}]"
			string += ", color: #{self.color}"
			string += ", piece: #{self.value.class}" if self.value != ""
			string += ", piece_details: #{self.value.valid_moves}" if self.value != ""
			p string
		end
	end
end
			