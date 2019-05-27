module SelextConnX

# ------------------------------------------------------------------------------
# will connect to the remote database connection pool and put connection in our
# SelextConnX.sutdb variable (instead of a global constant since we'll be
# dynamically connecting/disconnecting as necessary)

def self.connect_sut_db

  if @sutdb.nil?
    
    remote_database = Selext.databases[:sut]
    remote_database[:password] = 
        AppUtils.fetch_credential(
          'prod_database_passwords')[ENV.fetch('SUT_DATABASE_TAG').to_sym]

    SelextConnX.sql_logger.info(
       "CONNECTING TO SUT_DB  #{remote_database[:database]} on #{remote_database[:host]}")

    begin

      SelextConnX.sql_logger.info "...connect to the database"

      SelextConnX.sutdb = Sequel.connect(adapter:             :postgres, 
                                         database:            remote_database[:database],
                                         user:                remote_database[:username],
                                         password:            remote_database[:password],
                                         host:                remote_database[:host],
                                         port:                remote_database[:port],
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

