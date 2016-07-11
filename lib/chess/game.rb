module Chess
	class Game
		attr_accessor :players
		attr_reader :board, :current_player, :other_player
		def initialize(board = Board.new)
			@board = board
			@players = get_players
			@current_player,@other_player = players.shuffle
			@current_player.color = "white"
			@other_player.color = "black"
			play_game
		end

		def get_players
			puts "Player 1, please type your name:"
			player_1 = "Harry"
			puts "Player 2, please type your name:"
			player_2 = "Marge"
			@players = [Chess::Player.new(player_1,""), Chess::Player.new(player_2,"")]
		end

		def switch_player
			@current_player,@other_player = @other_player,@current_player
		end

		def get_row
			p "#{current_player.name}, choose a row"
			while row = gets.to_i
				if row >= 1 && row <= 8
					break
				else
					p "invalid input"
				end
			end
			row
		end

		def get_column
			p "#{current_player.name}, choose a column"
			while col = gets.to_i
				if col >= 1 && col <= 8
					break
				else
					p "invalid input"
				end
			end
			col
		end

		def get_coordinate
			[get_row,get_column]
		end

		def validate_move_from(coordinate)
			board.get_piece(coordinate).color == current_player.color
		end

		def game_over_message
			return "#{current_player.name} wins!" if board.game_over == :winner
			return "Stalemate!" if board.game_over == :draw 
		end

		def play_game
			p "#{current_player.name} has been randomly chosen to go first."
			puts ""
			while true
				board.display_board
				while move_from = get_coordinate
					p "#{current_player.name}, choose a piece"
					p board.get_piece(move_from).to_s
					p "Available Moves: #{board.possible_moves(move_from)}"
					if validate_move_from(move_from)
						break
					else
						p "You did not select a piece of your color"
					end
				end

				while move_to = get_coordinate
					p "#{current_player.name}, choose a destination"
					p board.get_piece(move_to).to_s
					if board.check_move(move_from,move_to) == true
						board.move_piece(move_from,move_to)
						break
					else
						p board.check_move(move_from,move_to)
					end
				end

				if board.game_over(current_player.color) == false
					board.display_board
					p "END"
					break
				else
					switch_player
				end
			end
		end
	end
end