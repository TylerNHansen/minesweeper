require 'debugger'

class MineSweeper

  def initialize
    @board = Board.new
    @player = Player.new
  end

  def run

    until self.gameover?
      play_turn
    end

    display_result

  end

  def play_turn
    @player.display_board(@board)
    choice = @player.get_move

  end

  def display_result

  end

  def gameover?
    #STUB
    return true
  end


end

class Board
  ROWCOUNT = 9
  COLCOUNT = 9

  def initialize
    @minefield = Array.new(ROWCOUNT) { Array.new(COLCOUNT) {Tile.new} }
    self.connect_neighbors
    nil
  end


  def connect_neighbors
    self.each_tile_with_index do |tile, row, col|
      adj_indices(row,col).each do |target_pair|
        i, j = target_pair
        tile.add_neighbor(@minefield[i][j])
      end
    end
    nil
  end

  def in_board?(i,j)
    i.between?(0, ROWCOUNT - 1)}
    j.between?(0, COLCOUNT - 1)}
  end

  def adj_indices(i,j)
    candidates = [-1,-1,0,1,1].permutation(2).to_a.uniq.map do |pair|
      pair[0] += i
      pair[1] += j
      pair
    end
    candidates.select{ |pair| in_board?(pair.first, pair.last)}
  end

  def each_tile_with_index(&prc)
    @minefield.each_index do |row|
      @minefield[row].each_index do |col|
        prc.call(@minefield[row][col], row, col)
      end
    end
    nil
  end

  def plant_bombs(bombcount)
    until bombcount == 0
      i,j = rand(ROWCOUNT), rand(COLCOUNT)
      bombcount -= 1 if @minefield[i][j].plant
      p bombcount
    end
  end

  def render
    render_arr = []

    self.each_tile_with_index {|tile| render_arr << disp_tile(tile)}
    ROWCOUNT.times do |_|
      string
    end
    puts render_string
  end

  def disp_tile(tile)
    #test method please ignore
    return "X" unless tile.has_bomb
    "_"
  end

end

class Tile

  DISPLAYSET = {
    :hidden => "*",
    :flagged => "F",
    :zero => "_",
    :one => "1",
    :two => "2",
    :three => "3",
    :four => "4",
    :five => "5",
    :six => "6",
    :seven => "7",
    :eight => "8"
  }

  attr_accessor :tile_state, :neighbor_array, :has_bomb


  def initialize
    @neighbor_array = Array.new
  end

  def inspect
    "TILE with #{neighbor_array.size} neighbors"
  end


  #define neighbors for each tile
  def neighbors
    @neighbor_array.dup
  end

  def add_neighbor(tile)
    @neighbor_array << tile
  end

  def plant
    return nil if self.has_bomb
    @has_bomb = true
  end


  def neighbor_bomb_count
    neighbors.inject(0) {|bombs, tile| tile.has_bomb ? 1 : 0}
  end

  def show_tile
    return DISPLAYSET[:flagged] if @flagged
    return DISPLAYSET[:hidden] unless @revealed
    return DISPLAYSET[:zero] if neighbor_bomb_count == 0
    return neighbor_bomb_count.to_s
  end

  def reveal_tiles
    return true if @revealed
    return false if self.has_bomb
    @flagged = false
    @revealed = true
    neighbors.each{ |tile| tile.reveal_tiles} if self.neighbor_bomb_count == 0
    true
  end

end


class Player

  def display_board(board)
    puts "DISPLAY BOARD NOT IMPLEMENTED"
  end

  def get_move
    puts "GET MOVE NOT IMPLEMENTED"
    [0,0]
  end

end