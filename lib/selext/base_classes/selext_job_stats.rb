class SelextJobStats

  attr_accessor :job_guid         # job_guid of job_history
  attr_accessor :started_at       # Time.iso8601(6) when job started
  attr_accessor :finished_at      # Time.iso8601(6) when job finished
  attr_accessor :duration         # seconds+fraction diff between start/finished
  attr_accessor :volume1          # job-determined volume as string
  attr_accessor :volume2          # job-determined volume as string
  attr_accessor :status           # started, running, finished, abended

  def initialize

    @job_guid    = ''
    @started_at  = ''
    @finished_at = ''
    @duration    = ''
    @volume1     = ''
    @volume2     = ''
    @status      = ''

  end

  def attributes

    {
      job_guid:       @job_guid,
      started_at:     @started_at,
      finished_at:    @finished_at,
      duration:       @duration, 
      volume1:        @volume1,
      volume2:        @volume2,
      status:         @status
    }
    
  end

end  # class
