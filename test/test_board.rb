require 'test/unit'
require_relative '../board'

class TestBoard < MiniTest::Unit::TestCase
  def setup
    #@board = Board.new
  end

  def teardown
    ## Nothing really
  end

  def test_initialize_default
    assert_equal "Matrix[[empty, empty, empty], [empty, empty, empty], [empty, empty, empty]]", Board.new(:header => 'RES').to_s
  end

  def test_initialize_with_sample
    b = Board.new(:sample =>
                      [[0, 0, 3],
                       [2, 0, 0],
                       [1, 0, 1]]
    )
    assert_equal "Matrix[[empty, empty, killed], [wounded, empty, empty], [ship, empty, ship]]", b.to_s
  end

  def test_initialize_with_block
    sample =
        [[0, 0, 3],
         [2, 0, 0],
         [1, 0, 1]]

    b = Board.new(:header => 'RES') do |row, col|
      sample[row][col]
    end
    assert_equal "Matrix[[empty, empty, killed], [wounded, empty, empty], [ship, empty, ship]]", b.to_s
  end

  def test_ship_around?
    b = Board.new(:sample => [[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    b.each_with_index { |c, row, col| assert !b.ship_around?(row, col), "Found ship around #{row},#{col}, but should not." }

    b = Board.new(:sample => [[0, 0, 0], [0, 1, 0], [0, 0, 0]])
    b.each_with_index { |c, row, col| assert b.ship_around?(row, col), "Not found ship around #{row},#{col}, but should be." }

    b = Board.new(:sample =>
                      [[0, 0, 0],
                       [1, 0, 0],
                       [0, 0, 1]]
    )
    b.each_with_index do |c, row, col|
      if [0, 2] == [row, col]
        assert !b.ship_around?(row, col), "Found ship around #{row},#{col}, but should not."
      else
        assert b.ship_around?(row, col), "Not found ship around #{row},#{col}, but should be."
      end
    end
  end

  def test_can_place
    def ok(test)
      assert test,  "Can not place a ship, but should be able to."
    end

    def nok(test)
      assert !test,  "Can place a ship, but should not be able to."
    end

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

  def test_try_setup_ship
    def ok(test)
      assert test,  "Can not set up a ship, but should be able to."
    end

    def nok(test)
      assert !test,  "Can set up a ship, but should not be able to."
    end

    b = Board.new(:sample =>
                      [[0, 0, 0, 0],
                       [1, 0, 0, 0],
                       [1, 0, 0, 0],
                       [0, 0, 1, 0]])

    ok  b.try_setup_ship(3, [0,0])
    ok  b.try_setup_ship(3, [0,1])
    ok  b.try_setup_ship(3, [0,2])
    nok b.try_setup_ship(3, [1,2])
    ok  b.try_setup_ship(3, [1,2])
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