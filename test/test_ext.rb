require 'test/unit'
require_relative '../board'

class TestExt < MiniTest::Unit::TestCase

  def test_int_to_board
    assert_equal :empty, 0.to_board
    assert_equal :ship, 1.to_board
    assert_equal :wounded, 2.to_board
    assert_equal :killed, 3.to_board
  end

  def test_nil_to_board
    assert_equal nil, nil.to_board
  end

  def test_symbol_to_board
    assert_equal :empty, :empty.to_board
  end

  def test_array_go
    assert_equal [1,2],  [0,1].go([1,1])
    assert_equal [2,2],  [0,1].go(2,1)
    assert_equal [-1,0], [0,1].go(-1,-1)
  end
end