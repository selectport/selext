 module Selext
  
  def Selext.require_enums

    @enums_list = []

    # load enums_list - from application

    enums = Dir.glob(Selext.enums("*.rb"))

    enums.each do |ef|
      enumname = File.basename(ef,".rb")
      @enums_list << enumname
      require ef
    end

  end # def

end # module
