class String
	def letter_to_number
		self.upcase.ord - 'A'.ord + 1
	end
end

class Integer
	def reverse_number
		(1..8).to_a.reverse[self - 1]
	end

	def forward_number
		(1..8).to_a[self - 1]
	end

	def number_to_letter
		(self + 65).chr
	end
end

class Array
	def unchessify_coordinates
		self[0] = self[0].letter_to_number
		self[1] = self[1].reverse_number
		self
	end

	def chessify_coordinates
		self[0] = self[0].number_to_letter
		self[1] = self[1].forward_number
		p self
	end
end