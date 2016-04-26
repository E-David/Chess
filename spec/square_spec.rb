require "spec_helper.rb"
module Chess
	describe square do
		context "#initialize" do
			it "has a default value and color of "" " do
				square = Square.new
				expect(square.value).to eq ""
				expect(square.color).to eq ""
			end

			it "changes value if given input" do
				square = Square.new
				square.value = "pawn"
				expect(square.value).to eq "pawn"
			end

			it "changes color if given input" do
				square = Square.new("", "black")
				expect(square.color).to eq "black"
			end
		end
	end
end