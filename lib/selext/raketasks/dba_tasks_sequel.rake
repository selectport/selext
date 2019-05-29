namespace 'dbase' do

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------

desc 'createDatabase environment [all production, test, development]'
task :createDatabase, [:in_enviro] do |t, args|

  enviro = args.in_enviro.to_s.downcase

    enviro = args.in_enviro.to_s.downcase    
    
    enviros = []
    enviros << :production  if enviro == 'production'  or enviro == 'all'
    enviros << :test        if enviro == 'test'        or enviro == 'all'
    enviros << :development if enviro == 'development' or enviro == 'all'

    enviros.each do |env|

      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :development
      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}_test" if env == :test
      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :production

      puts "... creating database #{dbname} for #{env}"

      cmd = "createdb -U $SELEXT_DATABASE_SUPER_USER " +
                     "-O $SELEXT_DATABASE_USER " +
                     "-h $SELEXT_DATABASE_HOST #{dbname}"

      puts "... cmd: #{cmd}"
      system cmd

    end  # enviros.each
    
  end  # createDatabase


# ------------------------------------------------------------------------------

  desc 'dropDatabase environment [production, test, development]'
  task :dropDatabase, [:in_enviro] do |t, args|
  
    enviro = args.in_enviro.downcase

    enviros = []
    enviros << :production  if enviro.downcase.to_s == 'production'
    enviros << :test        if enviro.downcase.to_s == 'test'  
    enviros << :development if enviro.downcase.to_s == 'development'
  
    enviros.each do |env|

      dbname = "#{ENV['SELEXT_DATABASE_NAME']}"      if env == :development
      dbname = "#{ENV['SELEXT_DATABASE_NAME']}_test" if env == :test
      dbname = "#{ENV['SELEXT_DATABASE_NAME']}"      if env == :production

      puts "... dropping database #{dbname} for #{env}"
    
      DB.disconnect
      cmd = "dropdb -U $SELEXT_DATABASE_SUPER_USER -h $SELEXT_DATABASE_HOST #{dbname}"
      system cmd

    end  # enviros.each
  
  end  # dropDatabase


# ------------------------------------------------------------------------------

  desc "create a new table in the database for specified Modelname  use : dbase:createTable[Modelname]"
  task :createTable, [:in_modelname] do |t,args|

    model       = args.in_modelname       # eg. ArtistPainting
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 

      if DB.table_exists?(tblname)
      
        puts "... ignoring create request : #{model} already exists" 
    
      else
      
        puts "... creating table #{tblname} for model #{model}"
                  
        ddl_filename = Selext.baseroot('dba', 'ddl', "#{model_file}.rb")

        require ddl_filename
        
        Module.const_get(model).send(:tblCreate)
 
        # conditional preseeds
        # --------------------

        # --------------------

      end

  end   # task create

# ------------------------------------------------------------------------------

  desc "drop the table in the database for the specified Modelname  use: dbase:dropTable[Modelname]"
  task :dropTable, [:in_modelname]  do |t, args|
      
    model       = args.in_modelname       # eg. ArtistPainting
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 

    puts "dropping tables for #{model}"
  
    if DB.table_exists?(tblname) then

      puts "...dropping table #{tblname} for model #{model}"
      
        DB.drop_table(tblname)
        
    else
    
      puts "...ignoring drop request : #{model} does not exist" 

    end

  end  # task drop

# ------------------------------------------------------------------------------

  desc "Create a db/structure.sql file that can be used by Postgresql"
  task :dumpStructure   do
  
    cmd = "pg_dump -U #{ENV.fetch('SELEXT_DATABASE_SUPER_USER')} " +
                  "-h #{ENV.fetch('SELEXT_DATABASE_HOST')} " +
                   "-s -x -O -f #{Selext.homeroot('db','structure.sql')} " +
           "#{ENV.fetch('SELEXT_DATABASE_NAME')}"

    system cmd
  
  end   # task dumpStructure

# ------------------------------------------------------------------------------

  desc 'Load a db/structure.sql file to database'
  task :loadStructure, [:in_enviro]  do |t, args|

  env = args.in_enviro.to_sym

  dbname = ''
  dbname = "#{ENV['SELEXT_DATABASE_NAME']}"      if env == :development
  dbname = "#{ENV['SELEXT_DATABASE_NAME']}_test" if env == :test
  dbname = "#{ENV['SELEXT_DATABASE_NAME']}"      if env == :production

  raise StandardError, "Invalid environment argument" if dbname.blank?

    cmd = "psql -U #{ENV.fetch('SELEXT_DATABASE_SUPER_USER')} " +
               "-h #{ENV.fetch('SELEXT_DATABASE_HOST')} " +
                  "#{dbname} " +
          "< #{Selext.homeroot('db','structure.sql')}"
    system cmd

    # set ownership of database & artifacts

    zdirname = File.dirname(__FILE__)

    cmd = ". #{zdirname}/helperlib/pg_change_ownership.sh -d #{dbname} " +
          "-o #{ENV['SELEXT_DATABASE_USER']}"

    puts "CMD : #{cmd}"
    system cmd


  end  # task loadStructure

