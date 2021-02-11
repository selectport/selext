module SelextService

# ------------------------------------------------------------------------------

class Result

  attr_reader :retsts   # 'OK' || 'FAIL'
  attr_reader :errors   # hash or nil
  attr_reader :retobjs  # User or nil

  def initialize(retsts: nil, errors: nil, retobjs: nil)

    @retsts  = retsts
    @errors  = errors

    if retobjs.nil?
      @retobjs = {}
    else
      @retobjs = retobjs
    end

    # resulting retobjs has to be either hash or a mash
    unless @retobjs.is_a?(Hash)
      raise Selext::Errors::ProgrammingError, "retobjs on Service initialization is not a Hash"
    end

  end



  def successful?
    @retsts == 'OK'
  end



end # included class Result

# ------------------------------------------------------------------------------

def log_errors(e)

  # suppress exception reporting to the logs if we are testing...

  unless Selext.testing?

    puts("\nSERVICE HANDLER EXCEPTION \n #{e.message} \n")

    e.backtrace.each do |eline|
      puts eline
    end

  end


  errors = {'error on save': "#{e}"}

end # log_errors

# ------------------------------------------------------------------------------

end
