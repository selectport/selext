require_relative './helperlib/selext_relprocs_helpers.rb'
require 'erb'

# File : selext_relproc.rake (rake tasks to run release procedures on a deployment)


namespace 'relprocs' do


# ----------------------------------------------------------------------------------------------------------------
# if we're calling thru rails environment, :environment task will already be defined in a railsy-way ... skip here
# otherwise, we just define a blank environment since our tasks depend on it...

 unless Rake::Task.task_defined?(:environment)  

  task :environment do 

  end

 end

# ----------------------------------------------------------------------------------------------------------------

  # note - only need to run this 1x to initialize a database's applied_relprocs.data file ... but it won't
  # harm anything if it gets run more than 1x (ie. it's idempotent)

  desc "Initialize Relprocs DataFile"
  task :initializeDatafiles => :environment do

    SelextDeployer::Relprocs.initialize_datafiles
    
  end 

# ----------------------------------------------------------------------------------------------------------------

  desc "Run release procedures for current environment, current database, current version"
  task :runReleaseProcs => :environment do

    SelextDeployer::Relprocs.perform_relprocs(Selext.app_version)

  end

# ----------------------------------------------------------------------------------------------------------------

  desc "List Pending release procedures needed for this database"
  task :listPendingReleaseProcs => :environment do

    SelextDeployer::Relprocs.list_pending_relprocs(Selext.app_version)

  end

# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------

end  # namespace relprocs
