require 'yaml'

module Selext

  def self.load_app_configuration

    # these are statically set at the app level in the source code config file

    values = YAML.load_file(Selext.configroot('selext_config.yaml'))

    @system_code       = values['selext_system_code'].to_sym

    @traqs_mode        = values['selext_traqs_mode'].to_sym
    @authnav_mode      = values['selext_authnav_mode'].to_sym
    @jobmgmt_mode      = values['selext_jobmgmt_mode'].to_sym

    # these are dynamically loaded from the ENV

    @system_name       = @system_code  # default to this

    @system_name       = ENV['SELEXT_SYSTEM_NAME'].to_s if ENV.has_key?('SELEXT_SYSTEM_NAME')

    @service_seq       = '' # default to single node service

    @service_seq       = ENV['SELEXT_SERVICE_SEQ'].to_s if ENV.has_key?('SELEXT_SERVICE_SEQ')

    return true

  end # method

end # module
