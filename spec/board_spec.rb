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

			it "sets the grid with given input" do
				board = Board.new(grid: [0,1,2])
				expect(board.grid).to eq [0,1,2]
			end
		end

		context "#coordinate_board" do
			it "sets square position to row/column index" do
				Cat = Struct.new(:coordinate)
				board = Board.new(grid: [[Cat.new(),Cat.new()],[Cat.new(),Cat.new()]])
				board.coordinate_board
				expect(board.grid[0][1].coordinate).to eq [0,1]
				expect(board.grid[1][1].coordinate).to eq [1,1]
			end
		end

		context "#colorize_board" do
			it "sets board to alternating square colors" do
				Cat = Struct.new(:color)
				board = Board.new(grid: [[Cat.new(""),Cat.new("")],[Cat.new(""),Cat.new("")]])
				board.colorize_board
				expect(board.grid[0][0].color).to eq "white"
				expect(board.grid[0][1].color).to eq "black"
				expect(board.grid[1][1].color).to eq "black"
			end
		end

		context "#get_square" do
			it "retrieves square when given valid input" do
				board = Board.new(grid: [["","",""],["","something",""]])
				expect(board.get_square([1,1])).to eq "something"
			end
		end

		context "#set_square" do
			it "changes value to given piece" do
				Cat = Struct.new(:value)
				board = Board.new(grid: [["","",""],["",Cat.new("cool"),""]])
				board.set_square([1,1],"meow")
				expect(board.get_square([1,1]).value).to eq "meow"
			end
		end

		context "#is_unoccupied?" do
			it "returns true if square has a piece value" do
				Cat = Struct.new(:value)
				board = Board.new(grid: [[Cat.new("something"),Cat.new("")]])
				expect(board.is_unoccupied?([0,0])).to be_falsey
				expect(board.is_unoccupied?([0,1])).to be_truthy
			end
		end

		context "#is_enemy?" do
			it "returns true if colors aren't equal" do
				Piece = Struct.new(:color)
				board = Board.new(grid: [[Piece.new("white"),Piece.new("black"),Piece.new("white")]])
				expect(board.is_enemy?([0,0],[0,1])).to be_truthy
			end
		end

		context "#is_valid_move?" do
			it "returns true if piece can move there" do
				Square = Struct.new(:value)
				Piece = Struct.new(:valid_moves)
				board = Board.new(grid: [[Square.new(Piece.new([[5,5]]))]])
				expect(board.is_valid_move?([0,0],[5,5])).to be_truthy
			end

			it "returns false if piece cannot move there" do
				Square = Struct.new(:value)
				Piece = Struct.new(:valid_moves)
				board = Board.new(grid: [[Square.new(Piece.new([[1,1]]))]])
				expect(board.is_valid_move?([0,0],[5,5])).to be_falsey
			end
		end

		context "#horizontal_movement_check" do
			it "returns true if piece is unhindered horizontally" do
				square = Struct.new(:value)
				board = Board.new(grid: [[Square.new(""),Square.new("")],
										 [Square.new(""),Square.new("")]])
				expect(board.horizontal_movement_check([0,0],[0,1])).to be_truthy
			end

			it "returns false if piece is hindered horizontally" do
				square = Struct.new(:value)
				board = Board.new(grid: [[Square.new(""),Square.new("Occupied")],
										 [Square.new(""),Square.new("")]])
				expect(board.horizontal_movement_check([0,0],[0,1])).to be_falsey
			end
		end

		context "#check_move" do
			let(:board) { Board.new }
			it "returns true if move is valid and square is unoccupied" do
				allow(board).to receive(:is_valid_move?) { true }
				allow(board).to receive(:is_unoccupied?) { true }
				expect(board.check_move("this","that")).to be_truthy
			end

			it "returns true if move is valid and square is an enemy" do
				allow(board).to receive(:is_valid_move?) { true }
				allow(board).to receive(:is_unoccupied?) { false }
				allow(board).to receive(:is_enemy?) { true }
				expect(board.check_move("this","that")).to be_truthy
			end

			it "returns false if move is not valid" do
				allow(board).to receive(:is_valid_move?) { false }
				allow(board).to receive(:is_unoccupied?) { true }
				allow(board).to receive(:is_enemy?) { true }
				expect(board.check_move("this","that")).to be_falsey
			end

			it "returns false if move is valid and square is not an enemy" do
				allow(board).to receive(:is_valid_move?) { true }
				allow(board).to receive(:is_unoccupied?) { false }
				allow(board).to receive(:is_enemy?) { false }
				expect(board.check_move("this","that")).to be_falsey
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