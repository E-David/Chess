require "spec_helper.rb"
module Chess
	describe Cell do
		context "#initialize" do
			it "has a default value and color of "" " do
				cell = Cell.new
				expect(cell.value).to eq ""
				expect(cell.color).to eq ""
			end

			it "changes value if given input" do
				cell = Cell.new
				cell.value = "pawn"
				expect(cell.value).to eq "pawn"
			end

			it "changes color if given input" do
				cell = Cell.new("", "black")
				expect(cell.color).to eq "black"
			end
		end
	end
end