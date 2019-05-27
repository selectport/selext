module Selext

extend self

  attr_accessor     :initmode                     # flag if called already
  attr_accessor     :run_mode                     # symbolized mode we're running in
                                                  # selext runs in 1 of ? modes : 
                                                  # - :standalone - console, jobs, poros 
                                                  #                 ie. anything non-full rails
                                                  # - :replay     - running in special replay mode
                                                  # - :in_rails   - running inside a ui server
                                                  
  attr_accessor     :replay_mode                  # Y/N in_replay mode

  attr_accessor     :environment                  # development, test, production
  attr_accessor     :project_directory            # top level project directory
  attr_accessor     :home                         # project_directory

  attr_accessor     :deployment_type              # local, server, docker


  attr_accessor     :short_env                    # dev, test, prod 
  attr_accessor     :persisted_models_list        # array of physically persisted models
  attr_accessor     :all_models_list              # array of all (phys/virt) models

  attr_accessor     :app_version                  # current app's version

  attr_accessor     :logger                       # Selext::Logger instance
  attr_accessor     :log_level                    # current #.logger level set
                                                  # Levels = {
                                                  # :fatal => 4,
                                                  # :error => 3,
                                                  # :warn  => 2,
                                                  # :info  => 1,
                                                  # :debug => 0}

  attr_accessor     :databases                    # array of database configs from yaml
  attr_accessor     :database_info                # single entry from databases for this env
  attr_accessor     :database_name                # resolved database name for env/yaml
  attr_accessor     :database_root                # database root name from env
  attr_accessor     :database_user                # database user from env
  attr_accessor     :database_password            # database password from env
  attr_accessor     :database_host                # database host from env
  attr_accessor     :database_port                # database port from env
 
  attr_accessor     :tracer                       # activity tracer instance 
                                                  # or nil if no tracing

  attr_accessor     :is_tracing                   # true if tracer isn't null

  attr_accessor     :gem_dir                      # absolute path where this gem is installed

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def initialize!(run_mode: nil)

  return if @initmode == 'initialized'

  unless @initmode.nil?
    raise StandardError, "Warning:  Selext abended during init mode!"
  end

 # set inflight initmode to signify we started it before

  @initmode = 'inflight'

# --------------------------------------------------------------------------
# require SolidAssert and enable (before bundler does)

  require 'solid_assert'
  ::SolidAssert.enable_assertions

# ------------------------------------------------------------------------------
# load the class decorators

  require_relative './selext/decorators/selext_dates.rb'
  require_relative './selext/decorators/selext_mash.rb'
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
# set @run_mode
#
#   run_mode is either :
#     :standalone (poros, jobs, etc) 
#     :replay     (running in replay mode)
#     :in_rails   (running in a rails ui server)

  @run_mode = nil

  case 

  when run_mode.blank?
    raise StandardError, "Missing run_mode for Selext.initialize!"

  when run_mode.to_s.downcase == 'standalone'
    @run_mode       = :standalone               # console mode 
    @replay_mode    = "N"

  when run_mode.to_s.downcase == 'in_rails'     # rails ui only server
    @run_mode       = :in_rails
    @replay_mode    = "N"

  else
    raise StandardError, "Invalid run mode specified : #{run_mode}"

  end
  
# --------------------------------------------------------------------------
  # note: that root directory and environments are the only bootstrapped 
  # environment variables required outside of our config ...

  @environment = ENV.fetch('SELEXT_ENVIRONMENT')

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

# ------------------------------------------------------------------------------
# SELEXT_PROJECT_DIRECTORY points at the root of this components directory tree

  @project_directory = ENV['SELEXT_PROJECT_DIRECTORY'].to_s
  @home = @project_directory


# ------------------------------------------------------------------------------
# affix this gem's install directory 
  
  @gem_dir = File.dirname(File.expand_path(File.join(__FILE__,'./../')))
  
# ------------------------------------------------------------------------------
# setup databases environment from ENV and config

  @databases              = SelextMash.new

  @database_root          = nil
  @database_user          = nil
  @database_password      = nil
  @database_host          = nil
  @database_port          = nil
  
  @database_root          = ENV.fetch('SELEXT_DATABASE_ROOT')
  @database_password      = ENV.fetch('SELEXT_DATABASE_PASSWORD')
  @database_host          = ENV.fetch('SELEXT_DATABASE_HOST')
  @database_port          = ENV.fetch('SELEXT_DATABASE_PORT')
 

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

# # ------------------------------------------------------------------------------
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
# setup tracing if requested via env variable

  require_relative './selext/lib/tracer.rb'

  @is_tracing = ENV['SELEXT_TRACE_ACTIVITY'] || 'N'

  if @is_tracing == 'N'
      @tracer = TracerLogger.new(:NULL)
  else
      @tracer = TracerLogger.new(Selext.logroot('activity_tracer.log'))
  end

# ------------------------------------------------------------------------------
# require/define Selext.get_app_version which can be used to load the application
# version by reading the cicd/Version in the containing application; note that
# this is then called to assign to Selext.app_version ivar so it is availalble
# everywhere as Selext.app_version

  require_relative './selext/lib/get_app_version.rb'

  @app_version = Selext.get_app_version 
 
# ------------------------------------------------------------------------------
# small collection of utility routines

  require_relative './selext/lib/utils.rb'
  require_relative './selext/lib/message_serializer.rb'
 
# ------------------------------------------------------------------------------
# set database name from root + environment

  require 'sequel'

  require_relative './selext/lib/get_sequel_database_config.rb'
  Selext.get_sequel_database_config

# ------------------------------------------------------------------------------
# connect sequel database to global ::DB variable

  require_relative './selext/lib/connect_sequel.rb'

# ------------------------------------------------------------------------------
# connect Que

  Que.connection = DB
  
# ------------------------------------------------------------------------------
# require all our base classes from selext_base/

  require_relative "./selext/base_classes/origin_context.rb"
  require_relative "./selext/base_classes/queued_job.rb"
  require_relative "./selext/base_classes/que_queued_job.rb"
  require_relative "./selext/base_classes/selext_form.rb"
  require_relative "./selext/base_classes/selext_handler_retsts.rb"
  require_relative "./selext/base_classes/selext_handler.rb"
  require_relative "./selext/base_classes/selext_request.rb"
  require_relative "./selext/base_classes/selext_response.rb"
  require_relative "./selext/base_classes/selext_job_stats.rb"
  require_relative "./selext/base_classes/selext_job_handler.rb"

# --------------------------------------------------------------------------
# require all model files

  require_relative './selext/lib/require_models.rb'

  Selext.require_models
  
# --------------------------------------------------------------------------
# require enums and validators

  require_relative './selext/lib/require_enums.rb'
  require_relative './selext/lib/require_validators.rb'

  Selext.require_enums
  Selext.require_validators

# --------------------------------------------------------------------------
# require app_utils if they exist

  if Dir.exist?(Selext.app_utils)
    Selext::Utils.require_glob(Selext.app_utils("**/*.rb"))
  end
  
# --------------------------------------------------------------------------
# --------------------------------------------------------------------------
# load and initialize SelextConnX for synchronous communication with our System
# Under Test (SUT)

  require_relative 'selext/selext_conn_x/selext_conn_x.rb'
  SelextConnX.initialize!


# --------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# all done ! - flip initmode - won't be rerun if accidentally called
# Selext.initialize! more than once.

  @initmode = 'initialized'

end  # initialize!

# ------------------------------------------------------------------------------
# define a convenient boolean method
  
  def self.tracing?
    @is_tracing == 'Y' ? true : false
  end

# ------------------------------------------------------------------------------
private


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

end # module
