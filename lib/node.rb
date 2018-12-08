# Linked lists used to construct the paths of slidersclass Node

class Node
  attr_accessor :x, :y, :next_node, :moves

  def initialize(x, y, next_node=nil, distance=0, moves=[])
    @x = x
    @y = y
    @next_node = next_node
    @moves = moves
  end
  def equal?(node)
    return true if self.x == node.x && self.y == node.y
    return false
  end
end
