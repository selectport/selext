module SelextDeployer

class Relprocs

# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------
# This is the primary entry point for SelextDeployer::Relprocs
#
# It is passed a version number (generally, this will be the current version number
# for the application as determined by the selext_application.version file)

def self.perform_relprocs(for_version)

  puts "...performing release procedures for version #{for_version}"
  puts " "

  # get list of rel_procs that need to be run (this is total less ones already run)

  procs_to_run = self.todo_procs(for_version)

  unless procs_to_run.count == 0
    puts " "
    puts "================================================================================================="
    puts "================================================================================================="
    puts "                                   Selext Release Upgrade Procs                                  "
    puts "================================================================================================="
    puts "================================================================================================="
    puts "Current directory : #{Dir.pwd}"
    puts "Current version   : #{for_version}"
  end

  # pass each one and launch it

  procs_to_run.each do |proc|

    puts " "
    puts "-------------------------------------------------------------------------------------------------"
    puts "...starting #{proc}"
    puts " "
    self.execute_proc(proc)
    puts " "
    puts "...completed #{proc}"
    puts "-------------------------------------------------------------------------------------------------"

  end

  puts "================================================================================================="


end

# ---------------------------------------------------------------------------------
# This just lists the relprocs that would be run (dry run) if perform_relprocs was
# executed now ... it will return nothing ... but it prints to console the list of
# jobs.  (ie. prints results of .todo_procs)

def self.list_pending_relprocs(for_version)

  procs_to_run = self.todo_procs(for_version)

  unless procs_to_run.count == 0
    puts "Pending Release Procedures for Database - version #{for_version}"
    puts ""
  end

  procs_to_run.each do |proc|

    puts "requires #{proc}"

  end

end

# ---------------------------------------------------------------------------------
# set of helper routines below here
# ---------------------------------------------------------------------------------

def self.execute_proc(proc_file)

  # pick off the version, proc_id, and proc_type from the proc_file - which should
  # be a fully pathed file name

  version_id = self.version_id_from_file(proc_file) 
  proc_id    = self.proc_id_from_file(proc_file)
  proc_type  = self.proc_type_from_file(proc_file) 

  # execute the proc in proc_file - how we do that depends on the extension

  case
  when proc_type == 'rb'
    sub_status = system("bundle exec ruby #{proc_file}")
  when proc_type == 'sh'
    sub_status = system("sh #{proc_file}")
  else
    raise StandardError, "Unhandled release procedure file type - must be either sh or rb"
  end

  # now if it completed successfully, mark it complete

  if sub_status then

      puts " "
      puts "......#{proc_id} completed succesfully"
      self.mark_proc_complete(proc_id)

    else

      raise StandardError, "Release Process File #{proc_file} did not complete successfully"

    end

end  # execute_proc

# ------------------------------------------------------------------------------------------------------------

