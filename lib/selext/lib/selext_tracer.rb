module Selext
class TracerLogger < ::Logger

  def initialize(in_filename='')
    
    case 

    when in_filename == :NULL
    
      filename = File::NULL

    when in_filename.blank?

      filename = Selext.logroot('activity_tracer.log')

    else 

      filename = in_filename

    end

    super(filename)

    self.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.as_selext_detail} -->> #{msg}\n"
    end

  end

  def log(message)
    if message.is_a?(String)
      self.info message
    else
      self.info message.to_s
    end

  end

end
end
