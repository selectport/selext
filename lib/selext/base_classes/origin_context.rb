require 'active_attr'

class  OriginContext
  
  include ActiveAttr::Model

  attribute :origin_request_id
  attribute :origin_submitted_at

  attribute :origin_ipaddress

  attribute :origin_domain
  attribute :origin_subdomain
  attribute :origin_center
  attribute :origin_feature
  attribute :origin_authfunct

# ------------------------------------------------------------------------------
# Origin context is meant to carry tracing and tracking data thru the 3 layers
# If using our portals (ui layer), these are captured and setup in the Persona
# and since they are a user<->portal session, these are fully populated with
# information from both our code and the Request/Session object. 
#
# Our portals would pass these on to the UIAPI layer for authentication, 
# authorization, tracing calls (esp useful with a single portal->uiapi==> multi
# backend calls since we'll have the same request_id on all child calls);
#
# Other portals or external apps accessing our uiapi gateway are urged to 
# use these as well but if uiapi receives empty or only partially filled in 
# context, it will assign the missing fields as best it can - but they will be
# 'our side' values for many of the missing fields.
#
# On internal, service-to-service where the origination of the entries is NOT
# coming via portals/uiapi, just use the .internal call to build the minimal
# values from the origination service.
#
# Note : other than the uiapi filling in missing data at point of origin to our
# system, this origin_context is meant to be 'immutable' - ie. assigned at
# creation/entry point and then static for rest of calls.
#
# ------------------------------------------------------------------------------
# use for internal mesh originated items (eg. service-to-service)

def self.internal

  oc = {}

    oc[:origin_request_id]     = SecureRandom.uuid
    oc[:origin_submitted_at]   = Time.now.iso8601
    
    oc[:origin_ipaddress]      = ''

    oc[:origin_domain]         = ''
    oc[:origin_subdomain]      = ''   
    oc[:origin_center]         = ''
    oc[:origin_feature]        = ''

    oc[:origin_authfunct]      = ''

  origin_context = OriginContext.new(oc)

end

# ------------------------------------------------------------------------------
# convenience routine to provide a populated 'test' instance

def self.mock_context

  oc = {}

    oc[:origin_request_id]     = SecureRandom.uuid
    oc[:origin_submitted_at]   = Time.now.iso8601

    oc[:origin_ipaddress]      = '0.0.0.0'

    oc[:origin_domain]         = ''
    oc[:origin_subdomain]      = ''
    oc[:origin_center]         = 'fast_my_account'
    oc[:origin_feature]        = 'profile'

    oc[:origin_authfunct]      = 'display_profile_page'

  origin_context = OriginContext.new(oc)

end  # .mock_context


# ------------------------------------------------------------------------------
# convenience routine to provide a populated 'guest' instance

def self.guest_context(request)

  oc = {}

    oc[:origin_request_id]     = request.env['action_dispatch.request_id']
    oc[:origin_submitted_at]   = Time.now.iso8601

    oc[:origin_ipaddress]      = request.ip

    oc[:origin_domain]         = request.domain
    oc[:origin_subdomain]      = request.subdomain
    oc[:origin_center]         = 'presignin'
    oc[:origin_feature]        = 'page'

    oc[:origin_authfunct]      = 'presignin_display_page'

  origin_context = OriginContext.new(oc)

end  # .mock_context

# ------------------------------------------------------------------------------

def to_s

  self.attributes.each_pair do |k,v|
    puts "#{k} @ --> #{v}"
  end

end

# ------------------------------------------------------------------------------

end  # class
