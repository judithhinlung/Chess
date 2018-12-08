

class Board
  attr_accessor :grid, :color, :captured_pieces

  def initialize(grid=nil)
    @color = "w"
    @grid = grid
    setup_board if @grid.nil?
  end
  def setup_board
    @grid = Array.new(8) {Array.new(8)}
    8.times do |col|
      case col
      when 0, 7
        @grid[0][col] = Rook.new("w", [0, col], self)
        @grid[7][col] = Rook.new("b", [7, col], self)
      when 1, 6
        @grid[0][col] = Knight.new("w", [0, col], self)
        @grid[7][col] = Knight.new("b", [7, col], self)
      when 2, 5
        @grid[0][col] = Bishop.new("w", [0, col], self)
        @grid[7][col] = Bishop.new("b", [7, col], self)
      when 3
        @grid[0][col] = Queen.new("w", [0, col], self)
        @grid[7][col] = Queen.new("b", [7, col], self)
      when 4
        @grid[0][col] = King.new("w", [0, col], self)
        @grid[7][col] = King.new("b", [7, col], self)
      end
    end
    8.times do |col|
      @grid[1][col] = Pawn.new("w", [1, col], self)
      @grid[6][col] = Pawn.new("b", [6, col], self)
    end
  end
  def alt_color(color)
  color == "w" ? "b" : "w"
  end
  def make_move(start, target)
    begin
      row, col = start
      piece = @grid[row][col]
      if piece.color != self.color
        raise WrongColorError.new("Please select your own color::#{self.color}")
      end
      if piece.moves.include?(target)
      # TODO: moved into check
        capture(piece, target)
        piece.move(target)
      else 
        raise InvalidMoveError.new("Invalid move")
      end
    end
  end
  def capture(piece, target)
    row, col = target
    return if target.nil?
    if piece.instanceof(Pawn) && piece.location == target[row][col - 1]
      target_piece = @grid[row][col-1] if en_passant?(@grid[row][col])
      target_piece = @grid[row][col+1] if en_passant?(@grid[row][col+1])
    else
      target_piece = @grid[row][col]
    end
    piece.remove(target)
  end
  def en_passant?(piece)
    return true if !piece.nil? && piece.instanceof(Pawn) && piece.en_passant
    return false
  end
  def attacked?(square, color)
  attacked = false
    opponents = @grid.flatten.select do |piece| 
      piece.color != color
    end
    opponents.each do |piece|
      piece.get_moves
      moves = piece.moves
      if moves.include?(square)
        puts "#{[square[0],square[1]]} is under attack by a #{piece.color} #{piece.class.name}."
     attacked = true
      end
    end
    return attacked
  end
  def find_king(color)
    king = @board.select do |piece| 
      piece.color == color && piece.instanceof(King)
    end
    return king
  end
  def check?(color)
    king = find_king(color)
    return attacked?(king.position, color)
  end
  def check_mate?(color)
    if check?(color)
      moves = king.get_moves
      moves.all? { |move| attacked?(move, color) }
    end
    return false
  end
  def copy_board
    new_board = Board.new
    new_grid = Array.new(8) { Array.new(8) }
    @grid.each_with_index do |row, row_index| 
      row.each_with_index do |col, col_index|
        piece = @grid[row_index][col_index]
        next if piece.nil?
        new_piece = piece.class.new(self.color, [row_index, col_index], new_board)
        new_grid[row_index][col_index] = piece
      end
    end
    new_board.grid = new_grid
    new_board.color = self.color
    return new_board
  end
  def moved_into_check?(piece, target)
    row, col = piece.position
    tmp_board = copy_board
    tmp_piece = tmp_board[row][col]
    move(tmp_piece, target)
    return tmp_board.check?(@color)
  end
  def to_s
    puts "   " + "A B C D E F G H".downcase
    puts puts
    7.downto(0) do |row|
      print row + 1
      0.upto(7) do |col|
        if @grid[row][col].nil?
                 print "\u2581"
        else
          print @grid[row][col]
        end
      end
      puts puts
    puts "   " + "A B C D E F G H".downcase
    end
  end
