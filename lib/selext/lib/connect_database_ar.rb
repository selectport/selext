require 'active_record'
require 'yaml'
require 'erb'


module Selext

  def self.connect_database_ar

    # RAILS will handle this itself, so don't do it under rails
    # And set the current database name

    Selext.database_info = Selext.databases[Selext.environment.to_sym]
    Selext.database_name = Selext.databases[Selext.environment.to_sym]['database']

    # ACTIVE RECORD VARIANT

    # Setup our logger

    ActiveRecord::Base.logger = Selext.logger

    # Include Active Record class name as root for JSON serialized output.
    ActiveRecord::Base.include_root_in_json = true

    # Store the full class name (including module namespace) in STI type column.
    ActiveRecord::Base.store_full_sti_class = true

    # Use ISO 8601 format for JSON serialized times and dates.
    ActiveSupport.use_standard_json_time_format = true

    # Don't escape HTML entities in JSON, leave that for the #json_escape helper.
    # if you're including raw json in an HTML page.
    ActiveSupport.escape_html_entities_in_json = false

    # Now we can establish connection with our db
    ActiveRecord::Base.establish_connection(Selext.database_info)


  end  # method

end  # module
