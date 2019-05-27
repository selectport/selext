module Selext

  class MessageSerializer

    # hash_or_json is either a hash, a mash, a string (json'd), or one of the
    # message classes;

    # serialize it to a pure json string

    def self.serialize(hash_or_json)

      return hash_or_json if hash_or_json.class == String

      if hash_or_json.is_a?(Hash)  # hash or mash
        return hash_or_json.to_json
      end

      if hash_or_json.is_a?(SelextRequest)
        return hash_or_json.to_json
      end

      raise StandardError, "Programming Error : Unhandled Request Type #{hash_or_json.class.name}"

    end  # method serialize

  end  # Serializer

end #  module Selext
