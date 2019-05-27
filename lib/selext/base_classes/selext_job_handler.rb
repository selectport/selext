module SelextJobHandler

# ------------------------------------------------------------------------------
# Super class for all of our job handlers;  our primary class is called via
# .run(queued_job_hash) where job_request is a hash of the QueuedJob attribs
#
# note: NO STATE in handlers !
#
# the run converts the hash to a contract and validates via 
# ActiveModel::Validations and if input is valid,
# then calls the ._execute method of the primary handler class.
#
# in both cases : valid and invalid;  successful and fail;  we trap exceptions
# and processing errors and build a valid retsts of either success or fail
#
# ------------------------------------------------------------------------------
# Simply adds job_handling methods around the SelextHandler
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# convenience routine to tag job run start time; 

# NOTE: queued_job is an instance of the job command REQUEST

def SelextJobHandler.start_job(queued_job)

  t = Time.now

  job_stats = SelextJobStats.new

  job_stats.started_at = t.iso8601(6)
  job_stats.status     = 'started'
  job_stats.job_guid   = queued_job.job_guid
 
  # setup a job_history (local) record on start ..... in normal case, it will 
  # updated at end_job;  if it abends, we'll have an orphan record in the file with
  # a 'started' status;  see above rescue clause, too
    
  # we don't want all the recurring setup jobs to log a record so we skip
  # those

  unless %w(Orchestration::QueueJob 
            Orchestration::BridgeCalendar
           ).include?(queued_job.job_code)


      jh = ::JobHistory.new

        jh.job_guid         = queued_job.job_guid
        jh.job_code         = queued_job.job_code
        jh.parent_child     = queued_job.parent_child

        jh.req_timestamp    = queued_job.req_timestamp
        jh.fill_or_kill     = queued_job.fill_or_kill
        jh.ttl              = queued_job.ttl
        jh.run_on_or_after  = queued_job.run_on_or_after
        jh.priority         = queued_job.priority
        jh.max_runtime      = queued_job.max_runtime
        jh.run_on_service   = queued_job.run_on_service
        jh.req_source       = queued_job.req_source
        jh.run_mode         = queued_job.run_mode
        jh.job_params_class = queued_job.job_params.class.name
        jh.job_params       = queued_job.job_params.to_json

        jh.job_results      = ''
        
        jh.started_at       = job_stats.started_at
        jh.finished_at      = nil
        jh.volume1          = nil
        jh.volume2          = nil
        jh.duration         = nil
        jh.status           = 'started'

        jh.num_jobs         = '1'   # for each job, it looks like it's only 1; 
                                      # orchsvc handles multiple job coordination
      jh.save

      # we push a jobsts message to Traqs on the start of the job

      # ::Traqs.publish_jobsts(job_code:        queued_job.job_code, 
      #                        job_guid:        queued_job.job_guid, 
      #                        job_attribs:     queued_job.attributes,  
      #                        job_stats:       job_stats.attributes)


  end # skip the orchestration setup jobs

  return job_stats

end  # start_job

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# jobhandler must fill in the volume1 and volume2 fields in the job_stats before 
# calling end_job

def SelextJobHandler.end_job(queued_job, job_stats, job_results)

  te = Time.now
  job_stats.finished_at  = te.iso8601(6)

  t0 = Time.parse(job_stats.started_at)
  duration = te-t0  # diff in seconds

  job_stats.duration = duration.to_s

  job_stats.status   = 'finished'


  # update the completed status on local job_history - skipping records we
  # skipped above on start_job

  unless %w(Orchestration::QueueJob 
            Orchestration::BridgeCalendar
           ).include?(queued_job.job_code)

    jh = JobHistory.where(job_guid: queued_job.job_guid).first
      raise unless jh  # huh?  it should have been put there on job_start!

      jh.finished_at = job_stats.finished_at
      jh.volume1     = job_stats.volume1
      jh.volume2     = job_stats.volume2
      jh.duration    = job_stats.duration
      jh.status      = 'finished'
      jh.job_results = job_results.attributes.to_json

    jh.save

    # we push a jobend message to Traqs on the end of the job

    # ::Traqs.publish_jobend(job_code:        queued_job.job_code, 
    #                        job_guid:        queued_job.job_guid, 
    #                        job_attribs:     queued_job.attributes, 
    #                        job_results:     job_results.attributes, 
    #                        job_stats:       job_stats.attributes)

  end # skipped records


end  # end_job

# ------------------------------------------------------------------------------

end # Handlers module
