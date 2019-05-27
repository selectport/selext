require 'yaml'
require 'erb'

# due to the way that sequel likes using a top-level global constant DB
# and that we have to connect our database before we load our models with Sequel,
# we don't actually connect the database here ... this just bridges the database
# configurations from database.yml into Selext.databases and Selext.database
# for callable reference.   

# note that this fetcher is usable with both AR and sequel

module Selext

  def self.get_sequel_database_config

    # load our dbconfigurations from database.yml

    dbconfig_file = Selext.configroot('database.yml')
    dbconfig = YAML::load(ERB.new(IO.read(dbconfig_file)).result)

    dbconfig.each do |k,v|

      Selext.databases[k.to_s] = v

    end

    # And set the current database name for our environment

    Selext.database_name = Selext.databases[Selext.environment.to_sym][:database]

  end  # method

end  # module
