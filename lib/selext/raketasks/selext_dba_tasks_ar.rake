require 'erb'

# ----------------------------------------------------------------------------------------------------------------
# if we're calling thru rails environment, :environment task will already be defined in a railsy-way ... skip here
# otherwise, we just define a blank environment since our tasks depend on it...

  unless Rake::Task.task_defined?(:environment)
    task :environment do
    end
  end

# ----------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------

namespace 'dbase' do


  desc "Checks to see if the database exists"
  task :exists do
    begin
      Rake::Task['environment'].invoke
      ActiveRecord::Base.connection
    rescue
      exit 1
    else
      exit 0
    end
  end

# ----------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

desc 'createDatabase environment [all production, test, development]'
task :createDatabase, [:in_enviro] do |t, args|

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

      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :development
      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}_test" if env == :test
      dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :production

      puts "... dropping database #{dbname} for #{env}"
    
      #ActiveRecord::Base.connection_pool.active_connection?.try(:disconnect!)

      cmd = "dropdb -U $SELEXT_DATABASE_SUPER_USER -h $SELEXT_DATABASE_HOST #{dbname}"
      system cmd

    end  # enviros.each
  
  end  # dropDatabase


# ------------------------------------------------------------------------------

  desc "create a new table in the database for specified Modelname  use : dbase:createTable[Modelname]"
  task :createTable, [:in_modelname] do |t,args|
      
    Selext.require_models
    Selext.connect_database_ar

    model       = args.in_modelname       # eg. ArtistPainting
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 

      if eval("#{model}.table_exists?")
      
        puts "... ignoring create request : #{model} already exists" 
    
      else
      
        puts "... creating table #{tblname} for model #{model}"
                  
        ddl_filename = Selext.baseroot('dba', 'ddl', "#{model_file}.rb")

        require ddl_filename
        
        Module.const_get(model).send(:tblCreate)
 
      end

  end   # task create

# ------------------------------------------------------------------------------

  desc "drop the table in the database for the specified Modelname  use: dbase:dropTable[Modelname]"
  task :dropTable, [:in_modelname]  do |t, args|
      
    Selext.require_models
    Selext.connect_database_ar
       
    model       = args.in_modelname       # eg. ArtistPainting
    model_class = model.constantize
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 

    puts "dropping table #{tblname} for #{model}"
  
    if model_class.send(:table_exists?) then

      puts "...dropping table #{tblname} for model #{model}"
      
      ActiveRecord::Schema.define do
      
        drop_table tblname
        
      end 
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
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :development
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}_test" if env == :test
  dbname = "#{ENV['SELEXT_DATABASE_ROOT']}"      if env == :production

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

  desc 'Load the BASE db/base_structure.sql file to database'
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
          "< #{Selext.homeroot('db','base_structure.sql')}"

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

    cmd = "bundle exec annotate --models"
    system cmd

  end  # task annotate_models

# ------------------------------------------------------------------------------

  desc "Dump DDL schema information for model file"
  task :makeDDL, [:in_modelname]  do |t, args|

    require_relative './helperlib/selext_make_ddl.rb' 

    Selext.connect_database_ar

    model       = args.in_modelname       # eg. ArtistPainting
    model_file  = get_model_file(model)   # eg. artist_painting
    tblname     = get_table_name(model) 
    ddl_name    = Selext.baseroot('dba', 'ddl', "#{model_file}.rb")

    #Selext.connect_database_ar

    puts "... dumping current table structure for #{model} to ddl file : #{ddl_name}"
    puts " "

    File.open( ddl_name, "w:utf-8") do |file|
       DDLDumper.dump(ActiveRecord::Base.connection, file, ActiveRecord::Base, 
                      model, tblname)
    end

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

      Selext.require_models
      Selext.connect_database_ar

      Selext.persisted_models_list.each do |model|

        table_name  = get_table_name(model)
        model_file  = get_model_file(model)
        model_class = model.constantize

        unless model_class.send(:table_exists?)

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

  desc "list valid Model/table names"
  task :listModels => :environment  do
    
    Selext.persisted_models_list.each do |k|

       table = get_table_name(k)

       outf = sprintf("Model : %-40s --> Table : %s",k,table)
       puts outf
       
    end
  
  end   # task listModels

# ------------------------------------------------------------------------------

  desc "Run migrations"
  task :migrate, [:version] do |t, args|

    version = ''
    version = args[:version].to_i if args[:version]

    if version.blank?
      cmd = "bundle exec rails db:migrate"
    else
      cmd = "bundle exec rails db:migrate VERSION=#{version}"
    end

    system cmd

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
