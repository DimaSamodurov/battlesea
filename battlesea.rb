START = 30
ROW_NUM = 10

require 'game'

Shoes.app :width => 800, :height => 600 do
    
  STATE_COLORS = {    
    :empty => dodgerblue,
    :ship => gold,
    :wounded => magenta,
    :killed => red,
    :miss => gray,
    nil => white
  }
    
  @cell_size = self.height/ROW_NUM/2
  @field_size = @cell_size * ROW_NUM
  
  def render_board(start_x, start_y, board, show_ships)
    x = start_x ; y = start_y
    self.strokewidth(1)
    (board.row_size + 1).times do |i|
      para board.header[i], :left => x + 6, :top => y - 22, :font => '13px'
      line(x, y, x, board.row_size*@cell_size + start_y)
      x += @cell_size
    end
    
    x = start_x
    (board.col_size + 1).times do |i|
      para((i+1).to_s, :left => x -22, :top => y + 6, :font => '13px') if i < board.row_size
      line(x, y, @cell_size*board.col_size+start_x, y)
      y += @cell_size
    end
    render_cells(start_x, start_y, board, show_ships)

    stack do
      para("Ранено: #{board.count :wounded}", :top => start_y + (board.col_size+1)*@cell_size, :left => start_x, :font => '13px')
      para("Убито: #{board.count :killed}", :top => start_y + (board.col_size+2)*@cell_size, :left => start_x, :font => '13px')
    end
  end
  
  def render_cells(start_x, start_y, board, show_ships)
    # fill cells with state colors 
    for row in 0...board.col_size
      for col in 0...board.row_size
        if board[row, col] == :ship and not show_ships
          fill STATE_COLORS[:empty]
        else
          fill STATE_COLORS[board[row, col]]
        end

        rect start_x + col*@cell_size, start_y + row*@cell_size, @cell_size, @cell_size
      end
    end

  end
  
  def render_pane
    clear do
      background rgb(219, 169, 108, 0.8)
      stack :margin_top => 10 do

        button("New game", :width => 100, :height => 30, :top => 410, :left => 70) do
          @game = Game.new
          render_pane
        end
      end

      render_boards
    end
  end

  def render_boards
    render_board(START, START, @game.board1, false)
    render_board(START + L2, START, @game.board2, true)
  end

  $app = self
  L2 = self.width/2
  
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
      if @game.human_turn?
        if @game.board1[row, col] != :miss
          @game.board1.fire(row, col)
          if @game.board1[row, col] == :miss
            @game.notify_human_turned
          end
          render_pane
          alert('Поздравляем, Вы выиграли!') if not @game.board1.alive?
          alert('Вы проиграли!') if not @game.board2.alive?
        end
      else
        alert("Не ваш ход!")
      end
    end
  end
  
end