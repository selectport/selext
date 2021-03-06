module Selext

# ------------------------------------------------------------------------------

  def Selext.homeroot(*args)    # {project_directory}
    File.expand_path(File.join(Selext.home, *args))
  end

  def Selext.api_contracts(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'apis', 'contracts', *args))
  end

  def Selext.api_adapters(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'apis', 'adapters', *args))
  end

  def Selext.api_handlers(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'apis', 'handlers', *args))
  end

  def Selext.approot(*args)     # {project_directory}/app
    File.expand_path(File.join(Selext.home, 'app', *args))
  end

  def Selext.applib(*args)      # {project_directory}/app/lib
    File.expand_path(File.join(Selext.home, 'app', 'lib', *args))
  end
  
  def Selext.app_utils(*args) 
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'app_utils', *args))
  end

  def Selext.baseroot(*args)    # {project_directory}/selextbase
    File.expand_path(File.join(Selext.home, 'selextbase', *args))
  end

  def Selext.configroot(*args)  # {project_directory}/config
    File.expand_path(File.join(Selext.home, 'config', *args))
  end

  def Selext.commands(*args)
    File.expand_path(File.join(Selext.approot, 'services', 'commands', *args))
  end

  def Selext.command_cards(*args)
    File.expand_path(File.join(Selext.approot, 'command_cards', *args))
  end
 
  def Selext.contracts(*args)
    File.expand_path(File.join(Selext.applib, 'contracts', *args))
  end

  def Selext.customizers(*args)
    File.expand_path(File.join(Selext.homeroot, 'customizers', *args))
  end

  def Selext.dbroot(*args)
    File.expand_path(File.join(Selext.home, 'db', *args))
  end

  def Selext.dbaroot(*args)
    File.expand_path(File.join(Selext.home, 'selextbase', 'dba', *args))
  end 

  def Selext.enums(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'enums', *args))
  end

  def Selext.forms(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'forms', *args))
  end

  def Selext.homeroot(*args)
    File.expand_path(File.join(Selext.home, *args))
  end
    
  def Selext.job_cards(*args)
    File.expand_path(File.join(Selext.home, 'app', 'jobs', 'job_cards', *args))
  end

  def Selext.job_handlers(*args) 
    File.expand_path(File.join(Selext.home, 'app', 'jobs', 'job_handlers', *args))
  end

  def Selext.job_registry(*args)
    File.expand_path(File.join(Selext.home, 'app', 'jobs', 'job_registry', *args))
  end
  
  def Selext.jobsroot(*args)    # {project_directory}/app/jobs
    File.expand_path(File.join(Selext.home, 'app', 'jobs', *args))
  end

  def Selext.libroot(*args)     # {project_directory}/lib
    File.expand_path(File.join(Selext.home, 'lib', *args))
  end

  def Selext.logroot(*args)
    File.expand_path(File.join(Selext.home, 'log', *args))
  end  

  def Selext.mediators(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'mediators', *args))
  end

  def Selext.models(*args)      # {project_directory}/app/models
    File.expand_path(File.join(Selext.approot, 'models', *args))
  end

  def Selext.probes(*args)
    File.expand_path(File.join(Selext.approot, 'lib', 'probes', *args))
  end

  def Selext.queries(*args)
    File.expand_path(File.join(Selext.approot, 'services', 'queries', *args))
  end

  def Selext.routes(*args)
    File.expand_path(File.join(Selext.home, 'app', 'routes', *args))
  end

  def Selext.specroot(*args)
    File.expand_path(File.join(Selext.home, 'spec', *args))
  end

  def Selext.validators(*args)
    File.expand_path(File.join(Selext.home, 'app', 'lib', 'validators', *args))
  end


# ------------------------------------------------------------------------------

  def Selext.gemroot(*args)
    base_dir = File.expand_path('../../../', File.dirname(__FILE__) )
    File.expand_path(File.join(base_dir, *args))
  end

  def Selext.gemtasks(*args)
    File.expand_path(Selext.gemroot('lib', 'selext', 'raketasks', *args))
  end
  
# ------------------------------------------------------------------------------

  # convenience environment mappers

  def Selext.development?
    @environment == 'development' ? true : false
  end

  def Selext.test?
    @environment == 'test' ? true : false
  end

  def Selext.testing?
    @environment == 'test' ? true : false
  end

  def Selext.production?
    @environment == 'production' ? true : false
  end 

  def Selext.replaying?
    @replay_mode == "Y" ? true : false
  end

  def Selext.standalone?
    @run_mode == :standalone ? true : false
  end

  def Selext.stage?
    @stage == :stage ? true : false
  end

  def Selext.in_rails?
    @run_mode == :in_rails ? true : false
  end 

  # for reaching outside the project to the common inter-service drop zone

  def Selext.drop_zone(*args)
    File.expand_path(File.join(ENV['SELEXT_DROP_ZONE'], *args))
  end


  def Selext.current_time
    Time.now.localtime.in_time_zone('Arizona').iso8601
  end
 
  def Selext.current_time_tz
    Time.now.localtime.in_time_zone('Arizona')
  end

# ------------------------------------------------------------------------------
end # Selext module
