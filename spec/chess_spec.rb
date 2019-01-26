require './lib/chess'

RSpec.describe Player do
  player = Player.new("Jack", "w")
  it "Returns the name of a player" do
    expect(player.name).to eql("Jack");
  end
  it "Returns the color of a player" do
    expect(player.color).to eql("w");
  end
end

RSpec.describe Chess do
  player1 = Player.new("Jack", "w")
  player2 = Player.new("Amy", "b")
  game = Chess.new(player1, player2)
  describe "#get_next" do
    it "Returns next player" do
      expect(game.get_next).to eql(player2)
    end
  end

  it "Returns current board color" do
    expect(game.board.color).to eql("w")
  end
  describe "#parse_move" do
    it "Translates move to row, col" do
      expect(game.parse_move("c3")).to eql([2, 2])
    end
  end
end

RSpec.describe Board do
    game = Board.new
    game.setup_board
  describe '#setup_board' do
    it "Checks for white rook" do
      expect(game.grid[0][0].instance_of?(Rook)).to eql(true)
    end

    it "Checks for white king" do
      expect(game.grid[0][4].instance_of?(King)).to eql(true)
    end
  end
  describe '#alt_color' do

    it "Returns the alt color" do
      expect(game.alt_color("w")).to eql("b")
    end
  end

  describe '#make_move' do
    it "checks if piece is moving into check" do
      game = Board.new
      game.setup_board
      game.color = "b"
      knight = game.grid[7][1]
      knight.move([5, 2])
      knight.move([4, 0])
      pawn = game.grid[6][1]
      pawn.move([5, 1])
      bishop = game.grid[7][2]
      bishop.move([6, 1])
      bishop.move([5, 2])
      queen = game.grid[7][3]
      pawn = game.grid[6][4]
      pawn.move([4, 4])
      queen.move([6, 4])
      w_knight = game.grid[0][6]
      w_knight.move([1, 4])
      w_knight.move([2, 2])
      w_knight.move([4, 1])
      w_knight.move([5, 3])
      w_knight.move([6, 1])
      king = game.grid[7][4]
      expect(game.moved_into_check?(king, [7, 3])).to eql(true)
    end
    it "checks for white pawn valid move" do
      pawn = game.grid[1][0]
      pawn.move([2, 0])
      expect(game.grid[1][0].nil?).to eql(true)
    end
    it "checks for black pawn validmove" do
      pawn = game.grid[6][0]
      pawn.move([5, 0])
      expect(game.grid[6][0].nil?).to eql(true)
    end
    it "checks for white rook invalid moves" do
      rook = game.grid[0][0]
      rook.get_moves
      expect(rook.valid_moves.include?([2, 0])).to eql(false)
    end

    it "checks for white rook valid moves" do
      rook = game.grid[0][0]
      pawn = game.grid[2][0]
      pawn.move([3, 0])
      rook.get_moves
       expect(rook.valid_moves.include?([1, 0])).to eql(true)
    end
    it "checks for black rook invalid moves" do
      rook = game.grid[7][0]
      rook.get_moves
      expect(rook.valid_moves.include?([5, 0])).to eql(false)
    end

    it "checks for black rook valid moves" do
      rook = game.grid[7][0]
      pawn = game.grid[5][0]
      pawn.move([4, 0])
      rook.get_moves
       expect(rook.valid_moves.include?([6, 0])).to eql(true)
    end
    it "checks for white knight invalid moves" do
      knight = game.grid[0][1]
      knight.get_moves
      expect(knight.valid_moves.include?([2, 1])).to eql(false)
    end

    it "checks for white knight valid moves" do
      knight = game.grid[0][1]
      knight.get_moves
       expect(knight.valid_moves.include?([2, 2])).to eql(true)
    end
    it "checks for black knight invalid moves" do
    game = Board.new
      game.setup_board
      knight = game.grid[7][1]
      knight.get_moves
#      expect(knight.valid_moves.include?([5, 1])).to eql(false)
    end

    it "checks for black knight valid moves" do
      knight = game.grid[7][1]
      knight.get_moves
       expect(knight.valid_moves.include?([5, 2])).to eql(true)
    end
  end

  describe '#capture' do
    it "captures en_passant pawn" do
    end

    it "captures rook" do
    end
  end

  describe '#attacked?' do
    it "checks if a square is being attacked" do
      game = Board.new
      game.setup_board
      expect(game.attacked?([1, 3], "b")).to eql(true)
    end

    it "checks if a square is being attacked" do
      game = Board.new
      game.setup_board
      expect(game.attacked?([1, 3], "w")).to eql(false)
    end
  end

  describe '#find_king' do
    it "finds the king" do
      puts game.find_king("w").color
      expect(game.find_king("w").instance_of?(King)).to eql(true)
    end
  end



  describe '#check?' do
    it "checks for check" do
      expect(game.check?("w")).to eql(false)
    end

    it "Checks for check" do
      game = Board.new
      game.setup_board
      game.color = "b"
      knight = game.grid[7][1]
      knight.move([5, 2])
      knight.move([4, 0])
      pawn = game.grid[6][1]
      pawn.move([5, 1])
      bishop = game.grid[7][2]
      bishop.move([6, 1])
      bishop.move([5, 2])
      queen = game.grid[7][3]
      pawn = game.grid[6][4]
      pawn.move([4, 4])
      queen.move([6, 4])
      w_knight = game.grid[0][6]
      w_knight.move([1, 4])
      w_knight.move([2, 2])
      w_knight.move([4, 1])
      w_knight.move([5, 3])
      w_knight.move([6, 1])
      king = game.grid[7][4]
      king.move([7, 3])
      expect(game.check?(king.color)).to eql(true)
    end
  end

  describe '#check_mate?' do
    it "checks for checkmate" do
    end
  end

  describe '#moved_into_check?' do
    it "returns true if next move is checked" do
    end
  end
  describe '#remove' do
    it "Removes a piece from the board" do
      game = Board.new
      game.grid[1][1] = Piece.new("b", [1, 1], game)
      game.remove(game.grid[1][1])
    expect(game.grid[1][1].nil?).to eql(true)
    end
  end
