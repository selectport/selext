require Selext.applib('app_utils','credentials.rb')

module MeshServices

extend self

# ------------------------------------------------------------------------------
# Small convenience utility for loading and connecting to the other services 
# in our internal service mesh.
#
# This is really just a thin wrapper around an http connection library
# 
# The target parameters are mapped via config/service_mesh_map.yaml.
#
# Note that there is a different one for development machines than from
# production ... make sure you have the correct version named service_mesh_map.yaml
# for your current working/production environment.
#
# The internal programming api for this is the MeshServices.* methods stored in 
# the mesh_services/mesh_services_http.rb file ... typical rest verbs are used ...
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

  attr_accessor     :mesh_api_token     # token from credentials

# ------------------------------------------------------------------------------

def initialize!

  return if @initmode == 'initialized'

# ------------------------------------------------------------------------------
# load the mesh_api_token from encrypted credentials file

  @mesh_api_token = ::AppUtils::Credentials.fetch_credentials(:mesh_api_token)

# ------------------------------------------------------------------------------
# load the service map;  note that the actual connections are lazy-loaded on
# first call ...

  MeshServices.load_mesh_services_service_map!

# ------------------------------------------------------------------------------
# require the synchronous http service

  require_relative 'mesh_services_http.rb'
 
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# MeshServices.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# allow meshservices to reload its service map and refresh connections without
# having to bounce app

def self.reset_meshservices!

  # close any connections

  @connections.each_pair do |key, conn|

    if conn != nil 
      conn[0].reset_all
    end

    @connections.delete(key)
    
  end

  # reload

  @connections = ::Concurrent::Map.new

  MeshServices.load_mesh_services_service_map!

end


# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

private

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# load service map from config file ... this is an interface routine which
# bridges config variables into MeshServices

def self.load_mesh_services_service_map!

  # in future we might want to support different map files based on what we're 
  # running tests against ... use a var here and load right after ... 

  if Selext.deployment_type == 'local'
    map_file = Selext.customizers('service_mesh_map.yaml')
  else
    map_file = Selext.customizers('service_mesh_map_prod.yaml')
  end
  

  unless File.exists?(map_file)
    raise StandardError, "Missing MeshServices mapping file :  #{map_file}"
  end

  # now load it from the config_file

  @services     = ::Concurrent::Map.new
  @connections  = ::Concurrent::Map.new

  hash = YAML.load_file(map_file)

  if hash.has_key?('mesh_services')

    hash['mesh_services'].each_pair do |k,element|
      @services.put_if_absent(k.to_sym,element)
      @connections.put_if_absent(k.to_sym, nil)
    end

  end

end


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

class MeshServicesError
  attr_accessor :body
  attr_accessor :status
end  


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

end # module
