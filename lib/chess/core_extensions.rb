class String
	#provided letter gets capitalized, subtract value of A, then add one since "A" column actually starts in column 1
	#column 0 is used to label vertical axis
	def letter_to_number
		self.upcase.ord - 'A'.ord + 1
	end
end

class Integer
	#changes provided input from displayed vertical axis 1-8 bottom to top to actual axis 1-8, top to bottom
	#or vice-versa with raw input
	def reverse_number
		(1..8).to_a.reverse[self - 1]
	end

	#reverse of letter_to_number. "65.chr" is "A", but need to subtract one since first column is for vert axis,
	#so raw input from self will be off by 1
	def number_to_letter
		(self + 64).chr
	end
end

class Array
	def unchessify_coordinates
		col = self[0]
		row = self[1]
		col = col.letter_to_number
		row = row.reverse_number
		[col,row]
	end

	def chessify_coordinates
		col = self[0]
		row = self[1]
		col = col.number_to_letter
		row = row.reverse_number
		[col,row]
	end
end