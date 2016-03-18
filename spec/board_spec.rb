require "spec_helper.rb"
module Chess
	describe Board do
		context "#initialize" do
			it "initializes the board with a grid" do
				expect { Board.new(grid: "grid").to_not raise_error}
			end
		end

		it "sets the grid with 8 rows by default" do
			board = Board.new
			expect(board.grid.size).to eq 8
		end

		it "sets the grid with 8 squares in each row by default" do
			board = Board.new
			board.grid.each { |row| expect(row.size).to eq 8 }			
		end

		it "sets the grid with alternating rows" do
			board = Board.new
			board.grid.each_with_index do |row, index|
				expect(row.first.color).to eq "white" if index.even?
				expect(row.first.color).to eq "black" if index.odd?
			end
		end
	end
end