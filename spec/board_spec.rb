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
				Coordinate = Struct.new(:coordinate)
				board = Board.new(grid: [[Coordinate.new(),Coordinate.new()],[Coordinate.new(),Coordinate.new()]])
				board.coordinate_board
				expect(board.grid[0][1].coordinate).to eq [0,1]
				expect(board.grid[1][1].coordinate).to eq [1,1]
			end
		end

		context "#colorize_board" do
			it "sets board to alternating square colors" do
				Color = Struct.new(:color)
				board = Board.new(grid: [[Color.new(""),Color.new("")],[Color.new(""),Color.new("")]])
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
				Value = Struct.new(:value)
				board = Board.new(grid: [["","",""],["",Value.new("cool"),""]])
				board.set_square([1,1],"meow")
				expect(board.get_square([1,1]).value).to eq "meow"
			end
		end

		context "#is_unoccupied?" do
			it "returns true if square has a piece value" do
				board = Board.new(grid: [[Value.new("something"),Value.new("")]])
				expect(board.is_unoccupied?([0,0])).to be false
				expect(board.is_unoccupied?([0,1])).to be true
			end
		end

		context "#is_enemy?" do
			it "returns true if colors aren't equal" do
				Piece_Color = Struct.new(:color)
				board = Board.new(grid: [[Piece_Color.new("white"),Piece_Color.new("black"),Piece_Color.new("white")]])
				expect(board.is_enemy?([0,0],[0,1])).to be true
			end
		end

		context "#is_valid_move?" do
			it "returns true if piece can move there" do
				Valid_Moves = Struct.new(:valid_moves)
				board = Board.new(grid: [[Value.new(Valid_Moves.new([[5,5]]))]])
				expect(board.is_valid_move?([0,0],[5,5])).to be true
			end

			it "returns false if piece cannot move there" do
				board = Board.new(grid: [[Value.new(Valid_Moves.new([[1,1]]))]])
				expect(board.is_valid_move?([0,0],[5,5])).to be false
			end
		end

		context "#horizontal_movement_check" do
			it "returns true if piece is unhindered horizontally either direction" do
				board = Board.new(grid: [[Value.new(""),Value.new(""),Value.new("")]])
				expect(board.horizontal_movement_check([0,0],[0,2])).to be true
				expect(board.horizontal_movement_check([0,2],[0,0])).to be true
			end

			it "returns false if piece is hindered horizontally either direction" do
				board = Board.new(grid: [[Value.new(""),Value.new("Occupied"),Value.new("")]])
				expect(board.horizontal_movement_check([0,0],[0,2])).to be false
				expect(board.horizontal_movement_check([0,2],[0,0])).to be false
			end
		end

		context "#vertical_movement_check" do
			it "returns true if piece is unhindered vertically either direction" do
				board = Board.new(grid: [[Value.new("")],
										 [Value.new("")],
										 [Value.new("")]])
				expect(board.vertical_movement_check([0,0],[2,0])).to be true
				expect(board.vertical_movement_check([2,0],[0,0])).to be true
			end

			it "returns false if piece is hindered vertically either direction" do
				board = Board.new(grid: [[Value.new("")],
										 [Value.new("Occupied")],
										 [Value.new("")]])
				expect(board.vertical_movement_check([0,0],[2,0])).to be false
				expect(board.vertical_movement_check([2,0],[0,0])).to be false
			end
		end

		context "#diagonal_movement_check" do
			it "returns true if piece is unhindered diagonally in any direction" do
				board = Board.new(grid: [[Value.new(""),Value.new(""),Value.new("")],
										 [Value.new(""),Value.new(""),Value.new("")],
										 [Value.new(""),Value.new(""),Value.new("")]])
				expect(board.diagonal_movement_check([0,0],[2,2])).to be true
				expect(board.diagonal_movement_check([2,2],[0,0])).to be true
				expect(board.diagonal_movement_check([0,2],[2,0])).to be true
				expect(board.diagonal_movement_check([2,0],[0,2])).to be true
			end

			it "returns false if piece is hindered diagonally in any direction" do
				board = Board.new(grid: [[Value.new(""),Value.new(""),Value.new("")],
										 [Value.new(""),Value.new("Occupied"),Value.new("")],
										 [Value.new(""),Value.new(""),Value.new("")]])
				expect(board.diagonal_movement_check([0,0],[2,2])).to be false
				expect(board.diagonal_movement_check([2,2],[0,0])).to be false
				expect(board.diagonal_movement_check([0,2],[2,0])).to be false
				expect(board.diagonal_movement_check([2,0],[0,2])).to be false
			end		
		end

		context "#direction_check" do
			let(:board) { Board.new }
			it "checks diagonally if row and column mismatch" do
				foo = [0,1]
				bar = [1,0]
				allow(board).to receive(:direction_check).with(foo,bar)
				board.diagonal_movement_check(foo,bar)
			end

			it "checks vertically if only row mismatch" do
				foo = [0,0]
				bar = [1,0]
				allow(board).to receive(:direction_check).with(foo,bar)
				board.vertical_movement_check(foo,bar)
			end

			it "checks horizontally if only column mismatch" do
				foo = [0,0]
				bar = [0,1]
				allow(board).to receive(:direction_check).with(foo,bar)
				board.horizontal_movement_check(foo,bar)
			end

			it "throws error if no mismatch exists" do
				foo = [0,0]
				bar = [0,0]
				expect { board.direction_check(foo,bar) }.to raise_error("Movement Error")
			end
		end

		context "#check_move" do
			let(:board) { Board.new }
			let(:valid_move) { allow(board).to receive(:is_valid_move?) { true } }
			let(:invalid_move) { allow(board).to receive(:is_valid_move?) { false } }
			let(:unoccupied) { allow(board).to receive(:is_unoccupied?) { true } }
			let(:occupied) { allow(board).to receive(:is_unoccupied?) { false } }
			let(:enemy_piece) { allow(board).to receive(:is_enemy?) { true } }
			let(:ally_piece) { allow(board).to receive(:is_enemy?) { false } }
			let(:unhindered_move) { allow(board).to receive(:direction_check) { true } }
			let(:hindered_move) { allow(board).to receive(:direction_check) { false } }
			it "returns true if move is valid, square is unoccupied, and move is unhindered" do
				valid_move && unoccupied && unhindered_move
				expect(board.check_move("this","that")).to be true
			end

			it "returns true if move is valid, square is an enemy, and move is unhindered" do
				valid_move && occupied && enemy_piece && unhindered_move
				expect(board.check_move("this","that")).to be true
			end

			it "returns false if move is invalid" do
				invalid_move && unoccupied && unhindered_move
				expect(board.check_move("this","that")).to be false
			end

			it "returns false if move is valid and square is not an enemy" do
				valid_move && occupied && ally_piece && unhindered_move
				expect(board.check_move("this","that")).to be false
			end

			it "returns false if move is valid and square is unoccupied, but move is hindered" do
				valid_move && unoccupied && hindered_move
				expect(board.check_move("this","that")).to be false
			end

			it "returns false if move is valid and square is an enemy, but move is hindered" do
				valid_move && occupied && enemy_piece && hindered_move
				expect(board.check_move("this","that")).to be false
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
				expect(board.game_over).to be false
			end
		end
	end
end