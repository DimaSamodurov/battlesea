require 'test/unit'
require_relative '../board'

class TestDirection < MiniTest::Unit::TestCase
  def test_direction_to_rc
    assert_equal(Direction.up,    Direction.to_rc(0))
    assert_equal(Direction.up_right,   Direction.to_rc(1))
    assert_equal(Direction.right, Direction.to_rc(2))
    assert_equal(Direction.down_right, Direction.to_rc(3))
    assert_equal(Direction.down,  Direction.to_rc(4))
    assert_equal(Direction.down_left,  Direction.to_rc(5))
    assert_equal(Direction.left,  Direction.to_rc(6))
    assert_equal(Direction.up_left,    Direction.to_rc(7))
  end
end