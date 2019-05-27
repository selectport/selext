class Hash
    # fast_stringify is a 2 step process ... it stringifies the input hash
    # ie. makes sure keys and values are strings (which are json safe) and then
    # to_s... it returns a new output string which is in valid string format.
    
    def fast_stringify
      str_hash = Hash.new
      self.each {|k,v| str_hash[k.to_s] = v.to_s}
      return str_hash.to_s
    end
    
end



class String
  
  # we return this as a mash which can be interchangeable with a
  # hash ... but has the added advantage that keys can be interchangeably
  # either strings or symbols.... nice !
  
  def fast_hashify
    begin
      h = eval(self)
      return SelextMash.new(h)
    rescue
      return nil
    end
  end

end
