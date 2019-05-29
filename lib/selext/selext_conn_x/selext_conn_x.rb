module SelextConnX

# ------------------------------------------------------------------------------
# Small convenience utility for loading and connecting to SuT's via http
# This is really just a thin wrapper around an http connection library
# (our default is httparty) - but that can be replaced easily.
# 
# The target parameters are mapped via config/service_map.yaml.
#
# There is an environment variable (SELEXTCONNX_DEFAULT_SERVICE) which maps
# the default service from that service_map.yaml file for the current session;
# it can be specified/overridden at connection time...
#
# The internal programming api for this is the SelextConnX.* methods stored in 
# the selext_conn_x/selext_conn_x_http.rb file ... typical rest verbs are used ...
#
# Connections can be closed/reloaded/reopened if need be ... we're using 
# the concurrent ruby library to handle multi-threading friendly data structures.
# 
# ------------------------------------------------------------------------------

extend self

# ------------------------------------------------------------------------------
# Define Variables

  attr_accessor     :initmode           # flag if called already

# selext_conn_x synchronous data structures (all hashes are string-keyed)

  attr_accessor     :services           # hash of services; each element is a hash

  attr_accessor     :connections        # hash of connections to synchronous (http) services

# selext_conn_x sql query api calls to SUT

  attr_accessor     :sutdb
  attr_accessor     :current_database_tag
  attr_accessor     :sql_logger

# ------------------------------------------------------------------------------

def initialize!

  return if @initmode == 'initialized'

# ------------------------------------------------------------------------------
# load the service map;  note that the actual connections are lazy-loaded on
# first call ...

  SelextConnX.load_selextconnx_service_map!

# ------------------------------------------------------------------------------
# require the synch http service

  require_relative 'selext_conn_x_http.rb'
 
# ------------------------------------------------------------------------------
# require the sql db service to the remote SUT -- 
# NOTE: only requires file, does NOT connect now - it is a lazy-load so only
# need to connect when need it (generally this is NOT needed in most of our system)
#
  require_relative 'selext_conn_x_sql.rb'
  require_relative 'selext_conn_x_sql_logger.rb'

  @current_database_tag = nil
  
  @sql_logger = SelextConnX::SqlLogger.new

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# SelextConnX.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# allow selextconnx to reload its service map and refresh connections without
# having to bounce app

def self.reset_selextconnx!

  # close any connections

  @connections.each_pair do |key, conn|

    if conn != nil 
      conn[0].reset_all
    end

    @connections.delete(key)
    
  end

  # reload

  @connections = ::Concurrent::Map.new

  SelextConnX.load_selextconnx_service_map!

end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

private

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# load service map from config file ... this is an interface routine which
# bridges config variables into selextconnx

def self.load_selextconnx_service_map!

  # in future we might want to support different map files based on what we're 
  # running tests against ... use a var here and load right after ... 

  map_file = Selext.configroot('service_map.yaml')

  unless File.exists?(map_file)
    raise StandardError, "Missing SelextConnX mapping file :  #{map_file}"
  end

  # now load it from the config_file

  @services     = ::Concurrent::Map.new
  @connections  = ::Concurrent::Map.new

  hash = YAML.load_file(map_file)

  if hash.has_key?('services')

    hash['services'].each_pair do |k,element|
      @services.put_if_absent(k.to_sym,element)
      @connections.put_if_absent(k.to_sym, nil)
    end

  end

end


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

class SelextConnXError
  attr_accessor :body
  attr_accessor :status
end  


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

end # module
