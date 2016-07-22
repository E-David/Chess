require 'yaml'

module Chess
	class Game
		attr_accessor :players, :current_player, :other_player, :board 
		def initialize(board = Board.new)
			@board = board
			@players = players
			@current_player = current_player
			@other_player = other_player
			check_for_file			
		end

		def check_for_file
			if File.exists?("file.yml")
				puts "saved game found. Type new to begin a new game or load to continue this game."
				while answer = gets.chomp.downcase
					if answer == "new"
						game_setup
					elsif answer == "load"
						load_game
					else
						p "invalid response"
						check_for_file
					end
				end
			else
				game_setup
			end
		end

		def save_game
			File.open("file.yml", "w") do |f| 
				f.write YAML::dump(self)
			end
			puts "Game saved!" if File.exists?("file.yml")
		end

		def load_game
			game = YAML::load(File.read("file.yml"))
			self.current_player = game.current_player
      		self.other_player = game.other_player
      		self.board = game.board
			play_game
		end

		def game_setup
			get_players
			set_players
			play_game
		end

		def get_players
			puts "Player 1, please type your name:"
			player_1 = gets.chomp
			puts "Player 2, please type your name:"
			player_2 = gets.chomp
			@players = [Chess::Player.new(player_1,""), Chess::Player.new(player_2,"")]
		end

		def set_players
			@current_player,@other_player = players.shuffle
			@current_player.color = "white"
			@other_player.color = "black"
		end

		def switch_player
			@current_player,@other_player = @other_player,@current_player
		end

		def get_coordinate
			while coord = gets.chomp.split("")
				if coord.size != 2
					puts "Please type a letter + number"	
				else		
					if !coord[0].match(/[A-H]|[a-h]/)
						puts "invalid column"
					elsif (coord[1].to_i >= 1 && coord[1].to_i <= 8) == false
						puts "invalid row"
					else
						break
					end
				end
			end
			coord[1] = coord[1].to_i
			coord.unchessify_coordinates
		end

		def validate_move_from(coordinate)
			return false if board.is_unoccupied?(coordinate)
			board.get_piece(coordinate).color == current_player.color
		end

		def game_over_message
			return "#{current_player.name} wins!" if board.game_over(other_player.color) == :winner
			return "Stalemate!" if board.game_over(other_player.color) == :draw 
		end

		def play_game
			puts "#{current_player.name} has been randomly chosen to go first."
			puts ""
			while true
				board.display_board
				until false 
					puts "#{current_player.name}, choose a piece to move"
					move_from = get_coordinate
					puts board.get_piece(move_from).to_s
					if validate_move_from(move_from) == false
						puts "You did not select a piece of your color"
					elsif board.get_legal_moves(move_from).empty?
						puts "No available moves for this piece"
					else
						puts "Available moves: #{board.show_legal_moves(move_from)}"
						break
					end
				end

				until false 
					puts "#{current_player.name}, choose a destination"
					move_to = get_coordinate
					puts board.get_piece(move_to).to_s if board.get_piece(move_to) != ""
					if board.check_move(move_from,move_to) == true
						board.move_piece(move_from,move_to)
						break
					else
						puts board.check_move(move_from,move_to)
					end
				end

				if board.game_over(other_player.color) != false
					p game_over_message
					board.display_board
					break
				else
					switch_player
					save_game
				end
			end
			restart?
		end

		def restart?
			prompt = "Would you like to play again?"
			puts prompt
			while answer = gets.chomp
				if answer == "yes" || answer == "y" || answer == "1"
					x = Chess::Game.new
					x.play_game
					break
				elsif answer == "no" || answer == "n" || answer == "0"
					p "Thanks for playing Chess!"
					break
				else
					p "invalid input"
					puts prompt
				end
			end
		end
	end
end