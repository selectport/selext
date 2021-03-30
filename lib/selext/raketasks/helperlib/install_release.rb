module Selext

class ReleaseManagement

# ------------------------------------------------------------------------------
# def self.tell_rollbar(version)

#   require 'uri'
#   require 'net/http'

#   url = URI("https://api.rollbar.com/api/1/deploy")

#   http = Net::HTTP.new(url.host, url.port)
#   http.use_ssl = true

#   request = Net::HTTP::Post.new(url)

#   git_commit = `git show --oneline`.chomp.split(' ')[0]

#   params = {}
#   params['environment']      = 'production'
#   params['rollbar_username'] = AppUtils.fetch_credentials('rollbar')[:rollbar_username]
#   params['access_token']     = AppUtils.fetch_credentials('rollbar')[:rollbar_access_token]
#   params['local_username']   = 'scott@selectport.com'
#   params['comment']          = "Version : #{version}"
#   params['status']           = 'succeeded'
#   params['revision']         = git_commit

#   request.body = params.to_json

#   response = http.request(request)

#   puts " "
#   puts "Rollbar Alerted : "
#   puts response.read_body
#   puts " "


# end

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# eg.  rake release:installRelease[v18.01.0001,<service_name>] =>
# self.install_release('v18.01.0001',<service_name>) where traqs must map onto a
# .ssh/config named server;  we're standardizing on 'maestro' username

def self.install_release(version, server)

  puts "Install release ... #{version} on #{server}"

  srv = DO::Server.new('srv1',server,'maestro',{forward_agent: true})
  srv.run "bash /home/maestro/.maestro/maestro-agent/#{Selext.system_service}_installer.sh #{version}"
  srv.close

  Selext::ReleaseManagement.tell_rollbar(version)

end # install release


# ------------------------------------------------------------------------------

end  # class
end  # module

