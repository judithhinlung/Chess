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
  describe '#alt_color' do
    it "Returns the alt color" do
    end
  end

  describe '#make_move' do
    it "checks if piece has right color" do
    end

    it "checks if piece is moving into check" do
    end
    it "checks for valid moves" do
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
    end
  end

  describe '#find_king' do
    it "finds the king" do
    end
  end

  describe '#check?' do
    it "checks for check" do
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
end
