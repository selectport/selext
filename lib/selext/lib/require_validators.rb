 module Selext

  def Selext.require_validators

    @validators_list = []

    # load validators_list - from application
    
    validators = Dir.glob(Selext.validators("*.rb"))

    validators.each do |vf|
      valname = File.basename(vf,".rb")
      @validators_list << valname
      require vf
    end


  end # def

end # module
