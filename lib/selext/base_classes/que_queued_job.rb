# note - client side does not need the invoker because .run is not called
# that is called only on the que_server dequeue process - 
# 
# make sure to require invoke_job_handler in server ...
#
class QueQueuedJob < Que::Job

  # tl/dr; This is the single wrapping job that is ever queued/dequeued from
  # Que;  it contains the params for us to extract from here, instantiate the
  # 'real' job class and invoke run on that
  #
  # the longer version...
  #
  # the actual Que Job for OxigineJobs
  #
  # This is an omnibus job - the only 'job' job that runs thru Que;
  # we put it on the que via QueJobServer.queue_job which serialized the QueuedJob
  # instance (abstract/generic - not Que specific implementation) to
  # a Que specific implementation and stuffed it into Que.
  #
  # Now when you enqueue to Que it wraps your 'job-class' into a QueJob
  # record and stuffs THAT into postgresql.  Later when dequeuing in the worker,
  # Que extracts from pg, and reifies our class QueTraqsJob and then invokes 
  # run - passing it the original wrapped job's parameters (in this case, that 
  # would have been the wrapped QueuedJob) as a hash. (typically would have been
  # the options to the job ... which in our case the options to the single job
  # QueTraqsJob IS the serialized original job_card::job_params ... 
  # it's all kind of meta)
  #
  # We receive the queued_job_hash (as hash) as params to run ... 
  # then to actually perform the job, we want to reify the job_params (which
  # is currently just a hash and not an actual JobParams for this job)
  # we must require that job's job_card::job_params, instantiate it using
  # the job_params hash from the queued_job_hash to convert/and stuff the 
  # job params back into the queued_job hash before requiring and calling the
  # particular job_handler called for 'inside' the queued_job
  # which effectively converts the single, generic queued_job as QueOxigineJob
  # into the actual job handler itself....
  #

# ------------------------------------------------------------------------------

  # queued_job_hash was the job_attribs (hash) pushed into Que via 
  # Oxigine.QueuedJob.enque  When Que dequeues job and invokes us here at .run
  # it passes us that QueuedJob hash of attributes which we then can pass onto
  # the job handler

  def run(queued_job_hash)

puts "QUEUED_JOB_HASH: #{queued_job_hash.inspect}"
    queued_job = QueuedJob.new(queued_job_hash)
puts "AS OBJECT: #{queued_job.inspect}"
  
    Selext.tracer.trace(queued_job_hash[:job_guid], 
                        'run job', 
                        queued_job_hash[:job_code],
                        queued_job_hash[:job_params].to_json) if Selext.tracing?


    job_handler_class = "JobHandlers::#{queued_job_hash[:job_code]}::JobHandler"

    job_handler = job_handler_class.constantize
    job_retsts  = job_handler.send(:run, queued_job)   

    Selext.tracer.trace(queued_job_hash[:job_guid], 
                        'finish job', 
                        queued_job_hash[:job_code],
                        queued_job_hash[:job_params].to_json) if Selext.tracing?

    return true  # so Que can clear item from queue

  end

end
