class Dollars
  attr_accessor :value
  attr_accessor :places

  def initialize(value)
    @value = value
    @places = 2
  end

  def times(in_operand)

    if in_operand.class == Integer
      result = @value * in_operand
      return result
    end

    if in_operand.class == Shares
      operand = in_operand.value
      result = (@value * operand) / 1000
      return result
    end


  end

end
