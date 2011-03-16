START = 30
ROW_NUM = 10
RESPUBLICA = %w(R E S P U B L I K A)

class Game

  SHIPS_SET = [4, 3, 3, 2, 2, 2, 1]
  
  attr_reader :board1, :board2, :history1, :history2, :state
  
  CELL_STATES = [:clean, :ship, :wounded,  :killed]
  GAME_STATES = [:ship_setup, :battle]
  
  def initialize
    @board1 = Array.new(ROW_NUM, [])
    for i in 0... @board1.size
      @board1[i] = Array.new(ROW_NUM, :clean)
    end
    @board2 = Array.new(ROW_NUM, [])
    for i in 0... @board2.size
      @board2[i] = Array.new(ROW_NUM, :clean)
    end
    
    @history1 = Array.new(ROW_NUM, [])
    for i in 0... @history1.size
      @history1[i] = Array.new(ROW_NUM, nil)
    end
    @history2 = Array.new(ROW_NUM, [])
    for i in 0... @history2.size
      @history2[i] = Array.new(ROW_NUM, nil)
    end
    
    @state = :ship_setup
  end
  
  def setup_ship_rc(row, col)
    #@history1 = copy_array(@board1)
    if @board1[row][col] == :clean
      @board1[row][col] = :ship
    else
      @board1[row][col] = :clean
    end
  end

  def setup_ship(coords)
    coords.each do |coord|
      col = RESPUBLICA.index(coord[0..0])
      row = coord[1..1].to_i - 1
      
      setup_ship_rc(row, col)
    end
  end

  def reset_array(board, value)
    for i in 0...board.size
      for j in 0...board[i].size
        board[i][j] = value
      end
    end
  end
  
  def reset_free_cells
    @free_cells ||= Array.new(ROW_NUM*RESPUBLICA.size)
    index = 0
    for row in 1..ROW_NUM
      for col in RESPUBLICA
        @free_cells[index] = "#{col}#{row}"
        index +=1
      end
    end
  end
  
  def get_random_cell(cells)
    if cells.empty?
      nil
    else
      cells[rand(cells.size)]
    end  
  end
  
  # Метод расставляет корабли случайным образом на поле
  def setup_random_ships(board, history)
    reset_array(board, :clean)
    reset_array(history, nil)
    reset_free_cells
    
    #ships = [%w(R1 E1 S1 P1), %w(B1 L1 I1), %w(A1 A2 A3)]
    ships = get_random_ships
    ships.each{|ship| setup_ship(ship)}
  end
  
  # Метод создает массив кораблей расставленых случайным образом и возвращает в качестве результата.
  # Алгоритм:
  # - перечисляя все свободные корабли
  #   - взять следующий корабль
  #   - найти случайную пустую клеточку поля
  #     - если найдена, попытаться установить корабль в эту клеточку 
  #       - если попытка удалась - вычеркнуть из списка свободных клеточек координаты корабля и смежные, перейти к следующему кораблю.
  #       - если попытка не удалась, вычеркнуть клеточку из свободных для данного корабля, взять следующую случайную свободную клеточку и попытаться установить туда.
  #     - если свободные клеточки закончились - завершить установку отказом (такое возможно в теории, если поле слишком маленькое а кораблей слишком много)  
  # 
  # детали:
  # попытаться установить в клеточку значит:
  #  - выбрать случайное направление (0 направо, 1 вниз, 2 налево, 3 вверх)
  #  - попытаться установить в данном направлении
  #  - если попытка неуспешна - попытаться установить в следующем направлении по часовой стрелке.
  #  - если не удалось установить ни в одном из четырех направлений - считать попытку неуспешной.
      
  def get_random_ships
 
    ships = Array.new(SHIPS_SET.size)
    for i in 0...ships.size do
      ships[i] = Array.new(SHIPS_SET[i])
    end
    
    for ship in ships do 
      
      cell = get_random_cell(@free_cells)
      while cell != nil
        if setup_random_ship(ship) == true
          strike_off_ship_cells_and_neighbours(ship)
          break
        else
          @free_cells.delete(cell)
        end
      end

    end
    
    ships
  end
  
  # вычеркнуть из списка свободных клеточек координаты корабля и смежные
  def strike_off_ship_cells_and_neighbours(ship)
    TODO
    @free_cells -= get_cells(ship) + get_neighbour_cells(ship)
  end
  
  # Пытается установить корабль в случайную клеточку поля и возвращает "успешно" или "неуспешно"
  def setup_random_ship(ship)
    coord = get_random_free_cell
    v = get_random_vector
    success = false
    for i in 0..3
      if try_setup_ship(ship, coord, (vector+i)%4 )
        success = true
        break
      end
    end
    return false if !success

    result = try_setup_ship(ship, coord, vector)
    if result == false
      v += 1
    end
  end
  
  def fire(row, col)
    
  end
  
  private
  
  def copy_array(source)
    result = source.dup
    for i in 0...source.size
      if source[i].is_a? Array
        result[i] = []
        for j in 0...source[i].size
          result[i][j] = source[i][j]
        end
      else
        result[i] = source[i].dup
      end
    end
    result
  end
  
end


Shoes.app :width => 800, :height => 600 do
    
  STATE_COLORS = {    
    :clean => dodgerblue,
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
    (ROW_NUM + 1).times do |i|
      para RESPUBLICA[i].to_s, :left => x + 6, :top => y - 22, :font => '13px'
      line(x, y, x, ROW_NUM*@cell_size + start_y)
      x += @cell_size
    end
    
    x = start_x
    (ROW_NUM + 1).times do |i|
      para((i+1).to_s, :left => x -22, :top => y + 6, :font => '13px') if i < ROW_NUM 
      line(x, y, @cell_size*ROW_NUM+start_x, y)
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

