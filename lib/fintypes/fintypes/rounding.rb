module Fintypes
  module Numerics

  def self.randcash(max_float)
    currency = (max_float * 100.00).to_i
    return rand(currency)
  end

  def self.randfullshares(max_float)
    shares = (max_float * 1000.00).to_i
    fract_shares = rand(shares)
    return fract_shares - (fract_shares % 1000)
  end

  def self.randshares(max_float)
    shares = (max_float * 1000.00).to_i
    return rand(shares)
  end

  # rounding

  def self.rndzero(fnumb)
    (((fnumb * 1.0) + 0.5).to_i / 1.0)
  end

  def self.rnd0(fnumb)
    (((fnumb * 1.0) + 0.5).to_i / 1.0)
  end

  def self.rndsng(fnumb)
    (((fnumb * 10.0) + 0.5).to_i / 10.0)
  end

  def self.rnd1(fnumb)
    (((fnumb * 10.0) + 0.5).to_i / 10.0)
  end

  def self.rnddbl(fnumb)
    #(((fnumb * 100.0) + 0.5).to_i / 100.0)
    Fintypes::NumberHelper.number_to_rounded(fnumb, precision: 2)
  end

  def self.rnd2(fnumb)
    (((fnumb * 100.0) + 0.5).to_i / 100.0)
  end

  def self.rndtrp(fnumb)
    (((fnumb * 1000.0) + 0.5).to_i / 1000.0)
  end

  def self.rnd3(fnumb)
    (((fnumb * 1000.0) + 0.5).to_i / 1000.0)
  end

  def self.rndqad(fnumb)
    (((fnumb * 10000.0) + 0.5).to_i / 10000.0)
  end

  def self.rnd4(fnumb)
    (((fnumb * 10000.0) + 0.5).to_i / 10000.0)
  end

  # decoding i's to floats

  def self.to_pct(inumb)   # -> whole pct eg 24%
    inumb / 10000.0
  end

  def self.to_decpct(inumb)  # -> true pct
    inumb / 1000000.0
  end

  def self.to_dol(inumb)
    inumb / 100.0
  end

  def self.to_shr(inumb)
    inumb / 1000.0
  end

  def self.to_price(inumb)
    inumb / 10000.0
  end

  def self.to_rate(inumb)
    inumb / 1000000000.0
  end

  def self.from_rate(fnumb)
    if fnumb.is_a?(String)
      f = fnumb.to_f
    else
      f = fnumb
    end

    f * 1000000000

  end

  # display formatters

  def self.numfmt_with_commas(dnumb, width, justify='l')

    if dnumb.is_a?(Float) || dnumb?.is_a?(Integer)
      number = dnumb.to_s
    else
      number = dnumb
    end

    parts = number.split('.')
    parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")

    if justify == 'R' || justify == 'r'
      return parts.join('.').rjust(width)
    else
      return parts.join('.').ljust(width)
    end
    
  end


  def self.numfmt(dnumb, width)

    SelextText.pad(dnumb, width)

  end

end # module numerics
end # module fintypes

# Fintypes::Numerics is the same as SelextNumerics ... if both libraries
# are defined, only map the NN constant onto Fintypes::Numerics

unless defined?(NN)
  NN = Fintypes::Numerics
end

