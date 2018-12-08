class Node
  attr_accessor :x, :y, :next_node, :moves

  def initialize(x, y, next_node=nil, distance=0, moves=[])
    @x = x
    @y = y
    @next_node = next_node
    @moves = []
  end



class Piece
  attr_accessor :location, :board
  def initialize(location, board)
    @board = board
    @location = location
    @moves = get_moves
  end
  def move(new_loc)
    new_loc_node = Node.new(x, y)
    if @moves.include?(new_loc_node)
      @location = new_lo
    puts "Moved to #{new_loc[0]}, {#new_loc[1]}."
  end

  def get_moves
    return nil
  end
end

