require "spec_helper.rb"
module Chess
	describe Board do
		context "#initialize" do
			it "initializes the board with a grid" do
				expect { Board.new(grid: "grid").to_not raise_error}
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
					if index.even?
						expect(row.first.color).to eq "white" 
						expect(row.last.color).to eq "white" 
					elsif index.odd?
						expect(row.first.color).to eq "black" 
						expect(row.last.color).to eq "black"
					end
				end
			end

			it "sets the grid with given input" do
				board = Board.new(grid: [0,1,2])
				expect(board.grid).to eq [0,1,2]
			end
		end

		context "#coordinate_board" do
			it "sets square position to row/column index" do
				cat = Struct.new(:x_coord,:y_coord)
				board = Board.new(grid: [["","",""],[cat(1,4),"",""]])
				board.coordinate_board
				expect(board[1][0].x_coord).to eq 1
				expect(board[1][0].y_coord).to eq 0
			end
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
				board = Board.new(grid: [["","",""],["",Cat("cool"),""]])
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