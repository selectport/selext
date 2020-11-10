class Shares

  PLACES = 3

  attr_accessor :value
  attr_accessor :places

  def initialize(value)

    @places = Shares::PLACES
   
    # if value is an integer, we assume it's *1000 shares;
    # if it is a decimal, we'll multiply it by 1000 and int it

    case 
      
    when value.class == Integer
      @value = value

    when value.class == Float
      @value = (value * @places).to_i
    else
      raise StandardError, "Invalid value to initialize shares with"
    end

  end

  def *(operand)
    result = @value * operand
    return result
  end

  def times(operand)

    if operand.class == Integer

      result = operand * @value
      return result

    end

    if operand.class == Dollar

      result = operand * @value

      return result

    end

  end

end
