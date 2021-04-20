class  SelextHandler

# ------------------------------------------------------------------------------
# Super class for all of our commands, queries, and probes;  
# our primary class is called via
# .run(selext_request) where selext_request is the SelextRequest object
# which will be used to instantiate this run.  
#
# note: NO STATE in handlers !
#
# IT IS EXPECTED THAT THE CALLING PROGRAM (typically an internal web controller,
# or an internal API controller, or a que job) WOULD HAVE VALIDATED THE SOURCE
# DATA (eg. web: form, api: request, job: params) before calling (ie. outward
# validation at the seam) and therefore we do NOT re-validate the selext_request
#
# in both cases : valid and invalid;  successful and fail;  we trap exceptions
# and processing errors and build a valid retsts of either success or fail
#
# ------------------------------------------------------------------------------

  # NOTE : this (or run!) is the PUBLIC api for calling the action
  # in order to wrap the __execute logic block with validation checking

  # selext_request is instance of SelextRequest and

  def self.run(selext_request)

    # wrap in rescue block for clean trapping/returning of exceptions

    begin

      retsts = self._execute(selext_request)

    rescue Exception => e

      puts ""
      puts("API HANDLER EXCEPTION \n #{e.message}")
      puts ""

      e.backtrace.each do |eline|
        puts eline
      end

      # SRETODO .. if rollbar doesn't get these, throw something
      # that it does

      return SelextHandlerRetsts.new(500, 
                                      {'caught_exception' => [e.message]},
                                       {})

    end # begin/rescue/end

    # and make sure our primary handler class was a good citizen/programming
    # no rescue block here !

      assert retsts.is_a?(SelextHandlerRetsts)

    # retsts passed back

    return retsts

  end  # method

end  # class  SelextHandler
