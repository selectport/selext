require 'yaml'
require 'erb'

# note that this fetcher is usable only with ActiveRecord

module Selext

  def self.get_database_config

    # load our dbconfigurations from database.yml

    dbconfig_file = Selext.configroot('database.yml')
    dbconfig = YAML::load(ERB.new(IO.read(dbconfig_file)).result)

    dbconfig.each do |k,v|

      Selext.databases[k.to_s] = v
      
    end

    # And set the current database name for our environment

    Selext.database_name     = Selext.databases[Selext.environment.to_sym][:database]
    Selext.database_host     = Selext.databases[Selext.environment.to_sym][:host]
    Selext.database_port     = Selext.databases[Selext.environment.to_sym][:port]
    Selext.database_user     = Selext.databases[Selext.environment.to_sym][:username]
    Selext.database_password = Selext.databases[Selext.environment.to_sym][:password]

  end  # method

end  # module
