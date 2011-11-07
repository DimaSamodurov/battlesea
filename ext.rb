require_relative 'utils'
require 'matrix'

CELL_STATE = {
  0 => :empty,
  1 => :ship,
  2 => :wounded,
  3 => :killed,
  4 => :miss
}

Matrix.instance_eval do
  public :[]=
end

Matrix.class_eval do
  def at(cell)
    self[cell.first, cell.last]
  end
end

Integer.class_eval do
  def to_board
    CELL_STATE[self]
  end
end

NilClass.class_eval do
  def to_board
    self
  end
end

Symbol.class_eval do
  def to_board
    self
  end
end

Array.class_eval do
  def go(*direction)
    direction = direction.flatten
    [first + direction.first, last + direction.last]
  end
end