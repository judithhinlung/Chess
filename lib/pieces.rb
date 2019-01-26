require_relative './node'
require_relative './exceptions'

class Piece 
  attr_reader :symbol, :color
  attr_accessor :location, :board, :moved, :valid_moves
  def initialize(color, location, board)
    @color = color
    @location = location 
    @board = board 
    @moved = false 
    @valid_moves = []
    @symbol = (@color == "w" ? symbols[0] : symbols[1])
  end
  def symbols
  ["\u2581", "\u2580"]
  end
  def horrizontal 
    [[1, 0], [-1, 0], [0, 1], [0, -1]]
  end
  def diagonal
  [[1, 1], [1, -1], [-1, 1], [-1, -1]]
  end
  def possible_moves
    horrizontal + diagonal
  end
  def move(new_loc)
    get_moves(new_loc)
    if @valid_moves.include?(new_loc)
      @moved = true
      prev_loc = self.location
      row, col = new_loc
      @board.grid[row][col] = self
      self.location = new_loc
      row, col = prev_loc
      @board.grid[row][col] = nil
    end
  end
  def get_moves(target=nil)
    moves = []
    possible_moves.each do |move|
      queue = []
      queue.push(@location)
      until queue.empty?
        current = queue.shift
        next_pos = [(move[0] + current[0]), (move[1] + current[1])]
        row, col = next_pos
        break if @board.out_of_bounds?(next_pos)
        piece = @board.grid[row][col]
        if (!target.nil? && next_pos[0] == target[0] && next_pos[1] == target[1])
          if piece.nil? || (!piece.nil? &&  piece.color != self.color)
            queue << next_pos
            moves << next_pos
          end
          break
        elsif piece.nil?
          queue << next_pos
         moves << next_pos
        else 
        break
        end
      end
    end
    @valid_moves = moves
  end
  def to_s
    return @symbol.encode('utf-8')
  end
end

class Knight < Piece
  def initialize(color, location, board)
    super(color, location, board)
  end
  def symbols
    ["\u2658", "\u265E"]
  end
  def possible_moves
    [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [-2, 1], [2, -1], [-2, -1]]
  end
  def get_moves(target=nil)
    moves = []
    current = self.location
    possible_moves.each do |move|
      next_pos = [(move[0] + current[0]), (move[1] + current[1])]
      moves << next_pos unless @board.out_of_bounds?(next_pos)
    end

    @valid_moves = moves
  end
end

class King < Piece
  def initialize(color, location, board)
    super(color, location, board)
  end
  def symbols
    ["\u2654", "\u265A"]
    end
  def possible_moves
    horrizontal + diagonal
  end 

  def move(new_loc)
    get_moves
    if self.location[0] == new_loc[0] && (self.location[1] - new_loc[1]).abs == 2
      castle(new_loc)
    else
      super(new_loc)
    end
    @moved = true
  end
  def find_rook(new_loc)
    rook = @board.grid.flatten.compact.select do |piece|
      piece.location[0] == new_loc[0] &&
      piece.instance_of?(Rook) &&
      piece.color == self.color &&
      !piece.moved &&
      (piece.location[1] - new_loc[1]).abs == 2
    end
    return rook[0]
  end
  def can_castle?(rook)
    if self.moved
      puts "King has previously moved"
      return false
    end
    if rook.nil?
      puts "Rook has moved"
      return false
    end
    if self.location[1] < rook.location[1]
      current = self.location
      final = rook.location
    elsif rook.location[1] < self.location[1]
      current = rook.location
      final = self.location
    end    
    until current[1] == final[1] - 1 do
      next_pos = [current[0], current[1] + 1]
      square = @board.grid[next_pos[0]][next_pos[1]]
      if !square.nil?
         puts "Square [#{current[0]}, #{current[1]}] is occupied"
        return false
      end
      if @board.attacked?(square, self.color)
        puts "Cannot place king in check"
        return false
      end
      current[1] += 1
    end
    return true
  end
  def castle(new_loc)
    get_moves
    rook = find_rook(new_loc)
    if can_castle?(rook)
      if new_loc[1] < self.location[1]
        self.location = new_loc
        rook.location[1] = self.location[1] + 1
      elsif new_loc[1] > self.location[1]
        self.location = new_loc
        rook.location[1] = self.location[1] - 1
      end
      row, col = self.location
      @board.grid[row][col] = self
      row, col = rook.location
      @board.grid[row][col] = self
    else
      raise InvalidMoveError.new("Cannot make a castling move")
    end
  end
  def get_moves(target=nil)
    queue = []
    current = self.location
    possible_moves.each do |move|
      next_pos = [(move[0] + current[0]), (move[1] + current[1])]
      queue << next_pos unless @board.out_of_bounds?(next_pos) || !@board.grid[next_pos[0]][next_pos[1]].nil?
    end
    @valid_moves = queue
    if !self.moved
      @valid_moves << [self.location[0], self.location[1] + 2]
      @valid_moves << [self.location[0], self.location[1] - 2]
    end
    return @valid_moves
  end
end


class Queen < Piece
  def initialize(color, location, board)
    super(color, location, board)
  end
  def symbols
    ["\u2655", "\u265B"]
  end
  def possible_moves
    horrizontal + diagonal
  end
end

class Rook < Piece
  def initialize(color, location, board)
    super(color, location, board)
    if @color == "w"
      @symbol = "\u2656"
    else
      @symbol = "\u265C"
    end
  end
  def possible_moves
    horrizontal
  end
end

class Bishop < Piece
  def initialize(color, location, board)
    super(color, location, board)
    if @color == "w"
      @symbol = "\u2657"
    else
      @symbol = "\u265D"
    end
  end
 def possible_moves
    diagonal
  end
end

class Pawn < Piece
  attr_accessor :en_passant
  def initialize(color, location, board)
    super(color, location, board)
    @en_passant = false
    if @color == "w"
      @symbol = "\u2659"
      @direction = 1
    else
      @symbol = "\u265F"
      @direction = -1
    end
  end
  def possible_moves
    [[1, 0], [1, 1], [1, -1], [2, 0]]
  end
  def get_moves(target=nil)
    next_move_free = false
    row, col = self.location
    moves = []
    possible_moves.each_with_index do |move, index|
      target = [(row + (move[0]*@direction)), (col + move[1])]
      target_piece = @board.grid[(row + (move[0]*@direction))][(col + move[1])]
      case index
      when 0
        if target_piece.nil?
          next_move_free = true
          moves << target
        end
      when possible_moves.length - 1
        if !self.moved && target_piece.nil? && next_move_free
          moves << target 
        end
      else
        moves << target if !target_piece.nil? && target_piece.color != self.color
      end
    end
    moves = moves.reject { |move| @board.out_of_bounds?(move) }
    @valid_moves = moves
  end
  def move(new_loc)
    @en_passant = true if (self.location[0] == new_loc[0]) && ((self.location[1] - new_loc[1]).abs == 2)
    super(new_loc)
  end
end
