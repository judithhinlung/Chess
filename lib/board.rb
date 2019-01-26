require_relative './pieces.rb'

class Board
  attr_accessor :grid, :color, :captured_pieces

  def initialize(grid=nil)
    @color = "w"
    @grid = grid
    setup_board if @grid.nil?
  end
  def setup_board
    grid = Array.new(8) {Array.new(8)}
    8.times do |col|
      case col
      when 0, 7
        grid[0][col] = Rook.new("w", [0, col], self)
        grid[7][col] = Rook.new("b", [7, col], self)
      when 1, 6
        grid[0][col] = Knight.new("w", [0, col], self)
        grid[7][col] = Knight.new("b", [7, col], self)
      when 2, 5
        grid[0][col] = Bishop.new("w", [0, col], self)
        grid[7][col] = Bishop.new("b", [7, col], self)
      when 3
        grid[0][col] = Queen.new("w", [0, col], self)
        grid[7][col] = Queen.new("b", [7, col], self)
      when 4
        grid[0][col] = King.new("w", [0, col], self)
        grid[7][col] = King.new("b", [7, col], self)
      end
    end
    8.times do |col|
      grid[1][col] = Pawn.new("w", [1, col], self)
      grid[6][col] = Pawn.new("b", [6, col], self)
    end
    @grid = grid
  end
  def alt_color(color)
  color == "w" ? "b" : "w"
  end
  def make_move(start, target)
    begin
      row, col = start
      piece = @grid[row][col]
      raise NoPieceAtLocationError.new("No piece at current location") if piece.nil?

      if piece.color != self.color
        raise WrongColorError.new("Please select your own color::#{self.color}")
      end
      if moved_into_check?(piece, target)
        raise MovedIntoCheckError.new("Cannot make a move that puts king in check")
      end
      piece.get_moves
      if piece.valid_moves.include?(target)
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
    if piece.instance_of?(Pawn) && piece.location == target[row][col - 1]
      target_piece = @grid[row][col-1] if en_passant?(@grid[row][col])
      target_piece = @grid[row][col+1] if en_passant?(@grid[row][col+1])
    else
      target_piece = @grid[row][col]
    end
    remove(target)
  end
  def en_passant?(piece)
    return true if !piece.nil? && piece.instance_of?(Pawn) && piece.en_passant
    return false
  end
  def remove(piece)
    row, col = piece.location
    @grid[row][col] = nil
    piece.location = nil
  end
  def out_of_bounds?(move)
    return true if (move[0] < 0 || move[0] > 7 ||
    move[1] < 0 || move[1] > 7)
    return false
  end
  def attacked?(square, color)
    alt = alt_color(color)
    is_attacked = false
    opponents = @grid.flatten.compact.select do |piece| 
      piece.color == alt
    end
    opponents.each do |piece|
      piece.get_moves
      moves = piece.valid_moves
      if moves.include?(square)
        is_attacked = true
      end
    end
    return is_attacked
  end
  def find_king(color)
    king = @grid.flatten.select { |piece|
!piece.nil? && piece.color == color && piece.instance_of?(King) }[0]

    return king
  end
  def check?(color)
    king = find_king(color)
    return attacked?(king.location, color)
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
    row, col = piece.location
    tmp_board = copy_board
    tmp_piece = tmp_board.grid[row][col]
    tmp_piece.move(target)
    return tmp_board.check?(piece.color)
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
    end
      puts puts
    puts "   " + "A B C D E F G H".downcase
  end
end
