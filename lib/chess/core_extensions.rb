class String
	def letter_to_number
		self.ord - 'A'.ord + 1
	end
end

class Integer
	def reverse_number
		(1..8).to_a.reverse[self - 1]
	end
end

class Array
	def unchessify_coordinates
		self[0] = self[0].letter_to_number
		self[1] = self[1].to_i.reverse_number
	end
end