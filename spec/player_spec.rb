require "spec_helper.rb"
module Chess
	describe Player do
		context "#initialize" do
			let(:player) {Player.new("Bob", "black")}
			
			it { expect(player.name).to eq "Bob" }
			it { expect(player.color).to eq "black" }
		end
	end
end