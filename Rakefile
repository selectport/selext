$:.push File.expand_path("../lib", __FILE__)

require "rspec/core/rake_task"


task :default => :spec

# setup environment

task :env do

  puts "...in env"

  @basedir = File.absolute_path(File.dirname(__FILE__))  # where Rakefile is in gem dir
    
  @gem_name_base = File.basename(@basedir)

  require_relative './lib/selext/version.rb'
  
  @version = Selext.version

  puts "version is #{@version}"
  
  @build_gem_file_name = "#{@gem_name_base}-#{@version}.gem"
  @result_gem_file_name = File.expand_path(@build_gem_file_name)
  
  @pkg_gem_file = File.join(@basedir, "pkg", @build_gem_file_name)
  
end
  
# =====================================================================================

  desc "Test Gem"
  task :spec => [:env] do |t|

  RSpec::Core::RakeTask.new(:spec)
  
  end

# =====================================================================================

  desc "Build Gem"
  task :build => [:env] do |t|
    
    puts "...building"

    @pkgdir = File.join(@basedir, 'pkg')

    system("rm #{@pkgdir}/*.gem")
   
    cmd = 'ruby bin/bump_version.rb'
    raw_new_version = `#{cmd}`
    new_version = raw_new_version.chomp.strip

    system("git add-commit --author='Scott Eckenrode <scott@selectport.com>' -m 'bumped version to #{new_version}'")
    system("git push")
    
    cmd = "gem build -V #{@gem_name_base}.gemspec"  
    system(cmd)
    
    FileUtils.mkdir_p(@pkgdir)
     
    @build_gem_file_name  = "#{@gem_name_base}-#{new_version}.gem"
    @result_gem_file_name = File.expand_path(@build_gem_file_name)

    @pkg_gem_file = File.join(@basedir, "pkg", @build_gem_file_name)
     
    FileUtils.mv(@result_gem_file_name, 'pkg/')

  end
  
# =====================================================================================
  
  desc "Install Gem"
  task :install => [:env] do |t|
  
  puts "...installing"
         
  system("gem install --no-document  #{@pkg_gem_file}")
    
  end

  
   
# =====================================================================================

  desc "Rebuild Gem"
  task :rebuild => [:env, :build, :install] do |t|

  end

# =====================================================================================
