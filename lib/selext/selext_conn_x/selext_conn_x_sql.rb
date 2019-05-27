module SelextConnX

# ------------------------------------------------------------------------------
# will connect to the remote database connection pool and put connection in our
# SelextConnX.sutdb variable (instead of a global constant since we'll be
# dynamically connecting/disconnecting as necessary)

# database_tag is used to look up the connection information in the SUTDatabase
# table of current app;  password is then fetched from our encrypted credentials
# in config/credentials.yml.enc

def self.connect_sut_db(database_tag)

  raise StandardError, "Missing database_tag on connect_sut_db call." if database_tag.blank?

  if @sutdb.nil?
    
    remote_database = SUTDatabase.where(database_tag: database_tag.to_s).first
      unless remote_database
        raise StandardError, "Invalid database_tag for SUT : #{database_tag}"
      end

    remote_password = 
        AppUtils.fetch_credential('prod_database_passwords')[database_tag.to_sym]

    SelextConnX.sql_logger.info(
       "CONNECTING TO SUT_DB  #{remote_database.database_name} on #{remote_database_database_host}")

    begin

      SelextConnX.sql_logger.info "...connect to the database"

      SelextConnX.sutdb = Sequel.connect(adapter:             :postgres, 
                                         database:            remote_database.database_name,
                                         user:                remote_database.database_user,
                                         password:            remote_password,
                                         host:                remote_database.database_host,
                                         port:                remote_database.database_port,
                                         max_connections:     1, 
                                         pool_timeout:        5,
                                         log_connection_info: true,
                                         logger:              SelextConnX.sql_logger
                                         )

    rescue PG::Error => e

      SelextConnX.sql_logger.info  "Error connecting to SUT database"
      SelextConnX.sql_logger.info  e.message
      raise

    rescue Exception => e

      SelextConnX.sql_logger.info  "Error connecting to SUT database"
      SelextConnX.sql_logger.info  e.message
      raise

    end

  end

end


# ------------------------------------------------------------------------------
# will disconnect from the connection pool and nil out our connection variable


def self.close_sut_db

  begin

    SelextConnX.sql_logger.info "...disconnect from the database"

    SelextConnX.sutdb.disconnect
    SelextConnX.sutdb = nil

  rescue Exception => e

    SelextConnX.sql_logger.info   e.message

  end

end

# ------------------------------------------------------------------------------

end # module

