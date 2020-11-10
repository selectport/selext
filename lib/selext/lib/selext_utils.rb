module Selext
module Utils

# ------------------------------------------------------------------------------
# Next code block comes straight from interagent/pliny w/only namespace change
# and config dereferencing
# ------------------------------------------------------------------------------

    def self.parse_env(file)
      env = {}
      File.open(file).each do |line|
        line = line.gsub(/#.*$/, '').strip
        next if line.empty?
        var, value = line.split("=", 2)
        value.gsub!(/^['"](.*)['"]$/, '\1')
        env[var] = value
      end
      env
    end

    # Requires an entire directory of source files in a stable way so that file
    # hierarchy is respected for load order.
    def self.require_glob(path)
      files = Dir[path].sort_by do |file|
        [file.count("/"), file]
      end

      files.each do |file|
        require file
      end
    end

    class << self
      alias :require_relative_glob :require_glob
    end

# ------------------------------------------------------------------------------
# Next block is inhouse written selext code
# ------------------------------------------------------------------------------
#
# Usage : The normal use-case for safe_create is that we do NOT expect the file
# to already exist ... so we create the NEW file;  if a file does exist,
# we rename it to 1 higher than the prior last version and then create the
# file as requested

def self.safe_create(orig_full_file)

  # easy case - if file doesn't already exist, we just use it

  unless File.exist?(orig_full_file)
    return orig_full_file
  end

  # file already exists, for safe_create we'll specify new file to be
  # created as in_file + _vnn where nn is 1 more than highest version

  newfile = nil

  other_files = Dir.glob("#{orig_full_file}_v*")

  if other_files.empty?
    newfile = "#{orig_full_file}_v1"
    FileUtils.mv(orig_full_file, newfile, verbose: true)
  else
    vnum = other_files.last.gsub(orig_full_file,'').gsub('_v','').to_i + 1
    newfile = "#{orig_full_file}_v#{vnum}"
    FileUtils.mv(orig_full_file, newfile, verbose: true)
  end

  return newfile

end

# ------------------------------------------------------------------------------

  end
end
