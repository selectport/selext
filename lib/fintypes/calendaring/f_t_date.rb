class FTdate

  attr_reader :month, :day, :year, :full, :standard

# ------------------------------------------------------------------------------
# class methods:
# ------------------------------------------------------------------------------
# date2std converts a normal Date to our i8 std (yyyymmdd) integer format

  def self.date2std(ddate)

    std = "#{sprintf('%04d',ddate.year)}#{sprintf('%02d', ddate.month)}#{sprintf('%02d',ddate.day)}".to_i    
    return std

  end

# ------------------------------------------------------------------------------

  def initialize(in_date)

    if in_date.is_a?(Integer)

      s=in_date.to_s

      raise Programming Error, "Invalid integer for FTdate" if s.length != 8

      @year  = s[0,4].to_i
      @month = s[4,2].to_i
      @day   = s[6,2].to_i
      @full  = Time.new(@year, @month, @day)
      @standard = in_date
      return
    end

    if in_date.is_a?(String)
      
      case in_date.length

      when 8

        @year  = in_date[0,4].to_i
        @month = in_date[4,2].to_i
        @day   = in_date[6,2].to_i
        @full  = Time.new(@year, @month, @day)
        @standard = in_date.to_i
        return

      when 10

        @year  = in_date[0,4].to_i
        @month = in_date[5,2].to_i
        @day   = in_date[8,2].to_i
        @full  = Time.new(@year, @month, @day)
        @standard = "#{sprintf('%04d',@year)}#{sprintf('%02d',@month)}#{sprintf('%02d',@day)}".to_i
        return
     
      when 25

        @year  = in_date[0,4].to_i
        @month = in_date[5,2].to_i
        @day   = in_date[8,2].to_i
        @full  = Time.new(@year, @month, @day)
        @standard = "#{sprintf('%04d',@year)}#{sprintf('%02d',@month)}#{sprintf('%02d',@day)}".to_i
        return
     
      else raise StandardError, "Invalid string date format for FTdate"

      end

    end

    if in_date.is_a?(Time)

      @year  = in_date.year
      @month = in_date.month
      @day   = in_date.day
      @full  = Time.new(@year, @month, @day)
      @standard = "#{sprintf('%04d',@year)}#{sprintf('%02d',@month)}#{sprintf('%02d',@day)}".to_i
      return
    end

    if in_date.respond_to?(:year) &&
       in_date.respond_to?(:month) &&
       in_date.respond_to?(:day)

       @year = in_date.year.to_i
       @month = in_date.month.to_i
       @day = in_date.day.to_i
       @full  = Time.new(@year, @month, @day)
       @standard = "#{sprintf('%04d',@year)}#{sprintf('%02d',@month)}#{sprintf('%02d',@day)}".to_i
       return

    end

# ------------------------------------------------------------------------------

  end # initialize


# ------------------------------------------------------------------------------
# is_a? methods

  def day_name

    case @full.wday

    when 0
      return 'sunday'
    when 1
      return 'monday'
    when 2
      return 'tuesday'
    when 3
      return 'wednesday'
    when 4
      return 'thursday'
    when 5
      return 'friday'
    when 6 
      return 'saturday'
    end
  end

  def day_abbrev

    case @full.wday

    when 0
      return 'Su'
    when 1
      return 'Mo'
    when 2
      return 'Tu'
    when 3
      return 'We'
    when 4
      return 'Th'
    when 5
      return 'Fr'
    when 6 
      return 'Sa'
    end
  end


  def is_a_normal_business_day?
    Fintypes::BUSINESS_DAYS.include?(day_name)
  end

  def is_not_a_normal_business_day?
    !Fintypes::BUSINESS_DAYS.include?(day_name)
  end

  def is_a_bank_holiday?
    Fintypes.bank_holidays.include?(@standard) ? true : false
  end

  def is_a_bank_day?
    return false if is_not_a_normal_business_day?
    return false if Fintypes.bank_holidays.include?(@standard)
    return true
  end

  def is_a_proc_holiday?
    Fintypes.proc_holidays.include?(@standard) ? true : false
  end
  
  def is_a_proc_day?
    return false if is_not_a_normal_business_day?
    return false if Fintypes.proc_holidays.include?(@standard)
    return true
  end

  def is_not_a_proc_day?
    !is_a_proc_day?
  end

  def is_a_sett_holiday?
    Fintypes.sett_holidays.include?(@standard) ? true : false
  end
  
  def is_a_sett_day?
    return false if is_not_a_normal_business_day?
    return false if Fintypes.sett_holidays.include?(@standard)
    return true
  end

  def is_a_biz_holiday?
    Fintypes.biz_holidays.include?(@standard) ? true : false
  end
  
  def is_a_biz_day?
    return false if is_not_a_normal_business_day?
    return false if Fintypes.biz_holidays.include?(@standard)
    return true
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# date arithmetic
# note - for some of the calcs, we work directly with Date class for arith
#        rather than instantiating an FTdate ... we're also using some of the
#        activesupport helpers and assuming bizdays are m-f and s/s are weekends
#        this can be changed if we ever need to expand that by using the 
#        Fintypes::BUSINESS_DAYS array
#        

