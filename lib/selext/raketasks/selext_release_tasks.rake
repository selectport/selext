require_relative './helperlib/express_release.rb'
require_relative './helperlib/install_release.rb'

require 'erb'

# File : selext_release.rake (rake tasks to cut a release from development branch)

namespace 'release' do

# ----------------------------------------------------------------------------------------------------------------
# if we're calling thru rails environment, :environment task will already be defined in a railsy-way ... skip here
# otherwise, we just define a blank environment since our tasks depend on it...

 unless Rake::Task.task_defined?(:environment)  

  task :environment do 

  end

 end

# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------
# ExpressRelease - special purpose combo for ready/release 
# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------

desc "express ready/publish a release candidate to central git repository"
task :expressRelease => [:environment] do

  Selext::ReleaseManagement.express_release

end




desc "installRelease[vyy.mm.nnnn,server_name] to server"
task :installRelease, [:version, :server_name] => :environment do |t, args|

  Selext::ReleaseManagement.install_release(args[:version], args[:server_name])

end

# ----------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------

end  # namespace relprocs