# ------------------------------------------------------------------------------

  desc 'Load the BASE db/base_structure_sequel.sql file to database'
  task :loadBaseStructure, [:in_enviro]   do |t, args|

  env = args.in_enviro.to_sym

  dbname = ''
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :development
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}_test" if env == :test
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :production

  raise StandardError, "Invalid environment argument" if dbname.blank?

    cmd = "psql -U #{ENV.fetch('SELEXT_DATABASE_USER')} " +
               "-h #{ENV.fetch('SELEXT_DATABASE_HOST')} " +
                  "#{dbname} " +
          "< #{Selext.homeroot('db','base_structure_sequel.sql')}"

    system cmd

    # set ownership of database & artifacts

    zdirname = File.dirname(__FILE__)

    cmd = ". #{zdirname}/helperlib/pg_change_ownership.sh -d #{dbname} " +
          "-o #{ENV['SELEXT_DATABASE_USER']}"

    system cmd

  end  # task loadStructure

# ------------------------------------------------------------------------------

  desc "Add schema information (as comments) to model files"
  task :annotateModels do

    require 'sequel/annotate'

    # must manually require models and use our models map instead of the brain-dead
    # rails convention of snake-casing file and table names ...
     
    Selext.persisted_models_list.each do |m|
      mc = m.constantize
      sa = Sequel::Annotate.new(mc)
      mf = Selext::PMODELMAP[m][0]
      fn = Selext.models("#{mf}.rb")
      sa.annotate(fn, position: :before)
    end

    #Sequel::Annotate.annotate(Dir["#{Selext.models('*.rb')}"], position: :before)

  end  # task annotate_models

# ------------------------------------------------------------------------------

  desc "Dump DDL schema information for model file"
  task :makeDDL, [:in_modelname]  do |t, args|

    require_relative './helperlib/make_ddl_sequel.rb' 

    model       = args.in_modelname       # eg. ArtistPainting
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 
    ddlname     = Selext.baseroot('dba', 'ddl', "#{model_file}.rb")

    ddlfile     = File.open(ddlname, "w:utf-8")
       
    schema      = Selext::MakeDDLSequel.new(model, tblname).generate

    ddlfile.puts schema
    ddlfile.close

  end  # task makeDDL


# ------------------------------------------------------------------------------

  desc "prepare test database for testing"
  task :prepareTest  do |t|

      Rake::Task["dbase:dumpStructure"].reenable
      Rake::Task["dbase:dumpStructure"].invoke
      
      Rake::Task["dbase:dropDatabase"].reenable
      Rake::Task["dbase:dropDatabase"].invoke('test')

      Rake::Task["dbase:createDatabase"].reenable
      Rake::Task["dbase:createDatabase"].invoke('test')

      system("rake dbase:loadStructure[test]")
 
      Rake::Task["dbase:dumpStructure"].reenable
      Rake::Task["dbase:dropDatabase"].reenable
      Rake::Task["dbase:loadStructure"].reenable

  end

# ------------------------------------------------------------------------------

desc "ensure database contains all persisted model tables"
task :ensureTables do |t|

    # step thru each of the app pd models and create the tables and seed them 
    # if seeds are available.  THIS IS IDEMPOTENT and NON-DESTRUCTIVE and
    # NON-OVERWRITING!

      puts " "
      puts ". create any missing tables from ddl"
      puts " "


      Selext.persisted_models_list.each do |model|

        table_name = get_table_name(model)
        model_file = get_model_file(model)

        unless DB.table_exists?(table_name)

          puts "creating table #{table_name} for #{model}..."
          
          ddl_filename = Selext.baseroot('dba','ddl', "#{model_file}.rb") 

          require ddl_filename

          Module.const_get(model).send(:tblCreate)

          puts "... table #{table_name} for #{model} created"

        end  # table_exists?

      end  # each model

    # end

  end


# ------------------------------------------------------------------------------

  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
      Sequel::Migrator.run(DB, "db/migrations", target: version)
  end

# ------------------------------------------------------------------------------

  desc "drop, recreate, and re-seed a single table"
  task :resetTable, [:in_modelname]  do |t, args|

    Rake::Task["dbase:dropTable"].reenable
    Rake::Task["dbase:createTable"].reenable

    model = args.in_modelname
    model_file = get_model_file(model)

    puts "Reseting single table #{model}"

    # drop table

    Rake::Task["dbase:dropTable"].invoke(model)

    puts "...recreating the table"

    ddl_filename = Selext.baseroot('dba', 'ddl', "#{model_file}.rb")
    require ddl_filename

    Module.const_get(model).send(:tblCreate)

    puts "created - #{model}"

  end   # task resetTable  

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# ============================================================================== 
# Helper routines - no tasks below here
# ============================================================================== 

  # this is a helper routine which returns the table name for the given model;
  # if modelname is not in our hash here, it returns nil -> unknown persisted 
  # table
  
  def get_table_name(modelname)

    if Selext::PMODELMAP[modelname].nil?
      return nil
    else
      return Selext::PMODELMAP[modelname][1]
    end

  end  # def get_table_name


  def get_model_file(modelname)

    if Selext::PMODELMAP[modelname].nil?
      return nil
    else
      return Selext::PMODELMAP[modelname][0]
    end

  end  # def get_model_file



# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

end # namespace dbase
