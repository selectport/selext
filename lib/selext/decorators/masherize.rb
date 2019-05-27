# array.masherize takes an array of simple strings, validates that it
# is an even length, then returns a mash where each "pair" of args
# is treated as a key->value pair, evens (0-based) being keys, odds
# begin values;  see how redis treats hash arguments for basis
#
# @param args [Array<String>] even-numbered array of simple strings
# @return retmash [Mash] hashed key,value pairs if non empty and even number
# @return retmash [Mash] empty hash if args was empty
# @return false if odd number of arguments
#

class Array

  def masherize

    if self.count % 2 == 1 then
      return false
    end

    retmash = SelextMash.new

    if self.count == 0 then
      return retmash
    end

    self.each_index do |i|
        retmash[self[i]] = self[i+1] if i % 2 == 0
    end

    retmash

  end  # masherize_args

end # class