# ------------------------------------------------------------------------------

  def add_proc_days(days)
    add_days(days, :proc)
  end

  def add_bank_days(days)
    add_days(days, :bank)
  end

  def add_sett_days(days)
    add_days(days, :sett)
  end

  def add_biz_days(days)
    add_days(days, :biz)
  end


  def sub_proc_days(days)
    sub_days(days, :proc)
  end

  def sub_bank_days(days)
    sub_days(days, :bank)
  end

  def sub_sett_days(days)
    sub_days(days, :sett)
  end

  def sub_biz_days(days)
    sub_days(days, :biz)
  end

# ------------------------------------------------------------------------------
# x_days_between
#
# end_date arg is an FTdate
#
  def proc_days_between(end_date)
    days_between(end_date, :proc)
  end

  def bank_days_between(end_date)
    days_between(end_date, :bank)
  end

  def sett_days_between(end_date)
    days_between(end_date, :sett)
  end

  def biz_days_between(end_date)
    days_between(end_date, :biz)
  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
private

# ------------------------------------------------------------------------------
  
  def add_days(days, calendar)

    # quick dup and return if 0 days requested

    if days == 0
      return self.dup
    end

    # step thru...skipping weekends and proc_holidays

    idays = 0
    next_date = Date.new(@year, @month, @day)   # start with our current state

    while idays < days do

      next_date = next_date + 1

      if next_date.on_weekend?
        next_date = next_date + 1
      end

      if next_date.on_weekend?
        next_date = next_date + 1
      end

      std_date  = FTdate.date2std(next_date)

      case calendar

      when :proc
        next_date += 1 if Fintypes.proc_holidays.include?(std_date)

      when :sett
        next_date += 1 if Fintypes.sett_holidays.include?(std_date)

      when :bank
        next_date += 1 if Fintypes.bank_holidays.include?(std_date)

      when :biz
        next_date += 1 if Fintypes.biz_holidays.include?(std_date)

      else
        raise StandardError, "Invalid calendar type : #{calendar}"
      end


      idays += 1

    end

    new_date = FTdate.new(next_date)

  end

# ------------------------------------------------------------------------------

  def sub_days(days, calendar)

    # quick dup and return if 0 days requested

    if days == 0
      return self.dup
    end

    # step thru...skipping weekends and holidays

    idays = 0
    next_date = Date.new(@year, @month, @day)   # start with our current state

    while idays < days do

      next_date = next_date - 1

      if next_date.on_weekend?
        next_date = next_date - 1
      end

      if next_date.on_weekend?
        next_date = next_date - 1
      end

      std_date  = FTdate.date2std(next_date)


      case calendar

      when :proc
        next_date -= 1 if Fintypes.proc_holidays.include?(std_date)

      when :sett
        next_date -= 1 if Fintypes.sett_holidays.include?(std_date)

      when :bank
        next_date -= 1 if Fintypes.bank_holidays.include?(std_date)

      when :biz
        next_date -= 1 if Fintypes.biz_holidays.include?(std_date)

      else
        raise StandardError, "Invalid calendar type : #{calendar}"
      end


      idays += 1

    end

    new_date = FTdate.new(next_date)

  end

# ------------------------------------------------------------------------------

def days_between(end_date, calendar)

  if (end_date.standard == @standard)
    return 0
  end

  direction = :fwd  if @standard < end_date.standard
  direction = :back if @standard > end_date.standard

  if direction == :fwd
    startd = Date.new(@year, @month, @day)
    stopd  = Date.new(end_date.year, end_date.month, end_date.day)
  end

  if direction == :back
    startd = Date.new(end_date.year, end_date.month, end_date.day)
    stopd  = Date.new(@year, @month, @day)
  end

  calc_days = 0
  next_date = startd.dup

  while next_date < stopd

    next_date = next_date + 1
    next if next_date.on_weekend?

    case calendar

    when :proc
      calc_days += 1 unless Fintypes.proc_holidays.include?(FTdate.date2std(next_date))

    when :sett
      calc_days += 1 unless Fintypes.sett_holidays.include?(FTdate.date2std(next_date))

    when :bank
      calc_days += 1 unless Fintypes.bank_holidays.include?(FTdate.date2std(next_date))

    when :biz
      calc_days += 1 unless Fintypes.biz_holidays.include?(FTdate.date2std(next_date))

    else
      raise StandardError, "Invalid calendar type : #{calendar}"
    end

  end # while

  return calc_days

end

# ------------------------------------------------------------------------------

end # class
