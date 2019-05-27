module SelextConnX

# ------------------------------------------------------------------------------

  def self.connection(service_type)

    svctype = service_type.to_s

    client  = ::JSONClient.new
    svc_url = SelextConnX.services[svctype]

    if svc_url.blank?
      raise Selext::Errors::ProgrammingError, "Unknown service type : #{service_type}"
    end

    if Selext.deployment_type == 'local'
      addr   = "#{svc['protocol']}://0.0.0.0:#{svc['port']}"
    else
      addr   = "#{svc['protocol']}://#{svctype.to_s}:#{svc['port']}"
    end

    [client, svc_url]

  end

# ------------------------------------------------------------------------------
# note - we escape the url since we're passing query params in it

  def self.get(svc, url)
    
    if SelextConnX.connections[svc].nil?
       SelextConnX.connections[svc] = SelextConnX.connection(svc)
    end

    client = SelextConnX.connections[svc][0]
    addr   = SelextConnX.connections[svc][1]

    path = URI.join(addr, url)

    # catch errors and convert to non-abends with our error scheme (see selext/errors)

    begin

      xresponse = client.get path

    rescue Exception => e

      # devnote: build these up as they occur!

      xresponse = SelextConnXError.new

      if e.errno == ::Errno::ECONNREFUSED::Errno
        xresponse.status = 503
        xresponse.body   = {'errors' => {http: 'Service Unavailable'}}
        return xresponse
      else
        xresponse.status = 500
        xresponse.body   = {'errors' => {http: 'NOI Error'}}
        return xresponse
      end

    else  # no errors

      return xresponse

    end

  end


# ------------------------------------------------------------------------------

  # these are internal services; body is a hash where key is :data and value
  # is jsonified hash (typically contract.attributes.to_json)
  
  def self.post(svc, url, body)

    if SelextConnX.connections[svc].nil?
       SelextConnX.connections[svc] = SelextConnX.connection(svc)
    end

    client = SelextConnX.connections[svc][0]
    addr   = SelextConnX.connections[svc][1]

    path = URI.join(addr, url)

    client.post(path, body)

  end

# ------------------------------------------------------------------------------

  # these are internal services; body is a hash where key is :data and value
  # is jsonified hash (typically contract.attributes.to_json)
  
  def self.patch(svc, url, body)

    if SelextConnX.connections[svc].nil?
       SelextConnX.connections[svc] = SelextConnX.connection(svc)
    end

    client = SelextConnX.connections[svc][0]
    addr   = SelextConnX.connections[svc][1]

    path = URI.join(addr, url)

    client.patch(path, body)

  end

# ------------------------------------------------------------------------------

  def self.close(svc)
    
    if SelextConnX.connections[svc] != nil

      client = SelextConnX.connections[svc][0]
      client.reset_all
      
    end

  end

# ------------------------------------------------------------------------------

end  # module
