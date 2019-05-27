class SelextForm

    include ActiveAttr::Model
    include ActiveModel::Validations

    #attribute :id, Integer

    def self.from_params(params, additional_params = {})

      p_hash = hash_from(params)
      params_hash = p_hash.merge(additional_params)

      form = self.new

      form.attributes.keys.each do |key|
        if params_hash.keys.include?(key.to_s)
          form.send("#{key}=".to_sym, params_hash.send(:[], key))
        end
      end

      form

    end

    def self.hash_from(params)
      params = params.to_unsafe_h if params.respond_to?(:to_unsafe_h)
    end

    def to_key
      [id]
    end

    def to_model
      self
    end

    def persisted?
      false
    end

    def squish_form!
      self.attributes.each do |attrib|
        next if attrib[0] == :id
        next if attrib[1].blank?

        attrib[1].strip!
      end
    end
    
end # class

