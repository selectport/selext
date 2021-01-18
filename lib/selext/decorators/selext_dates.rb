class SelextDate

  SelextDate::MONTHENDS = Array[31,28,31,30,31,30,31,31,30,31,30,31]

  SelextDate::MONTHENDS_HASH = ::SelextMash.new(
    jan: 31,
    feb: 28,
    mar: 31,
    apr: 30,
    may: 31,
    jun: 30,
    jul: 31,
    aug: 31,
    sep: 30,
    oct: 31,
    nov: 30,
    dec: 31
)

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

    require 'date'

    # --------------------------------------------------------------------------
    #  format timestamp or show n/a;  datetime is a Timestamp 
    # --------------------------------------------------------------------------

    def SelextDate.timestamp_or(datetime)

      return "n/a" if datetime.nil?
      return "n/a" if datetime.is_a?(String) && datetime.blank?

      retval = ''

      begin
        t = datetime.in_time_zone('Arizona')
        retval = t.as_selext_display
      rescue
        retval = "n/a"
      end

      retval
      
    end

    # --------------------------------------------------------------------------
    #  standard ruby Date ==> yyyymmdd as string
    # --------------------------------------------------------------------------

    def SelextDate.date2stddate(ddate)

      assert ddate.class == Date

      retdate = "yyyymmdd"
      retdate[0..3] = sprintf("%04d", ddate.year)
      retdate[4..5] = sprintf("%02d", ddate.month)
      retdate[6..7] = sprintf("%02d", ddate.day)

      retdate

    end


    # --------------------------------------------------------------------------
    #  mdy2stddate(mdy) ==> yyyymmdd as string
    # --------------------------------------------------------------------------
  
    def SelextDate.mdy2stddate(mdy)

      if (mdy.length == 7) then
        indate = " " + mdy
      end

      if (mdy.length == 8) then
        indate = mdy
      end

      pmdy = mdy.split(/\//)
    
      retdate = "yyyymmdd"
    
      retdate[2..3] = sprintf("%02s", pmdy[2])
      retdate[4..5] = sprintf("%02s", pmdy[0])
      retdate[6..7] = sprintf("%02s", pmdy[1])
    
      retdate.gsub!(/\s/,"0")
    
      iyear = pmdy[2].to_i
    
      if ((iyear >= 0) and (iyear < 30)) then
        retdate[0..1] = '20'
      else
        retdate[0..1] = '19'
      end
      
      return retdate
    end
  
    # --------------------------------------------------------------------------
    # yyyyymmdd2mmddyyyy(yyyymmdd) ==> mmddyyyy as string
    # --------------------------------------------------------------------------
  
    def SelextDate.yyyymmdd2mmddyyyy(yyyymmdd)
    
      retdate = "mmddyyyy"
      retdate[0..1] = yyyymmdd[4..5]
      retdate[2..3] = yyyymmdd[6..7]
      retdate[4..7] = yyyymmdd[0..3]
      return retdate
    end

    # --------------------------------------------------------------------------
    # yyyymmdd2ordina(yyyymmdd)  ==> yddd (string, string)
    # --------------------------------------------------------------------------
  
    def SelextDate.yyyymmdd2ordinal(yyyymmdd)
    
      imon  = yyyymmdd[4..5].to_i
      iday  = yyyymmdd[6..7].to_i
      iyear = yyyymmdd[0..3].to_i
    
      jd = Date.civil_to_jd(iyear, imon, iday)
      od = Date.jd_to_ordinal(jd)               # => [yyyy,ddd] (as integers)
      cy = od[0].to_s
      cd = sprintf("%03d", od[1])
      retdate = "yddd"
      retdate[0..0] = cy[3..3]
      retdate[1..3] = cd[0..2]
    
    
      return retdate
      end

    
     # --------------------------------------------------------------------------
     # mdcy2yyyymmdd(mm/dd/yyyy) => yyyymmdd
     # --------------------------------------------------------------------------

      def SelextDate.mdcy2yyyymmdd(mdcy)
      
        pmdy = mdcy.split(/\//)

        retdate = "yyyymmdd"

        retdate[0..3] = sprintf("%02s", pmdy[2])
        retdate[4..5] = sprintf("%02s", pmdy[0])
        retdate[6..7] = sprintf("%02s", pmdy[1])

        retdate.gsub!(/\s/,"0")

        return retdate
        end

     # --------------------------------------------------------------------------
     # mdcy2yyyymmdd(mm/dd/yyyy) => yyyy-mm-dd
     # --------------------------------------------------------------------------

      def SelextDate.mdcy2yyyy_mm_dd(mdcy)
      
        pmdy = mdcy.split(/\//)

        retdate = "yyyy-mm-dd"

        retdate[0..3] = sprintf("%02s", pmdy[2])
        retdate[5..6] = sprintf("%02s", pmdy[0])
        retdate[8..9] = sprintf("%02s", pmdy[1])

        retdate.gsub!(/\s/,"0")

        return retdate
        end

          
    
     # --------------------------------------------------------------------------
     # yyyymmdd2mdcy(yyyymmdd) => mm/dd/yyyy
     # --------------------------------------------------------------------------

      def SelextDate.yyyymmdd2mdcy(yyyymmdd)
      
        retdate = "mm/dd/ccyy"

        retdate[0,2] = yyyymmdd[4,2]
        retdate[3,2] = yyyymmdd[6,2]
        retdate[6,4] = yyyymmdd[0,4]


        return retdate
        end

      # --------------------------------------------------------------------------
      # valstddate(yyyymmdd) --> true/false
      # --------------------------------------------------------------------------

      def SelextDate.valstddate(in_date)
      
        return false if !(in_date =~ /\d{8}/)
      
        inmonth = in_date[4,2].to_i
        inday = in_date[6,2].to_i
        inyear = in_date[0,4].to_i
      
        return false if !((1..12).include?(inmonth)) 
      
        return false if (inday > 31)
      
        return false if ((inyear < 1600) or (inyear > 2100)) 
      
        # now do month-specifics
      
        return false if ([2,4,6,9,11].include?(inmonth) and (inday > 30))  
      
        if inmonth == 2 then
        
          return false if (self.is_leap?(in_date) and (inday > 29)) 
          return false if (!(self.is_leap?(in_date)) and (inday > 28))
        end
        return true
      
      end
      # --------------------------------------------------------------------------
      # valexpdate(yyyy-mm-dd) --> true/false
      # --------------------------------------------------------------------------

      def SelextDate.valexpdate(in_date)
      
        return false if !(in_date =~ /\d{4}-\d{2}-\d{2}/)

        inmonth = in_date[5,2].to_i
        inday   = in_date[8,2].to_i
        inyear  = in_date[0,4].to_i
      
        return false if !((1..12).include?(inmonth)) 
      
        return false if (inday > 31)
      
        return false if ((inyear < 1600) or (inyear > 2100)) 
      
        # now do month-specifics
      
        return false if ([2,4,6,9,11].include?(inmonth) and (inday > 30))  
      
        if inmonth == 2 then
        
          stddate = "yyyymmdd"
          stddate[0,4] = in_date[0,4]
          stddate[4,2] = in_date[5,2]
          stddate[6,2] = in_date[8,2]

          return false if (self.is_leap?(stddate) and (inday > 29)) 
          return false if (!(self.is_leap?(stddate)) and (inday > 28))
        end
        return true
      
      end
        
        # -----------------------------------------------------------------------------
        # is_leap?(year)   --> true or false;  note year is string 4 (ccyy) or string 8 (ccyymmdd)
        # -----------------------------------------------------------------------------

        def SelextDate.is_leap?(in_year)
        
          unless ((in_year.length == 4) or (in_year.length == 8)) then
            puts "#{in_year} has bad length"
          end
        
          if (in_year.length == 4) then
            if !(in_year =~ /\d{4}/) then
              puts "#{in_year} not all digits"
              return false
            end
          
            iyear = in_year.to_i
          
          end
        
          if (in_year.length == 8) then
            if !(in_year =~ /\d{8}/) then
              puts "#{in_year} not all digits"
              return false
            end
          
            iyear = in_year[0,4].to_i
          
          end
        
          # now we can determine if it's a leap year
          # All years divisible by 4 are leap years in the Gregorian calendar, 
          # except for years divisible by 100 and not by 400.
        
          return (iyear % 4 == 0) && ((iyear % 100 != 0) || (iyear % 400 == 0))
        
        end
      
        # --------------------------------------------------------------------------
        # convert2stddate(in_date, in_style)  (any valid indate format ==> yyyymmdd format)
        # --------------------------------------------------------------------------

        def SelextDate.convert2stddate(un_date, style="mdy")
        
          # first, see if any slashes, dashes, or dots

          if un_date =~ /\/|\.|\-/ then
            sdd = "Y"
            in_date = un_date.gsub(/\/|\.|\-/, "-")
          else
            sdd = "N"
            in_date = un_date
          end
        
        
          if sdd == "Y"
          
            # split it into an array
          
            datarry = in_date.split("-")
          
            # is it m,d,y or d,m,y or y,m,d or y,d,m?
          
              if (style == "mdy") or (style == "mdc") then          
                  imonth = datarry[0].to_i
                  iday   = datarry[1].to_i
                  iyear  = datarry[2].to_i
                end
              
              if (style =="ydm") or (style == "cdm") then
                  imonth = datarry[2].to_i
                  iday   = datarry[1].to_i
                  iyear  = datarry[0].to_i
                end   

              if (style == "ymd") or (style == "cmd") then
                  imonth = datarry[1].to_i
                  iday   = datarry[2].to_i
                  iyear  = datarry[0].to_i
                end   
              

              if (style == "dmy") or (style == "dmc") then
                  imonth = datarry[1].to_i
                  iday   = datarry[0].to_i
                  iyear  = datarry[2].to_i
                end   
            
            end
          
          
         
          
          if sdd == "N"
          
            if (un_date.length > 8) then
              raise "invalid date (length) in convert2stddate"
            end
  
            # if length is 7, must assume leading 0 was dropped
            # ie. we don't support bmbdyy
          
            if (un_date.length == 7) then
              
                if ((style == "ymd") or (style == "cmd") or (style == "ydm") or (style == "cdm")) then
                  raise 'invalid date (length 7 mismatches date style)'
                end
              
                in_date = "0ddddddd"
                in_date[1,7] = un_date
              
              end
            
            if (un_date.length == 5) then
            
              unless ((style == "mdy") or (style == "mdc")) then
                raise 'invalid date (length 5 mismatches date style)'
              end
            
              in_date = "0ddddd"
              in_date[1,5] = un_date
            
              end
                    
            
            if ((un_date.length == 5) or (un_date.length == 6)) then
            
              if (style == "mdy") or (style == "mdc") then          
                  imonth = in_date[0,2].to_i
                  iday   = in_date[2,2].to_i
                  iyear  = in_date[4,2].to_i
                end

              if (style =="ydm") or (style == "cdm") then
                  imonth = in_date[4,2].to_i
                  iday   = in_date[2,2].to_i
                  iyear  = in_date[0,2].to_i
                end   

              if (style == "ymd") or (style == "cmd") then
                  imonth = in_date[2,2].to_i
                  iday   = in_date[4,2].to_i
                  iyear  = in_date[0,2].to_i
                end   


              if (style == "dmy") or (style == "dmc") then
                  imonth = in_date[2,2].to_i
                  iday   = in_date[0,2].to_i
                  iyear  = in_date[4,2].to_i
                end            
            
              end  # un_date.lenght < 9

            # easy case first -> length = 8
  
            if (in_date.length == 8) then
                    
              if (style == "mdy") or (style == "mdc") then          
                  imonth = in_date[0,2].to_i
                  iday   = in_date[2,2].to_i
                  iyear  = in_date[4,4].to_i
                end
            
              if (style =="ydm") or (style == "cdm") then
                  imonth = in_date[6,2].to_i
                  iday   = in_date[4,2].to_i
                  iyear  = in_date[0,4].to_i
                end   

              if (style == "ymd") or (style == "cmd") then
                  imonth = in_date[4,2].to_i
                  iday   = in_date[6,2].to_i
                  iyear  = in_date[0,4].to_i
                end   
            

              if (style == "dmy") or (style == "dmc") then
                  imonth = in_date[2,2].to_i
                  iday   = in_date[0,2].to_i
                  iyear  = in_date[4,4].to_i
                end            

            end  # sdd = N, length = 8

          end  # ! sdd == 'N'
        
          # by here, imonth, iday, iyear have been parsed for all conditions
        
          # now fix up century if needed
        
          iyear = iyear + 1900  if ((iyear >= 30) and (iyear <= 99))
          iyear = iyear + 2000  if ((iyear >= 0) and (iyear <= 29))

          if ((iyear < 1900) or (iyear > 2099)) then
            raise "invalid date (century)  in convert2stddate"
          end
        
          # now write it out and return
        
          outdate = "yyyymmdd"
          outdate[0,4] = sprintf("%04d", iyear)
          outdate[4,2] = sprintf("%02d", imonth)
          outdate[6,2] = sprintf("%02d", iday)         

          return outdate
        end
      
        # --------------------------------------------------------------------------
        # guessStyle(in_date)  (try to guess mdy style from random date format)
        # --------------------------------------------------------------------------

        def SelextDate.guessStyle(un_date)

          # this is purposefully simple;  it assumes North American convention of month-day-year order
          # 
          # first, we can only guess input lengths of 5,6,7,8,9,10
          #      note : /-. allowed for /
          #
          #   5  bmddyy (mdy)
          #   6  mmddyy (mdy)
          #   7  bmddccyy (mdc),  bm/dd/yy (mdy)
          #   8  mm/dd/yy (mdy),  yyyymmdd (cmd),  mmddyyyy (mdc)
          #   9  bm/dd/yyyy (mdc)
          #  10  mm/dd/yyyy (mdc),  yyyy/mm/dd (cmd)
          #
          #  note : after date style is guessed, date is convered to that style and then validated and if fails, style is XXX
          #
          #  NOTE NOTE NOTE : This is a best guess and there are plenty of conditions that it will guess wrong!  for safest
          #  solution, use a style;  next best, stick to either ccyymmdd or mm/dd/yyyy formats - they'll generally always be
          #  correct.
        
          # first, edit our length and short circuit 
        
          ilen = un_date.strip.length
          guess_style = " "
          guess_date = " "
          try_date = " " 
          sdd = 'N'
        
          if (ilen < 5) or (ilen > 10) then       # invalid
            return 'XXX'
          end
        
           # first, see if any slashes, dashes, or dots

          if un_date =~ /\/|\.|\-/ then
            sdd = "Y"
            sdd_date = un_date.gsub(/\/|\.|\-/, "/")
          else
            sdd = "N"
            sdd_date = un_date
          end
        
          if (ilen == 5) and (sdd == 'Y')         # invalid
            return 'XXX'
          end
        
          if (ilen == 6) and (sdd == 'Y')         # invalid
            return 'XXX'
          end
        
          if (sdd_date.strip =~ /[^0-9\/]/) then  # anything but 0-9 and \ is a fail
             return 'XXX'
          end
               
          if (ilen == 5) then                     # bmddyy   
            guess_date = "0ddddd"
            guess_date[1,5] = sdd_date 
            guess_style = "mdy"
            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
          
          if (ilen == 6) then                     # mmddyy
            guess_date = sdd_date
            guess_style = "mdy"
            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (ilen == 7) and (sdd == 'Y') then     # bm/dd/yy
            guess_style = 'mdy'
            guess_date = "0m/dd/yy"
            guess_date[1,7] = sdd_date
          
            return 'XXX' if !(guess_date =~ /\d\d\/\d\d\/\d\d/)   # must be 99/99/99 format

            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
            
          if (ilen == 7) and (sdd == 'N') then    # bmddccyy
            guess_style = "mdc"
            guess_date = "0mddccyy"
            guess_date[1,7] = sdd_date
            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (ilen == 8) and (sdd == 'Y') then     # mm/dd/yy
            guess_style = 'mdy'
            guess_date  = sdd_date

            return 'XXX' if !(guess_date =~ /\d\d\/\d\d\/\d\d/)   # must be 99/99/99 format

            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (ilen == 8) and (sdd == 'N') then     # ccyymmdd or mmddccyy

            if (sdd_date[0,2].to_i > 12) then
              guess_style = 'cmd'
              guess_date = sdd_date
              try_date = SelextDate.convert2stddate(guess_date, guess_style)
            end
          
            if (sdd_date[0,2].to_i <= 12) then
              guess_style = 'mdc'
              guess_date = sdd_date
              try_date = SelextDate.convert2stddate(guess_date, guess_style)
            end
          
          end
          
          if (ilen == 9) then                     # bm/dd/ccyy
            guess_style = "mdc"
            guess_date = "0m/dd/ccyy"
            guess_date[1,9] = sdd_date

            return 'XXX' if !(guess_date =~ /\d\d\/\d\d\/\d\d\d\d/)     # must be 99/99/9999 format

            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (ilen == 10) then        # must be formatted as either 99/99/9999 or 9999/99/99
        
             if !((sdd_date =~  /\d\d\/\d\d\/\d\d\d\d/)  or
                  (sdd_date =~  /\d\d\d\d\/\d\d\/\d\d/)) then
                
                  return 'XXX'
                  end
          end
         
        
          if (ilen == 10) and (sdd_date[2,1] == "/") then   # mm/dd/ccyy
            guess_style = "mdc"
            guess_date = sdd_date
            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (ilen == 10) and (sdd_date[4,1] == "/") then     # ccyy/mm/dd
            guess_style = "cmd"
            guess_date = sdd_date
            try_date = SelextDate.convert2stddate(guess_date, guess_style)
          end
        
          if (guess_style == "XXX") then
            return 'XXX'
          end
        
          # still got a chance!   try_date has our yyyymmdd guess in it; let's validate it
        
          if (SelextDate.valstddate(try_date)) then
            return guess_style
          else
            return 'XXX'
          end
        
        

        end      
  
  # ======================================================================================================

  end  # class

