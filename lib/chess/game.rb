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

		def get_column
			while col = gets.chomp
				if col.match(/[A-H]|[a-h]/)
					col = col.upcase.letter_to_number
					break
				else
					p "invalid input"
				end
			end
			col
		end

		def get_row
			while row = gets.to_i
				if row >= 1 && row <= 8
					row = row.reverse_number
					break
				else
					p "invalid input"
				end
			end
			row
		end

		def get_coordinate
			while coord = gets.chomp.split("")
				if coord.size != 2
					p "Please type a letter + number"	
				else
					coord = coord.unchessify_coordinates				
					if (coord[0].match(/[A-H]|[a-h]/)) == false
						p "invalid column"
					elsif (coord[1] >= 1 && coord[1] <= 8) == false
						p "invalid row"
					else
						break
					end
				end
			end
			coord
		end

		def validate_move_from(coordinate)
			return false if board.get_piece(coordinate) == ""
			board.get_piece(coordinate).color == current_player.color
		end

		def game_over_message
			return "#{current_player.name} wins!" if board.game_over(other_player.color) == :winner
			return "Stalemate!" if board.game_over(other_player.color) == :draw 
		end

		def play_game
			p "#{current_player.name} has been randomly chosen to go first."
			puts ""
			while true
				board.display_board
				p "#{current_player.name}, choose a piece to move"
				while move_from = get_coordinate
					p board.get_piece(move_from).to_s
					if validate_move_from(move_from) == false
						p "You did not select a piece of your color"
					elsif board.show_legal_moves(move_from).empty?
						p "No available moves for this piece"
					else
						p "Available Moves: #{board.show_legal_moves(move_from)}"
						break
					end
				end

				p "#{current_player.name}, choose a destination"
				while move_to = get_coordinate
					p board.get_piece(move_to).to_s if board.get_piece(move_to) != ""
					if board.check_move(move_from,move_to) == true
						board.move_piece(move_from,move_to)
						break
					else
						p board.check_move(move_from,move_to)
					end
				end

				if board.game_over(other_player.color) != false
					p game_over_message
					board.display_board
					break
				else
					switch_player
				end
			end
		end
	end
end