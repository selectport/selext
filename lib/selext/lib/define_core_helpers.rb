module Selext

# ------------------------------------------------------------------------------

  def Selext.homeroot(*args)    # {project_directory}
    File.expand_path(File.join(Selext.home, *args))
  end

  def Selext.approot(*args)     # {project_directory}/app
    File.expand_path(File.join(Selext.home, 'app', *args))
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
    File.expand_path(File.join(Selext.approot, 'commands', *args))
  end

  def Selext.command_cards(*args)
    File.expand_path(File.join(Selext.approot, 'command_cards', *args))
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
    File.expand_path(File.join(Selext.home, 'app', 'models', *args))
  end

  def Selext.probes(*args)
    File.expand_path(File.join(Selext.approot, 'probes', *args))
  end

  def Selext.protos(*args)
    File.expand_path(File.join(Selext.xtalk_root, 'xtalk', 'grpc', *args))
  end

  def Selext.queries(*args)
    File.expand_path(File.join(Selext.approot, 'queries', *args))
  end

  def Selext.registries(*args)
    File.expand_path(File.join(Selext.home, 'app', 'registries', *args))
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

  def Selext.in_rails?
    @run_mode == :in_rails ? true : false
  end 

  # for reaching into the gem's rake tasks

  def Selext.gemroot(*args)
    File.expand_path(File.join(Selext.gem_dir, *args))
  end

  def Selext.gemtasks(*args)
    File.expand_path(File.join(Selext.gem_dir, 'lib', 'selext', 'raketasks', *args))
  end

# ------------------------------------------------------------------------------
end # Selext module
