# Fast jsonify adds a method (jsonify) to Hash, Mash, and Array
# which converts symbols (keys, values) to strings and then does a .to_json
# returning a String without symbols 

class Array
  def jsonify
     a = Array.new
     self.each do |el|
       el.class == Symbol ? a << el.to_s : a << el 
     end
     a.to_json
  end
end

class Hash
  def jsonify
    h = Hash.new
    self.each do |key, val| 
      key.class == Symbol ? nkey = key.to_s : nkey = key
      val.class == Symbol ? nval = val.to_s : nval = val
      h[nkey] = nval
    end
    h.to_json
  end
end

class SelextMash
  def jsonify
    h = Hash.new
    self.each do |key, val| 
      key.class == Symbol ? nkey = key.to_s : nkey = key
      val.class == Symbol ? nval = val.to_s : nval = val
      h[nkey] = nval
    end
    m.to_json
  end
end
