require_relative 'utils'
require 'matrix'
require 'active_support/core_ext/module/delegation'

Matrix.instance_eval do
public :[]=, :set_element, :set_component
end

RESPUBLIKA = %w(R E S P U B L I K A)

class Board
  
  include Utils
  attr_reader :m, :free_cells, :cells
  alias_method :matrix, :m
  delegate :row_size, :col_size, '[]', '[]=', :each_with_index, :to => :@m

  
  def initialize(row_size, col_size = row_size, initial_state = :empty)
    @m = Matrix.build(row_size, col_size) {initial_state}
    @cells = Array.new(row_size*col_size)
    @free_cells = Array.new(row_size*col_size)
    reset_free_cells
  end

  def reset(state = :empty)
    each_with_index {|e, row, col| m[row, col] = state}
    reset_free_cells
  end

  def reset_free_cells
    index = 0
    for row in 1..m.column_size
      for col in 1..m.row_size
        @free_cells[index] = "#{col}#{row}"
        index +=1
      end
    end
  end

  # Метод расставляет корабли случайным образом на поле
  def setup_random_ships
    reset

    ship_coords = [%w(R1 E1 S1 P1), %w(B1 L1 I1), %w(A1 A2 A3)]
    #ships = get_random_ships
    ship_coords.each{|coords| setup_ship(coords)}
  end

  # decode_rc('R1') = 0,0
  def decode_rc(coord)
    col = RESPUBLIKA.index(coord[0])
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

end

b = Board.new(10)
b.setup_random_ships
p b.m.to_s