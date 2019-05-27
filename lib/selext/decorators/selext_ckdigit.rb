class SelextCkdigit

  # -------------------------------------------------------------------------------------
  # compute(instring) - compute and return the checkdigit of the given string
  # -------------------------------------------------------------------------------------
  
  def SelextCkdigit.compute(instring)

    # no check digits on blank or empty strings

    assert instring.length >= 1, "Invalid argument length"
    assert instring.not_blank?,  "Invalid blank argument"

    # strip instring, break into an array; insert a 0 at first element if
    # length is odd (won't effect calc'd checkdigit)

    arry = instring.strip.upcase.split("")
    if arry.length % 2 == 1
      arry.insert(0,'0')
    end

    # step thru the array elements, compute and accumulate

    runtotal = 0

    arry.each_index do |i|

      n = arry[i].bytes[0] - 48

      if i % 2 == 0  # ie. even position; no weight

        runtotal = runtotal + n

      else  # ie. odd position;  double weight

        m = (2 * n) - (9 * (n/5).floor)

        runtotal = runtotal + m

      end

    end  # arry.each loop

    # now compute ckdigit as 10 - mod10

    ckdig = 10 - (runtotal % 10)
    ckdig = 0 if ckdig == 10

    return ckdig.to_s

  end  # .compute

  # -------------------------------------------------------------------------------------
  # validate(instring) - compute the check digit and compare to last digit and return
  # true if valid or false if not
  # -------------------------------------------------------------------------------------

  def SelextCkdigit.validate(instring)

    return false if instring.length <= 1

    ckdig = instring[instring.length-1]

    computed = self.compute(instring[0,instring.length-1])

    ckdig == computed ? true : false

  end

end

