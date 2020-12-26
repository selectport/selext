require 'git'
require 'fileutils'

module Selext

# a set of helper routines available to relprocs rake file in a project
# tree.   
#
# aids in readying and publishing a release candidate following the standard
# develop->release->main git branching workflow model
#
# class consists of a primary entry method (called by rake task) : 
#
#
#   express_release - which takes the release branch and merges it into the main
#                     branch, tags it, and pushes it to main/origin - which 
#                     normally will then trigger the cicd builds
#
# note that there is extensive 'environment' checking done so that the rules
# must be followed or this will terminate!

class ReleaseManagement

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def self.express_release

  # express release is a special purpose, combined ready + publish release
  # process ... in the normal process, there needs to be a distinct delay
  # between readying a release and publishing the release to allow for any
  # commit conflict resolution.  However, when merging a set of feature releases
  # into 'develop' with no conflicts, an express_release can be employed which
  # does everything in 1 task.
  #
  # pre-requisites are pretty much the same as the 2 individual release tasks :
  #
  # 1. You must be on develop branch
  # 2. Develop branch must have had all feature releases subs merged into it cleanly
  #    already.  This includes all relprocs in the next_release directory
  # 3. Should not be any reason that develop->main should yield any conflicts
  #    (which is the normal expectation unless release flow has been violated!)


  # for the first step, we just invoke the make_ready method

  puts " "
  puts "Express Releasing ..."

  Selext::ReleaseManagement.make_ready

  # for the publish step, we basically are automating the list of steps
  # in the publish_release

  active_version = self.get_active_release_version


  # precompile assets 

  if Dir.exist?(Selext.approot('assets'))

    cmd = 'RAILS_ENV=production rake assets:clean && ' + 
          'RAILS_ENV=production rake assets:precompile'
          
    retsts = `#{cmd}`
      raise StandardError, "Fatal asset compiling tasks" unless $?.exitstatus == 0

  end

  # we only can ready from a clean release branch - but we've got
  # our version bump and (any) relprocs that moved which need to be checked in
  # and committed... do that first

    cmd = 'git add --all'
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... checked in any relprocs and the version bump"
    puts " "

  # and commit them

    cmd = "git commit -m 'commit of version bump and relprocs for #{active_version}'"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... and committed to release branch"
    puts " "
  

  assert self.ensure_on_release_branch(active_version),
         self.billboard("Source Tree must be on #{active_version} branch")

  # and that release branch must have no 'pending' commits

  assert self.ensure_clean_branch,
         self.billboard("Release branch must have no uncommitted/untracked activity")

  # now we'll checkout main so we operate next set of steps from there
    
    puts " "
    puts "Release #{active_version} is ready for publishing."
    
    git_repo = Git.open('.')
    git_repo.branch('main').checkout

    puts " "
    puts "... Checked out branch main"
    puts " "


  # Merge branch release_#{active_version} into local main"

    cmd = "git merge --no-ff release_#{active_version} -m 'publishing release_#{active_version}'"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... merged release_#{active_version} into main"
    puts " "


  # Tag main release with version stamp

    cmd = "git tag -a #{active_version} -m #{active_version}" 
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... tagged release as #{active_version} in main"
    puts " "


  # Push main to origin

    cmd = "git push origin main --tags"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... pushed main to remote origin repository"
    puts " "

  # now cleanup develop branch

  # Bring develop branch up to speed with release artifacts

    cmd = "git checkout develop"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... checked out develop to bring it back up to speed with release"
    puts " "

  # merge in the release branch

    cmd = "git merge --no-ff release_#{active_version} -m 'retrofitting release_#{active_version}'"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... merge release bumps back to develop"
    puts " "

  # and delete the release branch to finish up

    cmd = "git branch -d release_#{active_version}"
    retsts = `#{cmd}`
      raise StandardError, "Fatal subprocess return status" unless $?.exitstatus == 0

    puts " "
    puts "... cleanup deleted release branch release_#{active_version}"
    puts " "    

  # all done !

    puts "All done !"

end



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# helper routines

private

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

def self.make_ready

  # we only can ready from a clean develop branch

  assert self.ensure_on_develop_branch, 
         self.billboard("Source Tree must be on 'develop' branch")

  # and develop must have nothing 'pending' commits

  assert self.ensure_clean_branch,
         self.billboard("Develop branch must have no uncommitted/untracked activity")

  # the current release naming convention is yy.mm.nnnn;  
  # we want to assign the new release branch name according to the current
  # date;  bumping minor if year/month are still valid;  bumping year and/or
  # month automatically if either is rolling

  # determine what we need to bump and calc the new version number
  # but don't bump it yet - we want to do that after we've created the release
  # branch !

      newver = self.bump_version(Selext.app_version)

  # create a new release branch from develop, name it release_{newver} and check it out

      git_repo = Git.open('.')

      new_branch = "release_#{newver}"
      
      git_repo.branch(new_branch).checkout


  #                   <<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
  #                   < now operating in release branch >
  #                   <<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>

  # now commit/write the new version calc'd above

      self.write_version(newver)

  # and update Selext.app_version

      Selext.app_version = newver


  # and we're done ... release created, numbered, and ready for last minute
  # touchups ...

  puts "... bumped version to #{newver} and created and checked out branch #{new_branch}"

