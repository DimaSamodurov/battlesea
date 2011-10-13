require_relative 'utils'
require_relative 'board'

class Game
  include Utils
  
  SHIPS_SET = [4, 3, 3, 2, 2, 2, 1]
  
  attr_reader :board1, :board2, :history1, :history2, :state, :col_size
  
  CELL_STATES = [:empty, :ship, :wounded,  :killed]
  GAME_STATES = [:ship_setup, :battle]
  
  def initialize(rows = 10)
    @col_size = rows
    @board1 = Board.new(col_size, row_size)
    @board2 = Board.new(col_size, row_size)

    @state = :ship_setup
  end
  
  def get_random_cell(cells)
    if cells.empty?
      nil
    else
      cells[rand(cells.size)]
    end  
  end
  
  def get_random_vector
    rand(4)
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
    #TODO
    @free_cells -= get_cells(ship) + get_neighbour_cells(ship)
  end
  
  # Пытается установить корабль в случайную клеточку поля и возвращает "успешно" или "неуспешно"
  def setup_random_ship(ship)
    coord = get_random_cell(@free_cells)
    v = get_random_vector
    success = false
    for i in 0..3
      if try_setup_ship(ship, coord, (v+i)%4 )
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
  
  def try_setup_ship(ship, coord, vector)
    
  end
  
  def fire(row, col)
    
  end
  
end

game = Game.new
game.board1.setup_random_ships
puts game.inspect