module Chess
	class Game
		attr_reader :board, :players, :current_player, :other_player
		def initialize(board = Board.new)
			@board = board
			@players = get_players
			@current_player,@other_player = players.shuffle
			play_game
		end

		def get_players
			puts "Player 1, please type your name:"
			player_1 = gets.chomp
			puts "Player 2, please type your name:"
			player_2 = gets.chomp
			return [Chess::Player.new(player_1,"X"), Chess::Player.new(player_2,"O")]
		end

		def switch_player
			@current_player,@other_player = @other_player,@current_player
		end

		def get_coordinate
			while move = gets
				if move.match(/\d/) && move >=0 && move <= 7
					return move.to_i
					break
				else
					puts "Invalid move input"
				end
			end
		end

		def get_move
			until row <= 0 && row <=7 
				p "#{current_player.name}, choose a row:"
				row = get_coordinate
			end

			until col <= 0 && col <=7 
				p "#{current_player.name}, choose a column:"
				col = get_coordinate
			end
			[row,col]
		end

		def game_over_message
			return "#{current_player.name} wins!" if board.game_over == :winner
			return "Stalemate!" if board.game_over == :draw 
		end

		def play_game
			p "#{current_player.name} has been randomly chosen to go first."
			while true
				board.display_board
				puts ""
				solicit_move
				while move_from = get_move && move_to = get_move
					if board.check_move(move_from,move_to)
						board.move_piece(move_from,move_to)
						break
					else
						p "invalid move"
						solicit_move
					end
				end
				if board.game_over != false
					board.display_board
					p "END"
				else
					switch_player
				end
			end
		end
	end
end