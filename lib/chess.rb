require_relative './node'
require_relative './pieces'
require_relative './board'
require 'yaml'

class Chess
  attr_accessor :player, :players, :board, :game_on
  def initialize(player1, player2)
    @players = [player1, player2]
    @player = player1
    @board = Board.new
    @game_on = true
  end
  def get_next
    next_player = (@player == players[0] ? players[1] : players[0])
    return next_player
  end
  def make_one_move
    puts "Enter your move: "
    input = gets.chomp
    case input
      when "quit", "exit"
        game_on = false
        exit_game
      when "save"
        save_file
      when /^([a-h][1-8],?\s?[a-h][1-8])$/
        begin
          start, target = parse_move(input)
          puts start, target
          @board.make_move(start, target)
        rescue InvalidMoveError => e
          puts e.message
          retry
        rescue WrongColorError => e
          puts e.message
          retry
       rescue MovedIntoCheckError => e
         puts e.message
          retry
        end
      else
        puts "Invalid input."
        puts "Enter your move in the format \'a2, c3\'"
        make_one_move
    end
  end
  def parse_move(str)
    a = str.split("")
    a = translate_move(a)
    return a;
  end
  def translate_move(a)
    cols = ("a".."h").to_a
    dict = {}
    cols.each_with_index { |x, i| dict[x] = i }
    row = a[1].to_i - 1
    col = dict[(a[0])]
    return [row, col]
  end
  def play_one_turn
    while @game_on do
      color = @player.color
      @board.color = color
      next_player = get_next
      @board.grid.flatten do |piece|
        if piece.color == @board.color && piece.instance_of?(Pawn)
          piece.en_passant = false
        end
      end
      puts "#{player.name}:"
      make_one_move
      puts "#{color} king is in check" if @board.check?(color)
      if @board.check_mate?(color)
        puts "Checkmate!"
        @game_on = false
      end
      @player = next_player
    end
    play_again?
  end
  def exit_game
    prompt = "press 's' to save, ''q' to quit, or 'c' to cancel:"
    puts prompt
    input = gets.chomp.downcase
    case input
      when "s"
        save
      when "q"
        puts "Goodbye!"
        exit
      when "c"
        play_one_turn
      else
        puts prompt
       input
    end
  end
  def save
    filename = ""
    while filename.empty?
      prompt = puts "Enter filename: "
      input = gets.chomp
      if File.exists?("#{input}.txt")
        puts "File already exists.  Overwrite file? (y/n)"
        answer = gets.chomp.downcase
        if answer == "y"
          filename = input
        else 
          prompt
        end
      else
        filename = "#{input}.txt"
      end
    end
    save_file(filename)
  end
  def save_file(file)
    unless Dir.exist?("games")
      Dir.mkdir("games")
    end
    contents = YAML::dump(self)
    puts "Saving #{file}..."
    f = File.open("games/#{file}.yaml", "w")
    f.puts contents
    f.close
    exit
  end

  def load_file(file)
    puts "Loading file #{file}..."
    f = YAML::load(File.open("games/#{file}.yaml", "r+"))
    @players = f.players
    @player = f.player
    @board = f.board
    @game_on = true
  end
end

class Player
  attr_accessor :name, :color
  def initialize(name, color)
    @name = name
    @color = color
  end
end
def main
  puts "Welcome to chess!"
  puts "Player1, enter your name: "
  p1 = gets.chomp
  puts "Player2, enter your name: "
  p2 = gets.chomp
  players = choose_first(p1, p2)
  player1 = Player.new(players[0], "w")
  player2 = Player.new(players[1], "b")
  game = Chess.new(player1, player2)
  game.play_one_turn
end
def choose_first(p1, p2)
  first = [p1, p2].sample
  first == p1 ? [p1, p2] : [p2, p1]
end
def play_again?
  input = gets.chomp.downcase
  if input == "y"
    main
  elsif  input == "n"
    exit
  else
    play_again?
  end
end