end

RSpec.describe King do
  describe "#get_moves" do
    game = Board.new
    game.setup_board
    it "checks for white king invalid moves" do
      king = game.grid[0][4]
      king.get_moves
      expect(king.valid_moves.include?([1, 4])).to eql(false)
    end

    it "checks for white king valid moves" do
      pawn = game.grid[1][4]
      pawn.move([2, 4])
      king = game.grid[0][4]
      king.get_moves
       expect(king.valid_moves.include?([1, 4])).to eql(true)
    end

    it "checks for black king invalid moves" do
      king = game.grid[7][4]
      king.get_moves
      expect(king.valid_moves.include?([6, 4])).to eql(false)
    end

    it "checks for white king valid moves" do
      pawn = game.grid[6][4]
      pawn.move([5, 4])
      king = game.grid[7][4]
      king.get_moves
       expect(king.valid_moves.include?([6, 4])).to eql(true)
    end
  end

  describe "#move" do
    game = Board.new
    game.setup_board
    it "checks if king has moved" do
      king = game.grid[0][4]
      pawn = game.grid[1][4]
      pawn.move([2, 4])
      king.move([1, 4])
      expect(king.location == [1, 4]).to eql(true)
    end

    it "checks if board has updated" do
      expect(game.grid[0][4].nil?).to eql(true)
    end
  end

  describe "#find_rook" do
    game = Board.new
    game.setup_board
    it "Finds the rook" do
      king = game.grid[0][4]
      rook = king.find_rook([0, 2])
      expect(rook.location == [0, 0]).to eql(true)
    end

    it "Invalid for finding rook" do
      king = game.grid[0][4]
      pawn = game.grid[1][0]
      pawn.move([2, 0])
      rook = game.grid[0][0]
      rook.move([1, 0])
      rook = king.find_rook([0, 2])
      expect(rook.nil?).to eql(true)
    end
  end

  describe '#can_castle?' do
    it "Checks for castling condition king has moved" do
      game = Board.new
      game.setup_board
      king = game.grid[7][4]
      pawn = game.grid[6][4]
      king.move([6, 4])
      rook = game.grid[7][0]
      expect(king.can_castle?rook).to eql(false)
    end

    it "Checks for castling condition rook has moved" do
      game = Board.new
      game.setup_board
      king = game.grid[7][4]
      pawn = game.grid[6][0]
      pawn.move([5, 0])
      rook = game.grid[7][0]
      rook.move([6, 0])
      expect(game.grid[7][0].nil?).to eql(true)
    end
    it "Checks for castling condition rook has moved" do
      game = Board.new
      game.setup_board
      king = game.grid[7][4]
      pawn = game.grid[6][0]
      pawn.move([5, 0])
      rook = game.grid[7][0]
      rook.move([6, 0])
      rook = game.grid[7][0]
      expect(king.can_castle?(rook)).to eql(false)
    end
  end

    it "Checks for castling condition pieces between rook and king" do
      game = Board.new
      game.setup_board
      king = game.grid[7][4]
      rook = game.grid[7][7]
      expect(king.can_castle?(rook)).to eql(false)
    end
    it "Checks for castling condition places king in check" do
      game = Board.new
      game.setup_board
      knight = game.grid[7][1]
      knight.move([5, 2])
      knight.move([4, 0])
      pawn = game.grid[6][1]
      pawn.move([5, 1])
      bishop = game.grid[7][2]
      bishop.move([6, 1])
      bishop.move([5, 2])
      queen = game.grid[7][3]
      pawn = game.grid[6][4]
      pawn.move([5, 4])
      pawn.move([4, 4])
      queen.move([6, 4])
      w_knight = game.grid[0][6]
      w_knight.move([1, 4])
      w_knight.move([2, 2])
      w_knight.move([4, 1])
      w_knight.move([5, 3])
      w_knight.move([6, 1])
      square = [7, 3]
      expect(game.attacked?(square, "b")).to eql(true)
    end

    it "Checks for castling condition places king in check" do
      game = Board.new
      game.setup_board
      knight = game.grid[7][1]
      knight.move([5, 2])
      knight.move([4, 0])
      pawn = game.grid[6][1]
      pawn.move([5, 1])
      bishop = game.grid[7][2]
      bishop.move([6, 1])
      bishop.move([5, 2])
      queen = game.grid[7][3]
      pawn = game.grid[6][4]
      pawn.move([5, 3])
      pawn.move([4, 3])
      queen.move([6, 4])
      w_knight = game.grid[0][6]
      w_knight.move([1, 4])
      w_knight.move([2, 2])
      w_knight.move([4, 1])
      w_knight.move([5, 3])
      w_knight.move([6, 1])
      king = game.grid[7][4]
      rook = game.grid[7][0]
      expect(king.can_castle?(rook)).to eql(false)
    end

end
