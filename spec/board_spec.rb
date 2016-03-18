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

		it "sets the grid with given input" do
			board = Board.new(grid: "this")
			expect(board.grid).to eq "this"
		end

		context "#get_square" do
			it "retrieves square when given valid input" do
				board = Board.new(grid: [["","",""],["","something",""]])
				expect(board.get_square(1,1)).to eq "something"
			end
		end

		context "#set_square" do
			it "changes value to given piece" do
				Cat = Struct.new(:value)
				board = Board.new(grid: [["","",""],["",Cat.new("cool"),""]])
				board.set_square(1,1,"meow")
				expect(board.get_square(1,1).value).to eq "meow"
			end
		end

		context "#game_over" do
			it "returns winner if winner? is true" do
				board = Board.new
				allow(board).to receive(:winner?) { true }
				expect(board.game_over).to eq :winner
			end

			it "returns draw if draw? is true" do
				board = Board.new
				allow(board).to receive(:winner?) { false }
				allow(board).to receive(:draw?) { true }
				expect(board.game_over).to eq :draw
			end

			it "returns false if winner? and draw? are false" do
				board = Board.new
				allow(board).to receive(:winner?) { false }
				allow(board).to receive(:draw?) { false }
				expect(board.game_over).to eq false
			end
		end
	end
end