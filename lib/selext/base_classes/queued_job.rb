# This is the actual request to run a job - sourced either from
# a local direct job request, or in response from an api job request
# received from the job service orchestrator (received either via an http api
# or MQ api request)  Each of those external interfaces would receive in an
# a different (but closely related) format and would have mediated to this
# QueuedJob format for enqueing
#
# We use this strategy so that the actual job_handler class specific to the
# processing is insulated from the invocation via Que or whatever other deferred
# job processing library is being used - thus allowing us to invoke the handlers
# directly outside of the job system altogether.
#
# See QueQueuedJob for the Que job that gets enqueued and which contains
# this QueuedJob
#
# ------------------------------------------------------------------------------

class  QueuedJob

include ActiveAttr::Model

attribute    :job_guid          # uuid assigned on origin of job_request
attribute    :job_code          # job code (eg. Testing::TestJob)
attribute    :parent_child      # S=single job; P=multi/parent; C=multi/child
attribute    :parent_guid       # '' unless parent_child=C

attribute    :req_timestamp     # time.now.utc.iso8601
attribute    :fill_or_kill      # F=fill (add to queue regardless)
                                # K=kill (reject if not processing now)
attribute    :ttl               # .to_s of integer seconds from request; 0 = no ttl max
attribute    :run_on_or_after   # datetime.to_iso8601; allow deferred queue/execution
attribute    :priority          # def = 100; lower = higher priority
attribute    :max_runtime       # .to_s of integer; 0 = no max
attribute    :run_on_service    # local or service name (eg. :svcname)
attribute    :req_source        # local or service name (who requested)

attribute    :run_mode          # blank=normal; any integer=testmode, sleep n secs
attribute    :job_params_class  # JobCard class for params (as string)
attribute    :job_params        # hash of JobParamsClass attributes (not class itself!)

# ------------------------------------------------------------------------------

# attribs is a hash/mash; could be nil if not reifying

def initialize(in_attribs=nil)

  in_attribs.nil? ? attribs = SelextMash.new : attribs = SelextMash.new(in_attribs)

  self.job_guid         = attribs[:job_guid]          || SecureRandom.uuid
  self.job_code         = attribs[:job_code]          || ''
  self.parent_child     = attribs[:parent_child]      || 'S'
  self.parent_guid      = attribs[:parent_guid]       || ''
  self.req_timestamp    = attribs[:req_timestamp]     || Time.now.iso8601
  self.fill_or_kill     = attribs[:fill_or_kill]      || 'F'
  self.ttl              = attribs[:ttl]               || '0'
  self.run_on_or_after  = attribs[:run_on_or_after]   || ''
  self.priority         = attribs[:priority]          || 100
  self.max_runtime      = attribs[:max_runtime]       || '0'
  self.run_on_service   = attribs[:run_on_service]    || 'local'
  self.req_source       = attribs[:req_source]        || 'local'
  self.run_mode         = attribs[:run_mode]          || ' '
  self.job_params_class = attribs[:job_params_class]  || ''
  self.job_params       = attribs[:job_params]        || {}

end

# ------------------------------------------------------------------------------
# we queue a serialized job_request as params to our JobQue gateways;
# here's a serialize/reify pair of convenience routines ...

def serialize

  self.attributes.to_json

end

# ------------------------------------------------------------------------------

# given serialized message, reify to object but as a set of 
# symbolized_keys hashes

# NOTE: we typically do not need the job_params further reified to JobParams
#       except when we're dequeuing - so the reified QueuedJob.job_params is
#       a HASH and not a JobParams ... reify the params at end point you actually
#       need them in JobParams class format

def self.reify(serialized_attributes)

  attribs = JSON.parse(serialized_attributes)
  self.new(attribs)

end


# ------------------------------------------------------------------------------

def test_mode?
  self.run_mode == 'T' ? true : false
end

end  # QueuedJob class
