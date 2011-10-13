module Utils
  def copy_array(source)
    result = source.dup
    for i in 0...source.size
      if source[i].is_a? Array
        result[i] = []
        for j in 0...source[i].size
          result[i][j] = source[i][j]
        end
      else
        result[i] = source[i].dup
      end
    end
    result
  end

  def reset_array(array, value)
    for i in 0...array.size
      for j in 0...array[i].size
        array[i][j] = value
      end
    end
  end

  def each_cell(&block)
    for row in 1..row_num
      for col in 1..col_num
        instance_exec row, col, block
      end
    end
  end

end