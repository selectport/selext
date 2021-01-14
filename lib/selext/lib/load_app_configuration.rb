require 'yaml'

module Selext

  def self.load_app_configuration

    values = YAML.load_file(Selext.configroot('selext_config.yaml'))

    @system_code       = values['selext_system_code'].to_sym

    @traqs_mode        = values['selext_traqs_mode'].to_sym
    @authnav_mode      = values['selext_authnav_mode'].to_sym
    @jobmgmt_mode      = values['selext_jobmgmt_mode'].to_sym

  end # method

end # module