end


# ------------------------------------------------------------------------------

def self.ensure_on_develop_branch

  gitrepo = Git.open('.')
  cur_branch = gitrepo.current_branch
  cur_branch == 'develop' ? ok = true : ok = false
  ok

end

# ------------------------------------------------------------------------------

def self.ensure_clean_branch

  gitrepo = Git.open('.')


  opencount = gitrepo.status.changed.count + 
              gitrepo.status.added.count   +
              gitrepo.status.deleted.count +
              gitrepo.status.untracked.count

  opencount == 0 ? ok = true : ok = false

  if opencount != 0
    puts "changed   : #{gitrepo.status.changed.count}"
    puts "added     : #{gitrepo.status.added.count}"
    puts "deleted   : #{gitrepo.status.deleted.count}"
    puts "untracked : #{gitrepo.status.untracked.count}"
  end
  
  ok

end

# ------------------------------------------------------------------------------

def self.ensure_on_release_branch(active_version)

  gitrepo = Git.open('.')
  cur_branch = gitrepo.current_branch
  cur_branch == "release_#{active_version}" ? ok = true : ok = false
  ok

end

# ------------------------------------------------------------------------------

def self.billboard(msg)
  return "\n\n" + "Fatal Error - abending" + "\n" + msg + "\n\n"
end

# ------------------------------------------------------------------------------

def self.get_active_release_version
  
  vFilename  = Selext.homeroot("cicd","Version")
  ovFile     = File.open(vFilename,'r')
  curline    = ovFile.readline

  active_version = curline.strip
  
  return active_version

end

# ==============================================================================
# auto version assigner - bump_version 
# ==============================================================================

# looks at current version vs current date/time and bumps either year, month,
# release as needed ...  versions are in form v.yy.mm.iii where yy=last 2 of year;
# mm = ordinal of month; and iiii is a 1-based serial number within the month/year
# this is not strict semantic versioning.

# current_app_version is Selext.app_version (eg. v17.04.0001)
# current_year and current_month are ints - eg. 17, 05  (can inject for testing)

# does NOT write files - since this is called pre-release ... caller is 
# responsible for write-backs to the 2 files (by calling write_version)


def self.bump_version(current_app_version, current_year=nil, current_month=nil)

  tagged_app_version = Selext.app_version

  today = Date.today

  if current_year.nil?
    current_year = today.year % 2000
  end

  current_year = current_year % 2000 if current_year > 2000

  if current_month.nil?
    current_month = today.month
  end

  unless current_month >= 1 && current_month <= 12
    raise StandardError, "Invalid current_month : #{current_month}"
  end

  ver_year  = current_app_version[1,2].to_i
  ver_month = current_app_version[4,2].to_i
  ver_minor = current_app_version[7,4].to_i

  i_new_minor = ver_minor += 1
  i_new_minor = 1 if current_year  != ver_year
  i_new_minor = 1 if current_month != ver_month

  new_year    = sprintf('%02d', current_year)
  new_month   = sprintf('%02d', current_month)
  new_minor   = sprintf('%04d', i_new_minor)

  new_version = "v#{new_year}.#{new_month}.#{new_minor}"

  # failsafe edit - new_version cannot be < tagged_app_version (manually edit file to adjust)

  if new_version < tagged_app_version
    raise StandardError, "New version cannot be less than current app version"
  end

  return new_version

end



# ==============================================================================
# version_string eg. v17.06.0001
# write to history file @cicd/application.version AND to 
# @cicd/Version

def self.write_version(version_string)

  # set old and current file names
  
  old_vFilename = Selext.homeroot("cicd","application.version_old")
  vFilename     = Selext.homeroot("cicd","application.version")
  
  # copy current -> old
  
  FileUtils.cp(vFilename, old_vFilename)
  
  # open up the old file
  
  ovFile = File.open(old_vFilename,'r')

  # open new version of file
  
  vFile = File.open(vFilename, 'w')

  # setup newline

  timestamp = SelextText.display_timestamp(Time.now.localtime)
  timezone  = Time.now.localtime.zone

  newline = "VERSION: #{version_string.strip}  INITIALIZED: #{timestamp} - #{timezone}"

  # push newline as new line 1 
  vFile.puts(newline)  # push new version
  
  # billboard
  
  puts "Bumping version to : #{newline}"

  # now read/write old -> new
  
  ovFile.each do |inline|  # cursor s/b on rec 1
    vFile.puts inline.strip!
  end
  
  # close files
  
  vFile.close
  ovFile.close

  FileUtils.rm(old_vFilename)

  # write it to the cicd marker file, too

  fn = Selext.homeroot('cicd', 'Version')

  f = File.open(fn,'w')
  f.puts version_string.strip
  f.close

end

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

end  # class
end  # module
