require 'logger'

module Selext
class  TracerLogger < ::Logger

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
      "#{datetime.strftime("%Y.%m.%d %H:%M:%S.%L")} -->> #{msg}\n"

    end

  end

  def trace(guid, traqs_type, traqs_code,extra='')

    if extra.size > 100
      out_extra = extra[0,99]
    else
      out_extra = extra
    end

    message = "#{SelextText.pad(traqs_type,16)}  #{guid[0,8]}  #{SelextText.pad(traqs_code,42)}  #{out_extra}"

    self.info message.force_encoding('ASCII-8BIT')

  end
  
  def log(octet, message)
    self.info "#{octet} - #{message}"
  end

end
end
