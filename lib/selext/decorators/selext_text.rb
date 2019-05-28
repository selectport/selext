# general non-classed methods

def blank_or_strip(x)

  if x.nil?
    return ''
  end

  if x.is_a?(String)
    return x.chomp.strip
  end

  return x
  
end


class SelextText
 
  # -------------------------------------------------------------------------------------
  #  pad(inbuffer, ilen)  ==> string of ilen bytes;  pads string
  # -------------------------------------------------------------------------------------

  def SelextText.pad(inbuffer, ilen)
  
    retbuffer = String.new(" " * ilen)
    inlen = inbuffer.length
  
    for i in 1..inlen do
      retbuffer[i-1,1] = inbuffer[i-1,1]
    end
  
    return retbuffer
  
  end

  # -------------------------------------------------------------------------------------
  #  htmlpad(inbuffer, ilen)  ==> string of ilen bytes;  pads string with &nbsp
  #  note - due to proportional fonts this often won't yield what you're expecting !
  # -------------------------------------------------------------------------------------


  def SelextText.nbsp
    #nbsp = 0xC2.chr + 0xA0.chr
    nbsp = '\u00A0'
  end

  def SelextText.htmlpad(inbuffer, ilen)
  
    retbuffer = String.new(' ' * ilen)
    inlen = inbuffer.length
  
    for i in 1..inlen do
      retbuffer[i-1,1] = inbuffer[i-1,1]
    end

    bretbuffer = retbuffer.gsub(' ', SelextText.nbsp)
  
    return bretbuffer
  
  end

  # --------------------------------------------------------------------------------------
  # digits?(in_s)  ==> returns true if only digits (0-9);  returns false for anything else
  # --------------------------------------------------------------------------------------

  def SelextText.digits?(in_s)
  
    return false if (in_s == nil)    
    in_s.to_s.match(/\D+/) == nil ? true : false
  
  end

  # --------------------------------------------------------------------------------------
  # blank?(in_s)  ==> returns true if blanks or nil
  # --------------------------------------------------------------------------------------

  def SelextText.blank?(in_s)
  
    return true if (in_s == nil)
    return true if (in_s.strip == "")
    return false
  
  end

  # --------------------------------------------------------------------------------------
  # include_punct?(in_s)  ==> returns true if string includes punctuation character
  # --------------------------------------------------------------------------------------

  # note - tried and tried to get a regex to include some of the regex chars; use
  # case for this is password rule validation and $ is a common char in there
  # so we have to brute force this ...

  def SelextText.include_punct?(in_s)

    ipos = in_s =~ /[\]\[!"#$%&'()*+,.\/\\:;<=>?@\^_`{|}~-]/

    # return true true/false

    ipos ? true : false

  end
    

  # --------------------------------------------------------------------------------------
  # not_blank?(in_s)  ==> returns false if blanks or nil
  # --------------------------------------------------------------------------------------

  def SelextText.not_blank?(in_s)
  
    return false if (in_s == nil)
    return false if (in_s.strip == "")
    return true
  
  end


  # --------------------------------------------------------------------------------------
  # from_macaddr(in_macaddr) ==> returns a mac address stripped of its colons
  # --------------------------------------------------------------------------------------


  def SelextText.from_macaddr(in_macaddr)
    
    if in_macaddr.length != 17 then
      raise StandardError, "invalid input mac address - length is not 17"
    end
    
    return in_macaddr.split(":").join
  end


  # --------------------------------------------------------------------------------------
  # not_blank?(in_s)  ==> returns false if blanks or nil
  # --------------------------------------------------------------------------------------

  
  def SelextText.to_macaddr(in_addr)
    
    if in_addr.length != 12 then
      raise StandardError, "invalid input mac address - length is not 12"
    end
    
    macaddr = "01:34:67:90:23:56"
    macaddr[0,2]  = in_addr[0,2]
    macaddr[3,2]  = in_addr[2,2]
    macaddr[6,2]  = in_addr[4,2]
    macaddr[9,2]  = in_addr[6,2]
    macaddr[12,2] = in_addr[8,2]
    macaddr[15,2] = in_addr[10,2]
  
    return macaddr
  end

  # --------------------------------------------------------------------------------------
  # camelize(in_s)  ==> convert snake_case => camelCase
  # --------------------------------------------------------------------------------------

  def SelextText.camelize(in_s, uppercase_first_letter = true)

    return in_s.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }

  end

  # --------------------------------------------------------------------------------------
  # snakeize(in_s)  ==> convert camelCase => snake_case 
  # --------------------------------------------------------------------------------------

  def SelextText.snakeize(in_s)
    
       inword = in_s.dup
       inword.gsub(/::/, '/')
             .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
             .gsub(/([a-z\d])([A-Z])/,'\1_\2')
             .tr("-", "_")
             .downcase

       
  end

  # --------------------------------------------------------------------------------------
  # fileize(in_s)  ==> convert camelCase => snake_case for file names (::->_ vs ::->/)
  # --------------------------------------------------------------------------------------

  def SelextText.fileize(in_s)
    
       inword = in_s.dup
       inword.gsub(/::/, '_')
             .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
             .gsub(/([a-z\d])([A-Z])/,'\1_\2')
             .tr("-", "_")
             .downcase

       
  end

  # --------------------------------------------------------------------------------------
  # tableize(in_s)  ==> convert camelCase => snake_case for table names (::->_ vs ::->/)
  # --------------------------------------------------------------------------------------

  def SelextText.tableize(in_s)
    
       inword = in_s.dup
       inword.gsub(/::/, '_')
             .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
             .gsub(/([a-z\d])([A-Z])/,'\1_\2')
             .tr("-", "_")
             .downcase
             .pluralize
       
  end

  # ----------------------------------------------------------------------------
  # humanize(in_s) ===> convert snake_case -> separate words
  # ----------------------------------------------------------------------------

  def SelextText.humanize(in_s)

    result = in_s.to_s.dup

    result.sub!(/\A_+/, '')
    result.sub!(/_id\z/, '')
    result.tr!('_', ' ')

    result

  end

  # ----------------------------------------------------------------------------
  # titleize(in_s) ===> convert snake case to words and capitalize
  # ----------------------------------------------------------------------------

  def SelextText.titleize(in_s)
    words = in_s.to_s.dup
    result1 = SelextText.humanize(words)
    result2 = result1.gsub(/\b(?<!['’`])[a-z]/) { $&.capitalize }

    result2

  end

  # ---------------------------------------------------------------------------------------------
  # classify(in_s)  ==> convert snake_case => ClassName for table or model names (::->_ vs ::->/)
  # ---------------------------------------------------------------------------------------------

  # incoming should be either a model name (singular, underscore) or a table name (plural, underscore)

  def SelextText.classify(in_s)
    
       return in_s if in_s.include?('::')

       inword = in_s.dup
       a = SelextText.camelize(inword.singularize)
       outword = a

       outword
       
  end

  # --------------------------------------------------------------------------------------
  # randomString(size)  ==> random upper/lower alpha string of length(size) 
  # --------------------------------------------------------------------------------------

  def SelextText.randomString(size)

      alphabet = [('a'..'z').to_a, ('A'..'Z').to_a].flatten
      (1..size).inject("") { |s, x| s << alphabet[rand(alphabet.size)] }
       
  end


  # --------------------------------------------------------------------------------------
  # more_compressed(tezt, max_len) => returns string truncated with ...more appended if needed
  # --------------------------------------------------------------------------------------

  def SelextText.more_compressed(in_text, in_maxlen)
    out_text = in_text
    out_text = in_text[0,in_maxlen-8] + " ...more" if in_text.size > in_maxlen
    out_text
  end

  # --------------------------------------------------------------------------------------
  # ellipsis_compressed(tezt, max_len) => returns string truncated with ... appended if needed
  # --------------------------------------------------------------------------------------

  def SelextText.ellipsis_compressed(in_text, in_maxlen)
    out_text = in_text
    out_text = in_text[0,in_maxlen-4] + " ..." if in_text.size > in_maxlen
    out_text
  end

  # ----------------------------------------------------------------------------
  # display timestamp displays a formatted utc timestamp
  # ----------------------------------------------------------------------------

  def self.display_timestamp(in_datetime)

   return "" if (in_datetime == nil) 

   in_datetime.as_selectport_display
   
  end

  # ----------------------------------------------------------------------------
  # display user's tz timestamp displays a formatted user's_tz timestamp
  # ----------------------------------------------------------------------------

  def self.display_users_timestamp(in_datetime, in_time_zone='Eastern Time (US & Canada)')

   return "" if (in_datetime == nil) 

   tz_datetime = in_datetime.in_time_zone(in_time_zone)
   tz_datetime.as_selectport_display
   
  end

  # ----------------------------------------------------------------------------
  # format booleans to display Yes/No
  # ----------------------------------------------------------------------------

  def self.display_boolean(in_bool)
    
    in_bool ? "Yes" : "No"

  end



end  #  class
