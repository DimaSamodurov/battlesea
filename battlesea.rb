START = 30
ROW_NUM = 10

require 'game'


Shoes.app :width => 800, :height => 600 do
    
  STATE_COLORS = {    
    :empty => dodgerblue,
    :ship => gold,
    :wounded => magenta,
    :killed => red
  }
    
  @cell_size = self.height/ROW_NUM/2
  @field_size = @cell_size * ROW_NUM
  
  def render_board(start_x, start_y, board, history)
    #fill dodgerblue
    #rect start_x, start_y, @field_size, @field_size
    
    x = start_x ; y = start_y
    self.strokewidth(1)
    (board.size + 1).times do |i|
      para RESPUBLIKA[i].to_s, :left => x + 6, :top => y - 22, :font => '13px'
      line(x, y, x, board.size*@cell_size + start_y)
      x += @cell_size
    end
    
    x = start_x
    (board.size + 1).times do |i|
      para((i+1).to_s, :left => x -22, :top => y + 6, :font => '13px') if i < board.size 
      line(x, y, @cell_size*board.size+start_x, y)
      y += @cell_size
    end
    render_cells(start_x, start_y, board, history)
  end
  
  def render_cells(start_x, start_y, board, history)
    # fill cells with state colors 
    for row in 0...board.size
      for col in 0...board[row].size
        if board[row][col] != history[row][col]
          fill STATE_COLORS[board[row][col]]
          rect start_x + col*@cell_size, start_y + row*@cell_size, @cell_size, @cell_size
        end
      end
    end

  end
  
  def render_pane
    clear do
      background rgb(219, 169, 108, 0.8)
      stack :margin_top => 10 do
        #para("Ранено: #{0}", :top => 80, :left => 600)
        #para("Убито: #{0}", :top => 100, :left => 600)
        
        #line(590, 520, 790, 520)
        button("New game", :width => 100, :height => 30, :top => 410, :left => 70) do
          @game = Game.new
          render_pane
        end
        
        button("Random Ships", :width => 100, :height => 30, :top => 410, :left => 180) do
          @game.setup_random_ships(@game.board1, @game.history1)
          render_board(START, START, @game.board1, @game.history1)
        end        
      end
      
      render_board(START, START, @game.board1, @game.history1)
      render_board(START + self.width/2, START, @game.board2, @game.history2)
    end
  end
  
  $app = self
  
  @game = Game.new
  render_pane
  
  coord = para("", :top => 500, :left => 10)
  motion do |x,y|
    coord.text = "#{x}:#{y}"
  end
  
  click do |button, x, y|
    x = x - START
    y = y - START

    row = y/@cell_size
    col = x/@cell_size
    
    if x < 0 or y < 0  
      alert("Недолет! #{x}:#{y}")
    elsif x > @field_size or y > @field_size
      alert("Перелет! #{x}:#{y} ")
    else  
      if @game.state == :ship_setup
        @game.setup_ship_rc(row, col)
      elsif @game.state == :battle
        @game.fire(row, col)
      end
    end
    render_cells(START, START, @game.board1, @game.history1)
  end
  
end

