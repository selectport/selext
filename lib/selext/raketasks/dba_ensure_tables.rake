
# ----------------------------------------------------------------------------------------------------------------
# if we're calling thru rails environment, :environment task will already be defined in a railsy-way ... skip here
# otherwise, we just define a blank environment since our tasks depend on it...

  unless Rake::Task.task_defined?(:environment)
    task :environment do
    end
  end

# ----------------------------------------------------------------------------------------------------------------

namespace 'dbase' do

# ----------------------------------------------------------------------------------------------------------------

  desc "ensure database contains all persisted model tables"
  task :ensureTables  => :environment do |t|

    # step thru each of the app pd models and create the tables and seed them 
    # if seeds are available.  THIS IS IDEMPOTENT and NON-DESTRUCTIVE and
    # NON-OVERWRITING!

      puts " "
      puts ". create any missing tables from ddl"
      puts " "

      built_models = []

      Gselext.persisted_models_list.each do |model|

        model_table = model.tableize

puts "MODEL is #{model} table is #{model_table}"

        unless ActiveRecord::Base.connection.table_exists? model_table

          puts "creating table for #{model}..."
          
            Rake::Task["dbase:createTable"].reenable
            Rake::Task["dbase:createTable"].invoke(model)

          puts "... table for #{model} created"

          built_models << model

        end  # table_exists?

      end  # each model


      # seed any tables built if a seed exists 

      built_models.each do |model|

        seed_file = resolveSeedFile(model)

        if seed_file.not_blank?
          puts "...seed #{model} with #{seed_file}"
          require seed_file
          sname = "seed#{model}"
          DBseed.send(sname)
        end


      end
       
  end

# ----------------------------------------------------------------------------------------------------------------
end  # dbase namespace
# ----------------------------------------------------------------------------------------------------------------
