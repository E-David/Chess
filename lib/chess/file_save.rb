require 'yaml'

module Chess
	class File_Save
		attr_reader :board, :players
		def initialize(board,players)
			@board = board
			@player = players
		end

		def play
			until game_over != false
					puts "Guess a letter. Type 'save' to save your progress."
					board.display_board
					save_game if board.get_guess == false
			end
			board.display_hangman(board.tries_left)
			restart?
		end

		def save_game
			File.open("file.txt", "w") do |file| 
				file.puts "#{board.word}"
				file.puts "#{board.letters}"
				file.puts "#{board.tries_left}"
			end
			puts "Game saved!" if File.exists?("file.txt")
		end

		def load_game
			game = File.open("file.txt", "r")
			game_lines = game.readlines.each { |line| line.chomp! }
			game.close
			board.word = YAML::load(game_lines[0])
			board.letters = YAML::load(game_lines[1])
			board.tries_left = YAML::load(game_lines[2])
			play
		end

		def restart?
			prompt = "Would you like to play again?"
			puts prompt
			while answer = gets.chomp
				if answer == "yes" || answer == "y" || answer == "1"
					x = Hangman::Game.new
					x.play
					break
				elsif answer == "no" || answer == "n" || answer == "0"
					p "Thanks for playing Hangman!"
					break
				else
					p "invalid input"
					puts prompt
				end
			end
		end

	end
end