START = 20

module MyFuncs
  def array_deep_copy(from_array) 
    to_array = Array.new
    from_array.each { |ary| to_array += [ary.dup] }
    return to_array
  end

  def array_mul(ary1, ary2)
    ret_ary = []
    ary1.each do |i|
      ary2.each do |i2|
        ret_ary = ret_ary.push([i, i2])
      end
    end
    return ret_ary
  end
end


class Game

  include MyFuncs

  attr_reader :game_over, :current_player, :conflicted, :owning_player
  
  def initialize(size, square_size, app)
    @app = app
    @size = size
    @square_size = square_size
    @board = []
    @captures = { :black => 0, :white => 0 }
    @points = { :black => 0, :white => 0 }
    @last_passed = false
    @game_over = false
    for i in 0...@size
      a = []
      for j in 0...@size
        a[j] = 0
      end
      @board[i] = a
    end
    @current_player = "black"
    @history = [{ :board => [], :white_captures => 0, :black_captures => 0 }] #for checking for illegal ko moves and undoing, this will hold hashes of board positions and scores
    @move_count = 1
    @test_board = array_deep_copy(@board) #for various tests
    @owning_player = 0 #for territory counting at end game
    @conflicted = false #ditto
  end
  
  
  def illegal_move?(x, y)
    if (occupied?(x, y) || suicide?(x, y) || ko?(x, y))
      return true
    else 
      return false
    end
  end
  
  def occupied?(x, y)
    if(@board[x][y] != 0)
      return true
    else
      return false
    end
  end
  
  def off_board?(x, y)
    return (x >= @size || x < 0 || y >= @size || y < 0)
  end
  
  def play_to_board(x, y)
    play_at_loc(x, y)
    [[-1,0],[0,-1],[1,0],[0,1]].each do |offset|
      x_offset = offset[0]
      y_offset = offset[1]
      if(dead?(x+x_offset, y+y_offset, @current_player))
        kill(x+x_offset, y+y_offset)
      end
    end
  end
  
  
  def draw_x(x, y)
    size = @square_size
    @app.stroke rgb(255,0,0,0.9)
    @app.line(START+x*size-size/2-1, START+y*size-size/2-1, START+x*size+size/2-1, START+y*size+size/2-1)
    @app.line(START+x*size-size/2-1, START+y*size+size/2-1, START+x*size+size/2-1, START+y*size-size/2-1)
    @app.stroke "#000000"
  end
  
end


Shoes.app :width => 800, :height => 600 do
    
  @field_size = 10 #default
  @square_size = self.height/@field_size/2
  
  extend MyFuncs
  
  def render_field(start_x, start_y)
    x = start_x ; y = start_y
    self.strokewidth(1)
    @field_size.times do 
      line(x, y, x, (@field_size-1)*@square_size + start_y)
      x += @square_size
    end
    x = start_x
    @field_size.times do
      line(x, y, @square_size*(@field_size-1)+start_x, y)
      y += @square_size
    end   
  end
  
  def render_pane
    clear do
      background rgb(219, 169, 108, 0.8)
      stack :margin_top => 10 do
        #para("Ранено: #{0}", :top => 80, :left => 600)
        #para("Убито: #{0}", :top => 100, :left => 600)
        
        #line(590, 520, 790, 520)
        button("Новая игра:", :width => 100, :height => 30, :top => 540, :right => 100) do
          @game = Game.new(@field_size, @square_size, self)
          render_pane
        end
      end
      
      render_field(START, START)
      render_field(START + self.width/2, START)
#      @game.draw()
    end
  end
  
  $app = self
  
  @game = Game.new(@field_size, @square_size, self)
  render_pane
  click do |button, x, y|
    if(x < @square_size*@field_size && y < @square_size*@field_size)
      x_coord = x/@square_size
      y_coord = y/@square_size
    end
  end
end