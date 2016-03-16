require "spec_helper.rb"
module Chess
	describe Board do
		context "#initialize" do
			it "initializes the board with a grid" do
				expect { Board.new(grid: "grid").to_not raise_error}
			end
		end
	end
end