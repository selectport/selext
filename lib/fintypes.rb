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

  @bank_holidays = []
  @proc_holidays = []
  @sett_holidays = []
  @bizn_holidays = []

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
