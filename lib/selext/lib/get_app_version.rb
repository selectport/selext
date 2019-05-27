module Selext

extend self

attr_accessor :app_version 

# ------------------------------------------------------------------------------
# reloads from file;  normally, to use current cached version just access via
# Selext.app_version

  def self.get_app_version

    # use cicd Version file

    vFilename = Selext.homeroot("cicd", "Version")

    if File.exists?(vFilename)

      ovFile     = File.open(vFilename,'r')
      curline    = ovFile.readline
      ovFile.close
      @app_version = curline[0,11]
      return @app_version

    end


    # else return a blank string

    @app_version = ''


  end # method get_app_version

# ------------------------------------------------------------------------------

end # module