end
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
      row, col = @location
      @board.grid[row][col] = nil
      row, col = new_loc
      @board.grid[row][col] = self
      @location = new_loc
    else
      puts "Invalid move"
    end
  end
  def remove(piece)
    puts "Removing #{piece.color} #{piece.class}..."
    row, col = piece.position
    @board.grid[row][col] = nil
    piece.location = nil
  end
  def out_of_bounds?(move)
    return true if (move[0] < 0 || move[0] > 7 ||
    move[1] < 0 || move[1] > 7)
    return false
  end
  def get_moves(target=nil)
    queue = []
    queue.push(@location)
    current = queue.first
    until queue.empty?
      possible_moves.each do |move|
        next_pos = [(move[0] + current[0]), (move[1] + current[1])]
        piece = @board.grid[next_pos[0], next_pos[1]]
        target_piece = @board.grid[target[0], target[1]] unless target.nil?
        if  !(out_of_bounds?(next_pos)) ||
        (!target_piece.nil? && target_piece.color != self.color) ||
        (piece.nil? && piece.color != self.color)
        queue << move
         end
      end
    queue.shift
    end
    @valid_moves = queue
    return @valid_moves
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
    queue = []
    queue.push(@location)
    current = queue.first
    until queue.empty? do
      possible_moves.each do |move|
        next_pos = [(move[0] + current[0]), (move[1] + current[1])]
        queue << move unless   out_of_bounds?(next_pos)
      end
    queue.shift
    end
    @valid_moves = queue
    return @valid_moves
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
    distance = (new_loc[1] - @location[1])
    if !@moved && (distance.abs == 2)
      castle(new_loc)
    else
      super(new_loc)
    end
  end
  def find_rook
    @board.grid.flatten.select do |piece|
      piece.position[0] == self.position[0] &&
      piece.instanceof(Rook) &&
      piece.color == self.color &&
      !piece.moved
    end
    return piece
  end
  def castle?
    rook = find_rook
    return false if rook.nil?
    if self.position[1] < rook.position[1]
      current = self.position
      final = rook.position
    elsif rook.position[1] < self.position[1]
      current = rook.position
      final = self.position
    end    
    while current <= final do
      next_pos = [current[0], current[1 + 1]]
      square = @board[current[0], current[1]]
      if !square.nil?
        puts "Invalid move: square occupied."
        return false
      end
      if @board.attacked?(square, self.color)
        puts "Invalid move: placing king in check!"
        return false
      end
      current = next_pos
    end
    return true
  end
  def castle(new_loc)
    if castle?
      rook = find_rook
      if new_loc[1] < self.position[1] && rook.position[1] < self.position[1]
        self.location = new_loc
        rook.location = [self.location[0], self.location[1 + 1]]
      elsif self.location < rook.location && new_loc > self.location
        self.location = new_loc
        rook.location = [self.location[0], self.location[1-1]]
      end
    end
  end
  def get_moves(target=nil)
    queue = []
    queue.push(@location)
    current = queue.first
    possible_moves.each do |move|
      next_pos = [(move[0] + current[0]), (move[1] + current[1])]
      queue << next_pos unless out_of_bounds?(next_pos)
    end
    @valid_moves = queue
    return @valid_moves
  end
end

# Slider class for rook, queen, bishop who cannot leap over other pieces
class Slider < Piece
  def possible moves
    horrizontal + diagonal
  end
  def move(new_loc)
    target = find_path(@location, new_loc, possible_moves)
    path = find_path(target)
    display_path(path)
    super(new_loc)
  end
  def find_path(location, new_loc, possible_moves)
    row, col = @location
    start = Node.new(row, col)
    target = Node.new(new_loc[0], new_loc[1])
    queue = []
    queue.push(start)
    until queue.empty? do
      current = queue.first
      if current.equal?(target)
        return current
      end
      moves = find_moves(possible_moves, current)
      moves.each do |move|
        move.next_node = current
        queue << move
      end
      queue.shift
    end
  end
  def find_moves(moves, node)
    nodes = []
    moves.each do |move|
      move[0] = x
      move[1] = y    
      node = Node.new(current.x + x, current.y + y)
      nodes << node
    end
    nodes.reject do |node|
      node.x < 0 || node.x > 7 ||
      node.y < 0 || node.y > 7
    end
    nodes.reject do |node|
      x = node.x
      y = node.y
      @board[x][y].nil?
    end
    return nodes
  end
  def find_path(node)
    path = []
    until node.next_node.nil? do
      path << node
      node = node.next_node
    end
    return path.reverse
  end
  def display_path(path)
    path.each do |node|
      puts "[#{node.x}], [#{node.y}]"
    end
  end
end

class Queen < Slider
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

class Rook < Slider
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

class Bishop < Slider
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
  def get_moves
    next_move_free = false
    row, col = self.position
    possible_moves.each_with_index do |move, index|
      target_piece = @board.grid[(row + move[0])][col + (move[1] * @direction)]
      case index
      when 0
        if target_piece.nil?
          next_move_free = true
          moves << move
        end
      when possible_moves.length - 1
        if self.moved && target_piece.color != slef.color && next_move_free
          moves << move
        end
      else
        moves << move if !current_piece.nil? && piece.color != self.color
      end
    end
    return moves
  end
  def move(new_loc)
    moves = get_moves
    if moves.include?(new_loc)
      @en_passant = true if (self.location[0] == new_loc[0]) && (self.location[1] - new_loc[1]).abs == 2
      self.location = new_loc
    end
  end
end

a = Board.new
s = a.copy_board
s.to_s

