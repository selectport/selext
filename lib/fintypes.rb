require_relative './fintypes/fintypes/version.rb'
require_relative './fintypes/fintypes/rounding.rb'
require_relative './fintypes/fintypes/dollars.rb'
require_relative './fintypes/fintypes/shares.rb'
require_relative './fintypes/fintypes/number_helper.rb'

require_relative './fintypes/calendaring/f_t_date.rb'

require 'active_support/core_ext/time'
require 'active_support/core_ext/date'

Time.zone='UTC'  # lingua franca for internal use


module Fintypes

extend self

# ------------------------------------------------------------------------------
# Define Constants

  BUSINESS_DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday' ]

# ------------------------------------------------------------------------------
# Define Variables

  attr_accessor     :initmode             # flag if called already

  attr_accessor     :bank_holidays        # array of yyyymmdd ints
  attr_accessor     :proc_holidays        # array of yyyymmdd ints
  attr_accessor     :sett_holidays        # array of yyyymmdd ints
  attr_accessor     :biz_holidays         # array of yyyymmdd ints

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def initialize!

  return if @initmode == 'initialized'

  # load the 4 holiday arrays from the project's customizers/fintypes_calendars.rb
  # file;  unfortunately, this loads before full selext framework does, so we must
  # manually map onto the customizers directory (as is done in Selext.customizers)

  @bank_holidays = []
  @proc_holidays = []
  @sett_holidays = []
  @biz_holidays  = []

  cal_file = File.expand_path(File.join(Selext.home, 'customizers', 'fintypes_calendars.rb'))

  if File.exists?(cal_file)

    require cal_file

    @bank_holidays = Fintypes::BANK_HOLIDAYS.map { |x| SelextDate.crunch(x).to_i }
    @proc_holidays = Fintypes::PROCESSING_HOLIDAYS.map { |x| SelextDate.crunch(x).to_i }
    @sett_holidays = Fintypes::SETTLEMENT_HOLIDAYS.map { |x| SelextDate.crunch(x).to_i }
    @biz_holidays  = Fintypes::BUSINESS_HOLIDAYS.map { |x| SelextDate.crunch(x).to_i }

  end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# Fintypes.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!


# ------------------------------------------------------------------------------

def self.inject_bank_holidays(bank_holiday_array)
  @bank_holidays = bank_holiday_array
end

def self.inject_sett_holidays(sett_holiday_array)
  @sett_holidays = sett_holiday_array
end

def self.inject_biz_holidays(biz_holiday_array)
  @biz_holidays = biz_holiday_array
end

def self.inject_proc_holidays(proc_holiday_array)
  @proc_holidays = proc_holiday_array
end

# ------------------------------------------------------------------------------
private

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
  

end # module
