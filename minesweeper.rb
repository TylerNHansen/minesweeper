require 'debugger'
require 'yaml'

class MineSweeper

  def initialize(num_bombs = 4, filename = 'save.yaml')
    @player = Player.new
    if filename
      yaml_obj = nil
      File.open(filename, "r") do |f|
        yaml_obj = f.gets(nil)
        p yaml_obj.size
      end
      @board = YAML::load( yaml_obj )
    else
      @board = Board.new(filename) unless filename
      @board.plant_bombs(num_bombs)
    end
  end


  def run

    until @board.gameover?
      play_turn
    end

    display_result

  end

  def play_turn
    @player.display_board(@board)
    option, pos = @player.get_move
    if option == "s"
      self.save
      abort("GAME SAVED")
    elsif option == "p"
      @board.make_guess(*pos)
    elsif option == "f"
       @board.toggle_flag(*pos)
    else
       play_turn
    end
    nil
  end

  def display_result
    @board.render
    puts @board.gameover?
  end

  def save(filename = 'save.yaml')
    File.open(filename, "w") do |f|
      f.puts YAML::dump(@board)
    end
  end


end

class Board
  ROWCOUNT = 14
  COLCOUNT = 14

  def initialize
    unless filename
      @minefield = Array.new(ROWCOUNT) { Array.new(COLCOUNT) {Tile.new} }
      self.connect_neighbors
      @num_bombs = 0
      return nil
    end

    yaml_obj = nil
    File.open(filename, "r") do |f|
      yaml_obj = f.gets
    end



  end

  def gameover?
    counter = 0
    self.each_tile_with_index do |tile|
      return "lose" if tile.revealed_bomb?
      counter += 1 unless tile.revealed?
    end

    return "win" if counter == @num_bombs
    false
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
    i.between?(0, ROWCOUNT - 1) && j.between?(0, COLCOUNT - 1)
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
    @num_bombs = bombcount
    @minefield.flatten.sample(bombcount).each(&:plant)
    self
  end

  def render
    render_arr = []

    self.each_tile_with_index { |tile| render_arr << tile.show_tile.dup }

    padding = "0123456789" * 8

    puts " #{padding[0...COLCOUNT]}"

    ROWCOUNT.times do |i|
      puts "#{(i%10)}#{render_arr.shift(COLCOUNT).join("")}#{(i%10)}"
    end

    puts " #{padding[0...COLCOUNT]}"
    nil
  end

  def make_guess(i, j)
    @minefield[i][j].reveal_tiles
    nil
  end

  def toggle_flag(i, j)
    @minefield[i][j].toggle_flag
  end
  #
  # def disp_tile(tile)
  #   #test method please ignore
  #   return "X" unless tile.has_bomb
  #   "_"
  # end

end

class Tile

  DISPLAYSET = {
    :hidden => "*",
    :flagged => "F",
    :zero => "_",
    :bomb => "!"
  }

  attr_accessor :neighbor_array, :has_bomb


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
    neighbors.select(&:has_bomb).count
    # neighbors.inject(0) {|bombs, tile| bombs + (tile.has_bomb ? 1 : 0)}
  end

  def show_tile
    return DISPLAYSET[:flagged] if @flagged
    return DISPLAYSET[:hidden] unless @revealed
    return DISPLAYSET[:bomb] if self.has_bomb
    return DISPLAYSET[:zero] if neighbor_bomb_count == 0
    return neighbor_bomb_count.to_s
  end

  def revealed_bomb?
    self.show_tile == DISPLAYSET[:bomb]
  end

  def revealed?
    #revealed if it's :hidden or :flagged
    chr = self.show_tile
    (chr != DISPLAYSET[:hidden]) && (chr != DISPLAYSET[:flagged])
  end

  def reveal_tiles
    return true if @revealed
    @flagged = false
    @revealed = true
    neighbors.each{ |tile| tile.reveal_tiles} if self.neighbor_bomb_count == 0
    nil
  end

  def toggle_flag
    @flagged =  !@flagged
  end

end


class Player

  def display_board(board)
    board.render
  end

  def get_move
    puts "p3,2 places at row 3 col 2. f1,0 flags at row 1 col 0. S to save"
    move = gets.chomp
    option = move.chr
    move = move[1...move.size]
    return ["s", 0, 0] if option == "s"
    [option, move.split(",").map(&:to_i)]
  end

end

m = MineSweeper.new
m.run