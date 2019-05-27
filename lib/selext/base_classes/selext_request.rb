class SelextRequest

  include ActiveAttr::Model
  include ActiveModel::Validations

  def self.from_form(form)

    req = self.new

    req.attributes.keys.each do |key|
      if form.attributes.keys.include?(key)
        req.send("#{key}=".to_sym, form.send(key))
      end
    end

    req
    
  end

end # class SelextRequest
