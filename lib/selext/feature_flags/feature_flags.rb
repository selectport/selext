module FeatureFlags

extend self


# ------------------------------------------------------------------------------
# Define Variables

  attr_accessor     :initmode           # flag if called already
  attr_accessor     :flag_defs

# ------------------------------------------------------------------------------

def initialize!

  return if @initmode == 'initialized' || @initmode == 'loaded'

  @flag_defs = ::Concurrent::Map.new

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# FeatureFlags.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!


# ------------------------------------------------------------------------------
# load_flag_defs reads global defs from the FeatureFlag table

def self.load_flag_defs

  @flag_defs.clear

  ::FeatureFlag.all.each do |flag|
    @flag_defs[flag.flag_idn] = {default_value: flag.default_value}
  end

  @initmode = 'loaded'

end # method

# ------------------------------------------------------------------------------

def self.is_feature_enabled?(company_idn, flag_idn)

  keyflag = flag_idn.to_s

  flag = ::FeatureFlagCompany.where(company_idn:   company_idn,
                                    flag_idn:      keyflag).first

  if flag

    return flag.value

  else

    unless @initmode == 'loaded'
      self.load_flag_defs
    end

    if @flag_defs.keys.include?(keyflag)
      return @flag_defs[keyflag][:default_value]
    else
      return nil
    end

  end

end

# ------------------------------------------------------------------------------

def self.default_value_for_flag(flag_idn)

  flag = ::FeatureFlag.where(flag_idn: flag_idn).first

  unless flag
    raise Selext::Errors::ProgrammingError, "Invalid FeatureFlag idn : #{flag_idn}"
  end

  return flag.default_value

end

# ------------------------------------------------------------------------------

end # module
