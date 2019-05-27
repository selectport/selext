 module Selext

  def Selext.require_models

  unless @run_mode == :in_rails

  # load specific models in Selext.models_list 

    Selext.all_models_list.each do |model|
      model_file = Selext.models("#{SelextText.fileize(model)}.rb")
      begin
        require model_file

      rescue Exception => e
        msg = e.to_s
        unless msg.include?('relation') && msg.include?('does not exist')
          raise
        end
      end

    end

  end

  end # def

end # module
