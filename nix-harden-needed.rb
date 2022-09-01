#!@ruby@/bin/ruby

# @see https://www.thoughtco.com/optionparser-parsing-command-line-options-2907753
require 'optparse'

 # This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.
 options = {}

 optparse = OptionParser.new do |opts|
    opts.banner = "Usage: nix-harden-needed [options] file"
end

 # Parse the command-line. Remember there are two forms
 # of the parse method. The 'parse' method simply parses
 # ARGV, while the 'parse!' method parses ARGV and removes
 # any options found there, as well as any parameters for
 # the options. What's left is the list of files to resize.
 optparse.parse!

 ARGV.each do |f|

    unless f.match(/\.so$/)
        puts "Skipping #{f} since it's not a shared library file."
        next
    end

    absolute_path = File.expand_path(f)

    # Change the soname to be the absolute path
    `@patchelf@/bin/patchelf --set-soname #{absolute_path} #{f}`
end