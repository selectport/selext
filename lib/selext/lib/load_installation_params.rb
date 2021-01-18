module Selext

  def self.load_installation_params

    @org_short_name    = ENV.fetch('INSTALLATION_ORG_SHORT_NAME')
    @org_long_name     = ENV.fetch('INSTALLATION_ORG_LONG_NAME')
    @org_domain        = ENV.fetch('INSTALLATION_ORG_DOMAIN')
    
    @portal_name       = ENV.fetch('INSTALLATION_PORTAL_NAME')
    
    @org_home_base_url = ENV.fetch('INSTALLATION_ORG_HOME_BASE_URL')
    @org_logo_url      = ENV.fetch('INSTALLATION_ORG_LOGO_URL')

  end # method

end # module
