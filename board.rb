require_relative 'utils'
require 'matrix'
require_relative 'ext'
require_relative 'direction'
require 'active_support/core_ext/module/delegation'

class Board
  include Utils
  attr_reader :m,           # board matrix
              :free_cells,  # array of free cells ['R1', 'R2'] or [[0, 0], [0, 1]]]]
              :cells,       # array of cells ['R1', 'R2'] for quick turnaround
              :header,      # RESPUBLIKA
              :ship_set     # [4,3,2,2,2,1]
  alias_method :matrix, :m

  delegate :row_size, :col_size, '[]', '[]=', :each_with_index, :to => :@m

  # Creates a board. Size is specified by parameters in order: sample array, header.
  def initialize(options = {}, &block)
    default_options = {
        header: "RESPUBLIKA",
        ship_set:  [4, 3, 3, 2, 2, 2, 1]
    }
    options = default_options.merge(options)
    header = options[:header]
    sample = options[:sample]
    @header = header.is_a?(String) ? header.chars.to_a : header
    @header = @header.slice(0, sample.size) if sample
    row_size = @header.size
    col_size = options[:col_size] || @header.size
    @ship_set = options[:ship_set]
    @m = Matrix.build(row_size, col_size) do |row, col|
      block_given? ?  yield(row, col).to_board : sample ?  sample[row][col].to_board : :empty
    end
  end

  def all_cells
    header.product((1..col_size).to_a).map(&:join)
  end

  def to_s
    @m.to_s
  end

  # TODO
  def get_free_cells
    result = []
    @m.each_with_index do |c,row,col|
      next if c == :ship
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
      return true if @m[coord.first, coord.last] == :ship
    end
    false
  end

  def reset(state = :empty)
    each_with_index {|e, row, col| m[row, col] = state}
  end

  # Метод расставляет корабли случайным образом на поле
  def setup_random_ships
    reset
    #ships = [%w(R1 E1 S1 P1), %w(B1 L1 I1), %w(A1 A2 A3)]
    ships = get_random_ships
    ships.each{|coords| setup_ship(coords)}
  end

  # decode_rc('R1') = 0,0
  def decode_rc(coord)
    col = @header.index(coord[0])
    row = coord[1].to_i - 1
    return row,col
  end

  def setup_ship(coords)
    coords.each do |coord|
      row, col = decode_rc(coord)
      setup_ship_rc(row, col)
    end
  end

  def setup_ship_rc(row, col)
    if m[row, col] == :empty
      m[row,col] = :ship
    else
      m[row, col] = :empty
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

    ships = @ship_set.shuffle.map{|size| Array.new(size)}


    for ship in ships do
      free_cells = get_free_cells.shuffle
      cell = free_cells.sample
      if cell.nil?
        raise "Can't set up ships. Try to reduce ship number or size, or increase size of the board."
      end

      #if setup_random_ship(cell, ship) == true
      #  strike_off_ship_cells_and_neighbours(ship)
      #  break
      #else
      #  @free_cells.delete(cell)
      #end
    end

    ships
  end

  # вычеркнуть из списка свободных клеточек координаты корабля и смежные
  def strike_off_ship_cells_and_neighbours(ship)
    free_cells -= get_cells(ship) + get_neighbour_cells(ship)
  end

  #TODO
  # Пытается установить корабль в заданную клеточку поля во всех направлениях и возвращает "направление" или "nil"
  def where_can_place?(ship_size, cell)
    result = []
    [Direction.up, Direction.left, Direction.down, Direction.right].shuffle.each do |direction|
      result << direction if can_place?(ship_size, cell, direction)
    end
    result.empty? ? nil : result
  end

  # tested
  def out_of_board?(*coord)
    coord = coord.flatten
    r,c = coord.first, coord.last
    r < 0 || c < 0  || r >= @m.column_size || c >= @m.row_size
  end

  # tested. can_place(4, [1,1], Direction.left)
  def can_place?(ship_size, cell, direction)
    ship_size.times do
      return false if out_of_board?(cell) || ship_around?(cell)
      cell = cell.go direction
    end
    return true
  end

  private


  # tested
  def cell_to_rc(cell)
    [@header.index(cell[0].upcase), cell[1..-1].to_i - 1]
  end
end

#b = Board.new()
#b.setup_random_ships
#p b.m.to_s