def self.initialize_datafiles

    # this will safely create the directory and then the file as needed; falls thru if already present

    unless Dir.exist?(Selext.dbroot) then
      Dir.mkdir(Selext.dbroot)
    end

    unless File.exist?(Selext.dbroot('applied_relprocs.data')) then
      outfile = File.open(Selext.dbroot('applied_relprocs.data'),'w')

      outfile.puts "# Release Proc Completed Jobs File" 
      outfile.puts "#" 

      outfile.close
    end

  end  # initialize_database

  # ----------------------------------------------------------------------------------------------------------

  def self.has_completed_proc?(proc_id)

      # returns true if proc_id is already in applied_relprocs.data; false otherwise
      # this is a proxy for knowing whether the relproc has already been run on this database

      # no file? --> false (ie)

      return false unless File.exist?(Selext.dbroot('applied_relprocs.data'))

      # open file and scan it

      infile = File.open(Selext.dbroot('applied_relprocs.data'),'r')

      flag = false

      infile.readlines.each do |l|

        lc = l.chomp
        flag = true if lc == proc_id

      end

      infile.close

      return flag

    end

  # ----------------------------------------------------------------------------------------------------------

  def self.todo_procs(version_id)

    # builds and returns an array of release procs to do
    # for version_id;  does this by scanning the release directory
    # looking for RP's and matching them against the release.db of
    # already completed procs

    # get a list of the RP files in the release directory

    filearry = Array.new

    filedir = File.join(Selext.homeroot('deployer', 'release_procs', "**/*RP*"))
  
    Dir.glob(filedir).each do |dn|
      
      d = File.basename(dn)

      if d[0,10] <= version_id[0,10] and
         d[10,3] == "-RP" then
           filearry << dn
       end

    end


    filearry.sort!


    # load the release database

    infile = File.open(Selext.dbroot('applied_relprocs.data'),'r')

    dbarry = Array.new

    infile.readlines.each do |l|

      lc = l.lstrip.chomp
      next if lc == ""
      next if lc[0,1] == '#'
      next if (lc[0,1] != 'v' and lc[0,1] != 'V')

      dbarry << lc

    end

    infile.close

    # compare the list to the database array and push a new
    # entry to retarry if needs to be run

    retarry = Array.new

    # note - we are comparing in file order since they will be
    # the correct order - the filearry isn't necessarily in that
    # order (there might have been intervening procs) - so we have
    # to this by hand

    filearry.each do |fn|

      f = File.basename(fn, File.extname(fn))
      retarry << fn if dbarry.find_index(f) == nil

    end


    # return the to-do array

    return retarry

  end  # todo_procs

  # ----------------------------------------------------------------------------------------------------------

    def self.mark_proc_complete(proc_id)

      # when proc_id has completed executing, call this to append it to the completed release data file
      
      # our score keeping system in purposefully simple : applied_relprocs.data contains a line with the
      # relproc proc_id (version-RPxx) in it ... relprocs works a little like migrations : when
      # the rake task runs, it looks for what relprocs are available for this release (in deployer/release_procs)
      # and then what items have been completed in applied_relparocs.data - and then runs the difference
      # tagged for this release version.   This gives you a very simple way to rerun - just edit and
      # remove that line from the applied_relprocs.data file.  
      #
      # Also, while not always possible, try to make the relprocs conform to a standard by making them 
      # (1) ruby scripts
      # (2) idempotent



      # this shouldn't be - but rather than abend, let's create the file so we 
      # can log job and not re-run it

      self.initialize_datafiles unless File.exist?(Selext.dbroot('applied_relprocs.data'))

      # just append the proc_id to the file

      outfile = File.open(Selext.dbroot('applied_relprocs.data'),'a')
        outfile.puts(proc_id)
      outfile.close

    end  # mark_proc_complete

  # ----------------------------------------------------------------------------------------------------------

  def self.proc_id_from_file(in_file)

    # convenience routine to return the proc_id from a file name
    # in_file is fully pathed rel_proc file name ... 
    # relevant part eg. deployer/release_procs/v12.00.000/v12.00.000-RP01.rb would return
    # v12.00.000-RP01 as the proc_id

    bn = File.basename(in_file, File.extname(in_file))

    version_id = bn[0,10]
    proc_id = bn

    return proc_id

  end # proc_id_from_file

  # ----------------------------------------------------------------------------------------------------------

  def self.version_id_from_file(in_file)

    # convenience routine to return the version_id from a file name
    # in_file is fully pathed rel_proc file name ... 
    # relevant part eg. deployer/release_procs/v12.00.000/v12.00.000-RP01.rb would return
    # v12.00.000 as the version_id

    bn = File.basename(in_file, File.extname(in_file))

    version_id = bn[0,10]

    return version_id

  end # version_id_from_file

  # ----------------------------------------------------------------------------------------------------------

  def self.proc_type_from_file(in_file)

    # convenience routine to return the proc_type (rb, sh) from a file name
    # in_file is fully pathed rel_proc file name ... 
    # relevant part eg. deployer/release_procs/v12.00.000/v12.00.000-RP01.rb would return
    # 'rb' as the proc_type;
    #
    # relevant part eb. deployer/release_procs/v12.00.000/v12.00.000-RP01.sh would return
    # 'sh' as the proc_type;
    #
    # right now we're only supporting these ... so we're defensively abending here in case we
    # encounter a relproc with either none, or a different extension (this because version numbers
    # include a "." in them)

    ext = File.extname(in_file)

    ret_ext = ""

    case
    when ext == ".rb"
      ret_ext = "rb"
    when ext == ".sh"
      ret_ext = "sh"
    else
      raise StandardError, "Invalid extension for release procedure .. must be either rb or sh"
    end

    return ret_ext

  end # version_id_from_file

  # 
  # ----------------------------------------------------------------------------------------------------------


end  # class Relprocs

end  # moduleSelextDeployer
