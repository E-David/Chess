require "spec_helper.rb"
module Chess
	describe Pawn do
		context "#initialize" do
			let(:wh_pawn0) { Pawn.new("white", [1,1])}

			it { expect(wh_pawn0.color).to eq "white" }
			it { expect(wh_pawn0.position).to eq [1,1] }
			it { expect(wh_pawn0.alive).to eq 1 }
		end
	end
end
