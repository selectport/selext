require 'tzinfo'

class Time

   def as_selext_display
    fmt = self.strftime("%m/%d/%Y - %I:%M%P")
   end

   def as_selext_standard
    fmt = self.strftime("%Y%m%d  %H:%M")
   end

   def as_selext_detail
    fmt = self.strftime("%Y.%m.%d %H:%M:%S.%L")
   end

end
