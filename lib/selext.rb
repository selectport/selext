module Selext

extend self

  attr_accessor     :initmode                     # flag if called already

  # required parameter to initialize!

  attr_accessor     :run_mode                     # symbolized mode we're running in
                                                  # selext runs in 1 of ? modes : 
                                                  # - :standalone - console, jobs, poros 
                                                  #                 ie. anything non-full rails
                                                  # - :in_rails   - running inside a ui server

  # these 4 MUST be defined in the enviornment variables

  attr_accessor     :environment                  # development, test, production
  attr_accessor     :root_directory               # top level project directory
  attr_accessor     :database_support             # Y=include database support;
                                                  # anything else=no database required
  attr_accessor     :local_time_zone              # eg. 'Arizona'



  # optional env variables can set these

  attr_accessor     :deployment_type              # local, server, docker

  # convenience accessors set within

  attr_accessor     :short_env                    # dev, test, prod 
  attr_accessor     :project_directory            # app level project directory
  attr_accessor     :home                         # project_directory
  attr_accessor     :tz                           # local_time_zone alias

  attr_accessor     :logger                       # Selext::Logger instance
  attr_accessor     :log_level                    # current #.logger level set
                                                  # Levels = {
                                                  # :fatal => 4,
                                                  # :error => 3,
                                                  # :warn  => 2,
                                                  # :info  => 1,
                                                  # :debug => 0}

  attr_accessor     :app_version                  # current app's version
  
  attr_accessor     :persisted_models_list        # array of physically persisted models
  attr_accessor     :all_models_list              # array of all (phys/virt) models

  # if database access is being used, set these in env

  attr_accessor     :databases                    # array of database configs from yaml
  attr_accessor     :database_info                # single entry from databases for this env
  attr_accessor     :database_name                # resolved database name for env/yaml
  attr_accessor     :database_root                # database root name from env
  attr_accessor     :database_user                # database user from env
  attr_accessor     :database_super_user          # database super_user from env
  attr_accessor     :database_password            # database password from env
  attr_accessor     :database_host                # database host from env
  attr_accessor     :database_port                # database port from env 

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def initialize!(run_mode: nil)

  return if @initmode == 'initialized'

  unless @initmode.nil?
    raise StandardError, "Warning:  Selext abended during init mode!"
  end

 # set inflight initmode to signify we started it before

  @initmode = 'inflight'

# ------------------------------------------------------------------------------
# load the class decorators

  require_relative './selext/decorators/selext_mash.rb'
  require_relative './selext/decorators/selext_dates.rb'
  require_relative './selext/decorators/selext_text.rb'

# blank duplicates functionality in active_support
# except for defining a not_blank? method on object;
# we determine if we're in rails (as a proxy for active_support)
# and if so call a very limited version of selext_blank (only
# defining the missing not_blank? method);  otherwise, we pull
# in the full selext_blank class

  if defined?(Rails.root)
    require_relative './selext/decorators/blank_rails'
  else
    require_relative './selext/decorators/blank'
  end

  require_relative './selext/decorators/boolean.rb'
  require_relative './selext/decorators/hash.rb'
  require_relative './selext/decorators/jsonify.rb'
  require_relative './selext/decorators/masherize.rb'
  require_relative './selext/decorators/time.rb'
  require_relative './selext/decorators/selext_ckdigit.rb'
  
# ------------------------------------------------------------------------------
# load fintypes

# fintypes provides rounding, nice formatting of numbers, and some
# concepts of business days, bank days, settlement days, and processing days

  require_relative './fintypes.rb'
  ::Fintypes.initialize!

# --------------------------------------------------------------------------
  # note: that root directory and environment are the only bootstrapped 
  # environment variables required outside of our config ...

  @environment = ENV.fetch('SELEXT_ENVIRONMENT')
  @root_directory = ENV.fetch('SELEXT_PROJECT_ROOT')

  # set a short-form environment eg. dev, test, prod

  @short_env = nil
  @short_env = 'dev'  if @environment == 'development'
  @short_env = 'test' if @environment == 'test'
  @short_env = 'prod' if @environment == 'production'
    raise StandardError, "Unassigned short_env for #{@environment}" if @short_env.nil?



# pickup deployment_type
# defaults to local, can be docker if running in a docker container or server
# if running in a regular installation;  this will primarily govern which
# config files (env, mesh, etc.) to load from when only real diff is where it
# runs

  @deployment_type = 'local'

  @deployment_type = 'docker'  if ENV['SELEXT_DEPLOYMENT'] == 'docker'
  @deployment_type = 'server'  if ENV['SELEXT_DEPLOYMENT'] == 'server'


  @project_directory = ENV['SELEXT_PROJECT_DIRECTORY'].to_s
  @project_directory = @root_directory if @project_directory.blank?
  @home              = @project_directory

# must set local_time_zone

  @local_time_zone   = ENV.fetch('SELEXT_LOCAL_TIME_ZONE')
  @tz                = @local_time_zone

