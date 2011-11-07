require_relative 'utils'
require_relative 'matrix'
require_relative 'ext'
require_relative 'direction'
require_relative 'delegation'

class Board
  include Utils
  attr_reader :m,           # board matrix
              :header,      # RESPUBLIKA
              :ship_set     # [4,3,2,2,2,1]
  alias_method :matrix, :m

  delegate :row_size, '[]', '[]=', :each_with_index, :to => :@m

  # Creates a board. Size is specified by parameters in order: sample array, header.
  def initialize(options = {}, &block)
    default_options = {
        header: "RESPUBLIKA",
        ship_set:  [4, 3, 3, 2, 2, 2, 1, 1, 1, 1]
    }
    options = default_options.merge(options)
    header = options[:header]
    sample = options[:sample]
    @header = header.is_a?(String) ? header.chars.to_a : header
    @header = @header.slice(0, sample.size) if sample
    row_size = @header.size
    col_size = options[:col_size] || @header.size
    @ship_set = options[:ship_set]
    @ships = []
    @m = Matrix.build(row_size, col_size) do |row, col|
      block_given? ?  yield(row, col).to_board : sample ?  sample[row][col].to_board : :empty
    end
  end

  def col_size
    @m.column_size
  end

  def to_s
    @m.to_s
  end

  # returns array of free cells available on the  board
  # tested
  def free_cells
    result = []
    @m.each_with_index do |c,row,col|
      next if c != :empty
      next if ship_around? row,col
      result << [row, col]
    end
    result
  end

  # tested. Returns true if there is a ship in or around a specified cell.
  def ship_around?(*coords)
    coords = coords.flatten
    row, col = coords.first, coords.last
    return true if @m[row, col] == :ship
    8.times do |i| # look around the cell
      d = Direction.to_rc(i)
      coord = [row + d.first, col + d.last]
      next if coord.first < 0 || coord.last < 0
      return true if [:ship, :killed].include? @m[coord.first, coord.last]
    end
    false
  end

  def reset(state = :empty)
    @m.each_with_index {|e, row, col| m[row, col] = state}
    @ships = []
  end

  # decode_rc('R1') = 0,0
  def decode_rc(coord)
    col = @header.index(coord[0])
    row = coord[1].to_i - 1
    return row,col
  end

  # setup_ship([nil, nil, nil], [2,1], Direction.down) # set up 3 palub ship starting from R2C1 down.
  # tested
  def setup_ship(ship, cell, direction)
    ship.size.times do |i|
      @m[cell.first, cell.last] = :ship
      ship[i] = cell
      cell = cell.go direction
    end
    @ships << ship
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

  def setup_random_ships
    ships = @ship_set.shuffle.map{|size| Array.new(size)}

    for ship in ships do

      cells = free_cells.shuffle
      directions = []
      while cells.any?
        cell = cells.pop
        directions = where_can_place?(ship.size, cell)
        break if directions.any?
      end

      raise "Can't set up ship #{ship.to_s}. No free cells left. Try to reduce ship number or size, or increase size of the board." unless directions.any?
      setup_ship(ship, cell, directions.sample)
    end

    ships
  end

  # вычеркнуть из списка свободных клеточек координаты корабля и смежные
  def strike_off_ship_cells_and_neighbours(ship)
    free_cells -= get_cells(ship) + get_neighbour_cells(ship)
  end

  # Пытается установить корабль в заданную клеточку поля во всех направлениях и возвращает массив возможных "направлений"
  # tested
  def where_can_place?(ship_size, cell)
    result = []
    [Direction.up, Direction.left, Direction.down, Direction.right].shuffle.each do |direction|
      result << direction if can_place?(ship_size, cell, direction)
    end
    result
  end

  def onboard?(*coord)
    coord = coord.flatten
    r,c = coord.first, coord.last
    r >= 0 && c >= 0  && r < col_size && c < row_size
  end

  def out_of_board?(*coord)
    !onboard?(*coord)
  end

  # tested. can_place(4, [1,1], Direction.left)
  def can_place?(ship_size, cell, direction)
    ship_size.times do
      return false if out_of_board?(cell) || ship_around?(cell)
      cell = cell.go direction
    end
    return true
  end

  # returns array of ship coords or nil if there is no ship in the cell
  def ship_at(*cell)
    cell = cell.flatten
    return nil if @m.at(cell) == :empty
    ship = [cell]
    [Direction.up, Direction.right, Direction.down, Direction.left].each do |direction|
      coord = cell.go direction
      while onboard?(coord) && [:ship, :wounded, :killed].include?(@m.at(coord))
        ship << coord
        coord = coord.go direction
      end
    end
    ship
  end

  def fire(*cell)
    cell = cell.flatten
    v = @m.at cell
    r = case v
          when :empty then :miss
          when :ship then :wounded
          else raise "don't hit other cells"
        end

    @m[cell.first, cell.last] = r
    ship = ship_at cell
    if ship.all? {|coord| @m.at(coord) == :wounded}
      ship.each{|coord| @m[coord.first, coord.last] = :killed}
    end
    @m.at cell
  end

  def alive?
    @m.each_with_index do |c,row,col|
      return true if c == :ship
    end
    false
  end

  def count(value)
    result = 0
    @m.each_with_index do |c,row,col|
      result += 1 if c == value
    end
    result
  end

  def wounded_count
    count :wounded
  end

  def killed_count
    count :killed
  end

  private

  # tested
  def cell_to_rc(cell)
    [@header.index(cell[0].upcase), cell[1..-1].to_i - 1]
  end
end
