module Direction
  def self.up
    [ -1, 0 ]
  end

  def self.up_right
    [ -1, 1 ]
  end

  def self.right
    [ 0, 1 ]
  end

  def self.down_right
    [ 1, 1]
  end

  def self.down
    [ 1, 0 ]
  end

  def self.down_left
    [ 1, -1 ]
  end

  def self.left
    [ 0, -1 ]
  end

  def self.up_left
    [  -1, -1]
  end

  def self.to_rc(direction)
    case direction%8
      when 0 then  [ -1,  0 ] # up
      when 1 then  [ -1,  1 ] # up-right
      when 2 then  [  0,  1 ] # right
      when 3 then  [  1,  1 ] # down-right
      when 4 then  [  1,  0 ] # down
      when 5 then  [  1, -1 ] # down-left
      when 6 then  [  0, -1 ] # left
      when 7 then  [ -1, -1 ] # up-left
    end
  end

end