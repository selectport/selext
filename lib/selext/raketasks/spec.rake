# spec.rake

require "rspec/core/rake_task"

RSpec::Core::RakeTask.module_eval do

  def pattern

    bases  = [Selext.home]

    extras = []
    bases.each do |dir|
      if File.directory?( dir )
        extras << File.join( dir, 'spec', '**', '*_spec.rb' ).to_s
      end
    end
    extras
  end
  
end
