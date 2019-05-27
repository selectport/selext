#!/usr/bin/env ruby

gem_dir = File.dirname(File.absolute_path(__FILE__))
gem_dir.sub!('/bin','')
gem_name = File.basename(gem_dir)

version_file = File.join(gem_dir, 'lib', gem_name, 'version.rb')

unless File.exist?(version_file)
  puts "expected version file at : #{version_file}"
  raise StandardError, "Version file not in expected location."
end

verlines = File.open(version_file).readlines

version_line = verlines[2]

unless version_line[0,5] == "    '"
  puts "version line : #{version_line}"
  raise StandardError, "Version line not in expected format."
end

major, minor, patch = version_line.split(".")
major.gsub!("'",'')
patch.gsub!("'",'')
major.strip!
minor.strip!
patch.strip!

ipatch = patch.to_i
npatch = ipatch + 1

new_version = "#{major}.#{minor}.#{npatch}"

new_version_line = "    '#{new_version}'"

verlines[2] = new_version_line

vfile = File.open(version_file, 'w')

  verlines.each do |l|
    vfile.puts l
  end

vfile.close

puts new_version

