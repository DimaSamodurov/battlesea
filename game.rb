require_relative 'utils'
require_relative 'board'

class Game
  include Utils
  
  attr_reader :board1, :board2, :history1, :history2, :state, :col_size
  
  CELL_STATES = [:empty, :ship, :wounded,  :killed]
  GAME_STATES = [:ship_setup, :battle]
  
  def initialize(header, col_size)
    @board1 = Board.new(header, col_size)
    @board2 = Board.new(header, col_size)

    @state = :ship_setup
  end
  

  def fire(row, col)
    
  end
  
end

#game = Game.new
#game.board1.setup_random_ships
#puts game.inspect