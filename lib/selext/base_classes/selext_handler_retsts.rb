class  SelextHandlerRetsts
  
# ------------------------------------------------------------------------------
# Handler::Retsts gets returned from the handler as either a successful
# result (ie. valid? == true) or on errors (either request_validation or
# during execution)
#
# Note that we might want to provide additional errors derived during processing
# back to caller, so we lift out form validations to @errors so caller only 
# needs to check one place ...
#
# ------------------------------------------------------------------------------

attr_accessor :status     # status code from http status code list as Integer !

attr_accessor :errors     # .errors from request validation results (lifted out)
                          # errors is traditional amv hash with k=field and
                          # v=array of error messages on that field

attr_accessor :response   # ::Response of command handler request class or 
                          # ::JobResults of job handler class

# setup an alias for :response for jobs - can call them 'results' instead of
# response - but they are structured and function the same way ...

alias :results  :response
alias :results= :response=



def initialize(status=nil, errors=nil, response=nil)
  
  @status   = status
  @response = response

  # convert validation errors to single valued error hash; errors SHOULD BE
  # an active model errors hash k=>[v...];  we'll only report first error
  # on these internal api handlers

  @errors = {}

  if errors.is_a?(Hash)

    errors.each_pair do |k,v|

      if v.is_a?(Array)
        @errors[k.to_sym] = v[0]        # only take first error per field
      else
        @errors[k.to_sym] = v
      end

    end

  end

  if errors.is_a?(ActiveModel::Errors)

    errors.messages.each_pair do |k,v|
      @errors[k.to_sym] = v[0]          # only reporting first error on field
    end

  end

end

# ------------------------------------------------------------------------------

# valid statuses follow http statuses : ie 200 range is valid; 400-500 range
# signals errors

def valid?

  if @status >= 200 && @status <= 299
    return true
  end

  if @status >= 400 && @status <= 599
    return false
  end

  raise Selext::Errors::ProgrammingError, "Invalid status from command or job: #{@status}"

end


def invalid?
  !valid?
end



def inspect_results

  puts "Response/Results: "
  results.attributes.each_pair do |k,v|
    puts "#{SelextText.pad(k,25)} ---> #{v}"
  end

  return ''

end

# ------------------------------------------------------------------------------

end # class  Retsts