# ------------------------------------------------------------------------------
# set @run_mode
#
#   run_mode is either :
#     :standalone (poros, jobs, etc) 
#     :in_rails   (running in a rails ui server)

  @run_mode = nil

  case 

  when run_mode.blank?
    raise StandardError, "Missing run_mode for Selext.initialize!"

  when run_mode.to_s.downcase == 'standalone'
    @run_mode       = :standalone               # console mode 

  when run_mode.to_s.downcase == 'in_rails'     # rails ui only server
    @run_mode       = :in_rails

  when run_mode.to_s.downcase

  else
    raise StandardError, "Invalid run mode specified : #{run_mode}"

  end
  
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# setup databases environment from ENV and config

  @databases              = SelextMash.new

  @database_root          = nil
  @database_user          = nil
  @database_super_user    = nil
  @database_password      = nil
  @database_host          = nil
  @database_port          = nil
  @database_name          = nil
  @database_info          = nil
  
  @database_support       = ENV.fetch('SELEXT_DATABASE_SUPPORT')

  if @database_support == 'Y'

    @database_host          = ENV.fetch('SELEXT_DATABASE_HOST')
    @database_port          = ENV.fetch('SELEXT_DATABASE_PORT')
    @database_name          = ENV.fetch('SELEXT_DATABASE_NAME')

    # note : these may be overridden via credentials when connecting below

    @database_root          = ENV.fetch('SELEXT_DATABASE_ROOT')
    @database_password      = ENV.fetch('SELEXT_DATABASE_PASSWORD')
    @database_user          = ENV.fetch('SELEXT_DATABASE_USER')
    @database_super_user    = ENV.fetch('SELEXT_DATABASE_SUPER_USER')
    @database_info          = ENV.fetch('SELEXT_DATABASE_INFO')

  end

# ------------------------------------------------------------------------------
# load and define our core helpers;
# one of the primary benefits of Selext is it allows us to code to logical names
# using core helpers ... this sets them all up

  require_relative './selext/lib/define_core_helpers.rb'
  require_relative './selext/lib/errors.rb'

# ------------------------------------------------------------------------------
# setup bundler and require the gems for the run_mode and environment context
# we're running in;  rails calls this, so we only need to do it in standalone
# and server modes

  unless @run_mode == :in_rails
    
    require 'rubygems'
    require 'bundler'
    Bundler.setup
    Bundler.require(:default, :standalone, @environment.to_sym)

  end

# ------------------------------------------------------------------------------
# Set up the models lists :
#
#  persisted_models_list lets us know which models have a physical backing; used heavily
#  in the dbase rake tasks, ensure tables, etc. meta level;  only loads the arrays
#  here ...
#
#  models_list lets us know all the models that the selext application tree
#  knows about;  

  @persisted_models_list = []

  global_file = Selext.configroot('selext_models_list.rb')
  
    unless File.exist?(global_file)
        raise StandardError, 
              "Selext Global Model List configuration not located at #{global_file}"
    end

  require global_file

  Selext.persisted_models_list = Selext.set_persisted_models_list
  Selext.all_models_list       = Selext.set_all_models_list

# ------------------------------------------------------------------------------
# require logger and set log levels;  default to stdout unless LOG_OUTPUT is set

  require_relative './selext/lib/selext_logger.rb'

  if Selext.deployment_type == 'docker'
    fd = IO.sysopen("/proc/1/fd/1","w")
    io = IO.new(fd,"w")
    io.sync = true
  else

    if ENV['LOG_OUTPUT']
      io = ENV['LOG_OUTPUT']
    else
      io = $stdout
    end

  end

  @logger = Selext::Logger.new(io)

  level = ENV['LOG_LEVEL'] || "info"    # default if not set

  @log_level = Selext::Logger::LEVELS[level.to_sym]
  Selext.logger.level = @log_level

# ------------------------------------------------------------------------------
# small collection of utility routines

  require_relative './selext/lib/selext_utils.rb'

# ------------------------------------------------------------------------------
# require/define Selext.get_app_version which can be used to load the application
# version by reading the cicd/Version in the containing application; note that
# this is then called to assign to Selext.app_version ivar so it is availalble
# everywhere as Selext.app_version

  require_relative './selext/lib/get_app_version.rb'

  @app_version = Selext.get_app_version 
   
# ------------------------------------------------------------------------------
# set database name from root + environment & connect AR

  require 'active_record'
  
  require_relative './selext/lib/get_database_config.rb'
  Selext.get_database_config
    
  require_relative './selext/lib/connect_database_ar.rb'

  unless @run_mode == :in_rails
    Selext.connect_database_ar
  end

# ------------------------------------------------------------------------------
# require all our base classes from selext_base/

  require_relative "./selext/base_classes/selext_form.rb"
  
# --------------------------------------------------------------------------
# require all model files

  require_relative './selext/lib/require_models.rb'

  unless @run_mode == :in_rails
    Selext.require_models
  end
  
# --------------------------------------------------------------------------
# require enums and validators

  require_relative './selext/lib/require_enums.rb'
  require_relative './selext/lib/require_validators.rb'

  Selext.require_enums
  Selext.require_validators
   
# --------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# Selext.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!


# ------------------------------------------------------------------------------ 
# ------------------------------------------------------------------------------ 

end # module

