require 'logger'

module SelextConnX

class  SqlLogger < ::Logger

  LEVELS = {:fatal => 4,
            :error => 3,
            :warn  => 2,
            :info  => 1,
            :debug => 0}
            
  def initialize(in_filename='')
    
    case 

    when in_filename == :NULL
    
      filename = File::NULL

    when in_filename.blank?

      filename = Selext.logroot("sut_db.log")

    else 

      filename = in_filename

    end

    super(filename)

    self.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y.%m.%d %H:%M:%S.%L")} -->> #{msg}\n"

    end

  end

  # def log(message)
  #   self.info message
  # end

end
end
