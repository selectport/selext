# note - this is connected outside of the Selext module !

require 'logger'

  DB = Sequel.connect(adapter:          :postgres, 
                      user:             ENV['SELEXT_DATABASE_USER'],
                      host:             ENV['SELEXT_DATABASE_HOST'],
                      port:             ENV['SELEXT_DATABASE_PORT'],
                      password:         ENV['SELEXT_DATABASE_PASSWORD'],
                      database:         Selext.database_name, 
                      max_connections:  10, 
                      logger:           Logger.new('log/db.log')
                      )

