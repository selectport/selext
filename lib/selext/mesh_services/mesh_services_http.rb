module MeshServices

# ------------------------------------------------------------------------------

  def self.connection(svcname)

    unless self.services.keys.include?(svcname.to_sym)
      raise Selext::Errors::ProgrammingError, "Unknown service type : #{svcname}"
    end

    svc = self.services[svcname.to_sym]

    client  = ::Faraday.new

    addr   = "#{svc['protocol']}://#{svc['hostname']}:#{svc['port']}#{svc['root_path']}"

    [client, addr]

  end

# ------------------------------------------------------------------------------
# convenience routine to allow setting the proper url given just a 'service' 
# (eg. sandbox/production) id ...

  def self.url_for(svcname)

    svc = self.services[svcname.to_sym]

    "#{svc['protocol']}://#{svc['hostname']}:#{svc['port']}/#{svc['root_path']}"

  end

# ------------------------------------------------------------------------------
# note - we escape the url since we're passing query params in it

  def self.get(svcname, url)
    
    svc = svcname.to_sym

    if MeshServices.connections[svc].nil?
       MeshServices.connections[svc] = MeshServices.connection(svc)
    end

    client = MeshServices.connections[svc][0]
    addr   = MeshServices.connections[svc][1]

    path = URI.join(addr, url)

    # catch errors and convert to non-abends with our error scheme (see selext/errors)

    begin

      xresponse = client.get path

    rescue Exception => e

      # devnote: build these up as they occur!

      xresponse = MeshServiceError.new

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
  
  def self.post(svcname, url, body)

    svc = svcname.to_sym

    if MeshServices.connections[svc].nil?
       MeshServices.connections[svc] = MeshServices.connection(svc)
    end

    client = MeshServices.connections[svc][0]
    addr   = MeshServices.connections[svc][1]

    path   = "#{addr}#{url}"  #URI.join(addr, url)
    header = {'Authorization' => MeshServices.mesh_api_token}
    client.post(path, body, header)

  end

# ------------------------------------------------------------------------------

  # these are internal services; body is a hash where key is :data and value
  # is jsonified hash (typically contract.attributes.to_json)
  
  def self.patch(svcname, url, body)

    svc = self.services[svcname.to_sym]

    if MeshServices.connections[svc].nil?
       MeshServices.connections[svc] = MeshServices.connection(svc)
    end

    client = MeshServices.connections[svc][0]
    addr   = MeshServices.connections[svc][1]

    path = URI.join(addr, url)

    client.patch(path, body)

  end

# ------------------------------------------------------------------------------

  def self.close(svcname)
    
    svc = self.services[svcname.to_sym]

    if MeshServices.connections[svc] != nil

      client = MeshServices.connections[svc][0]
      client.reset_all
      
    end

  end

# ------------------------------------------------------------------------------

end  # module
