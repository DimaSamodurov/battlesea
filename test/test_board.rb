require_relative 'test_helper'
require 'board'

describe Board do

  it "should initialize with default values" do
    assert_equal "Matrix[[empty, empty, empty], [empty, empty, empty], [empty, empty, empty]]", Board.new(:header => 'RES').to_s
  end

  it "should initialize with sample values" do
    b = Board.new(:sample =>
                      [[0, 0, 3],
                       [2, 0, 0],
                       [1, 0, 1]]
    )
    assert_equal "Matrix[[empty, empty, killed], [wounded, empty, empty], [ship, empty, ship]]", b.to_s
  end

  it "should initialize with block" do
    sample =
        [[0, 0, 3],
         [2, 0, 0],
         [1, 0, 1]]

    b = Board.new(:header => 'RES') do |row, col|
      sample[row][col]
    end
    assert_equal "Matrix[[empty, empty, killed], [wounded, empty, empty], [ship, empty, ship]]", b.to_s
  end

  describe "free_cells" do
    before do
      @b =  Board.new(:sample =>
                      [[0, 0, 0],
                       [1, 0, 0],
                       [1, 0, 2]])
    end

    it "should return array of free cells" do
      @b.free_cells.must_equal [[0,2]]
      @b[1,0]= 0
      @b.free_cells.sort.must_equal [[0,0], [0,1], [0,2]]
    end
  end

  describe "ship_around" do
    it "should detect ship around a cell" do
      b = Board.new(:sample => [[0, 0, 0], [0, 0, 0], [0, 0, 0]])
      b.each_with_index { |c, row, col| assert !b.ship_around?(row, col), "Found ship around #{row},#{col}, but should not." }

      b = Board.new(:sample => [[0, 0, 0], [0, 1, 0], [0, 0, 0]])
      b.each_with_index { |c, row, col| assert b.ship_around?(row, col), "Not found ship around #{row},#{col}, but should be." }

      b = Board.new(:sample =>
                        [[0, 0, 0],
                         [1, 0, 0],
                         [0, 0, 2]]
      )
      b.each_with_index do |c, row, col|
        if [0, 2] == [row, col]
          assert !b.ship_around?(row, col), "Found ship around #{row},#{col}, but should not."
        else
          assert b.ship_around?(row, col), "Not found ship around #{row},#{col}, but should be."
        end
      end
    end
  end

  describe "can_place" do
    def ok(test)
      assert test,  "Can not place a ship, but should be able to."
    end

    def nok(test)
      assert !test,  "Can place a ship, but should not be able to."
    end

    it "should answer whether ship can be placed in the specified cell with the specified direction" do
      b = Board.new(:sample =>
                        [[0, 0, 0, 0],
                         [0, 0, 0, 0],
                         [1, 0, 0, 0],
                         [0, 0, 1, 0]])

      ok  b.can_place?(3, [0, 0], Direction.right)
      ok  b.can_place?(3, [0, 1], Direction.right)
      nok b.can_place?(3, [0, 2], Direction.right)
      nok b.can_place?(3, [0, 0], Direction.down)
      nok b.can_place?(3, [0, 4], Direction.down)
      nok b.can_place?(3, [2, 3], Direction.up)
      ok  b.can_place?(2, [1, 3], Direction.up)
      nok b.can_place?(2, [0, 0], Direction.down)
      ok  b.can_place?(1, [0, 0], Direction.down)
      ok  b.can_place?(2, [1, 2], Direction.up)
    end
  end

  describe "where_can_place?" do
    def ok(test)
      assert test,  "Can not set up a ship, but should be able to."
    end

    def nok(test)
      assert !test,  "Can set up a ship, but should not be able to."
    end

    it "tries to place ship in the specified cell with any direction" do
      b = Board.new(:sample =>
                        [[0, 0, 0, 0],
                         [1, 0, 0, 0],
                         [1, 0, 0, 0],
                         [0, 0, 1, 0]])

      b.where_can_place?(3, [0,0]).must_equal []
      b.where_can_place?(3, [0,1]).must_equal []
      b.where_can_place?(3, [0,2]).must_equal []
      b.where_can_place?(2, [0,2]).sort.must_equal [Direction.right, Direction.down].sort
    end
  end

  describe "setup_ship" do
    it "should pupulate ship array with cells" do
      board = Board.new
      ship = [nil, nil, nil]
      board.setup_ship(ship, [2,1], Direction.down)
      ship.must_equal [[2,1], [3,1], [4,1]]

      board.setup_ship(ship, [2,1], Direction.right)
      ship.must_equal [[2,1], [2,2], [2,3]]
    end
  end

  describe "ship_at(cell)" do
    it "should return ship" do
      b = Board.new(:sample =>
                        [[1, 0, 2, 0],
                         [1, 0, 2, 0],
                         [0, 0, 0, 0],
                         [0, 3, 3, 3]]
      )
      b.ship_at([0,0]).sort.must_equal [[0,0],[1,0]].sort
      b.ship_at([1,0]).sort.must_equal [[0,0],[1,0]].sort

      b.ship_at([0,1]).must_equal nil

      b.ship_at([0,2]).sort.must_equal [[0,2], [1,2]].sort
      b.ship_at([1,2]).sort.must_equal [[0,2], [1,2]].sort

      b.ship_at([3,2]).sort.must_equal [[3,1],[3,2],[3,3]].sort
    end
  end

  describe "alive?" do
    it "should return true if at least one cell on the board is :ship" do
      Board.new(sample: [[0,0], [0,0]]).alive?.must_equal false
      Board.new(sample: [[2,2], [2,1]]).alive?.must_equal true
      Board.new(sample: [[2,3], [3,0]]).alive?.must_equal false
    end
  end

  def test_cell_to_rc
    board = Board.new
    assert_equal([0, 0], board.send(:cell_to_rc, 'R1'))
    assert_equal([0, 1], board.send(:cell_to_rc, 'R2'))
    assert_equal([1, 0], board.send(:cell_to_rc, 'E1'))
    assert_equal([1, 1], board.send(:cell_to_rc, 'E2'))
    assert_equal([9, 9], board.send(:cell_to_rc, 'A10'))
  end

end