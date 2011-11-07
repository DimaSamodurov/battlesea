require_relative 'utils'
require_relative 'board'

class Game
  include Utils
  
  attr_reader :board1, #computer
    :board2, #human
    :state, :col_size
  attr_accessor :turn
  
  CELL_STATES = [:empty, :ship, :wounded,  :killed]
  GAME_STATES = [:game, :over]
  
  def initialize(header = 'RESPUBLIKA', col_size = 10)
    @board1 = Board.new(header: header, col_size: col_size)
    @board2 = Board.new(header: header, col_size: col_size)
    @board3 = Board.new(header: header, col_size: col_size) # board to fire on

    @board1.setup_random_ships  # computer
    @board2.setup_random_ships # human

    @state = :start
    @turn = 0
  end

  def human_turn?
    @turn.even?
  end

  def pc_turn?
    @turn.odd?
  end

  def notify_human_turned(&block)
    @turn += 1
    do_pc_turn(&block)
  end

  def do_pc_turn
    while pc_turn? do
      cell = @board3.free_cells.sample
      return if cell.nil?
      hit = @board2.fire(cell)
      @board3[cell.first, cell.last] = hit
      if  hit == :miss
        @turn += 1
      end
      yield if block_given?
    end
  end

  def play
    #turn while board1.alive? && board2.alive?
  end

end