 module Selext

  def Selext.require_models

    # load application_record first

      require Selext.models('application_record.rb')
      
    # load specific models in Selext.models_list 
      Selext.all_models_list.each do |model|
        next if model == 'ApplicationRecord'

        if Selext::PMODELMAP.has_key?(model)
          modelfn    = Selext::PMODELMAP[model][0]
        else
          modelfn    = Selext::NPMODELMAP[model][0]
        end

        model_file = Selext.models("#{modelfn}.rb")

        begin
          require model_file

        rescue Exception => e
          msg = e.to_s
          unless msg.include?('relation') && msg.include?('does not exist')
            raise
          end
        end

      end


  end # def

end # module
