#require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require 'optparse'
require 'logger'
require 'byebug'
require './disk_crawler.rb'
require './handlers/tag_reader.rb'
if $0 == __FILE__
  options = {}
  optparse = OptionParser.new do|opts|
    opts.banner = "Usage: build_song_lib.rb [-h | -d directory]"
    # Define the options, and what they do
    options[:dir] = nil
    opts.on( '-d path_to_song_collection',"Specify the top directory of your song collection" ) do |d|
      options[:dir] = d
    end
    
    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end
  # Parse the command-line. Remember there are two forms of the parse method.
  # The 'parse' method simply parses ARGV, while the 'parse!' method parses ARGV and removes any options found there,
  # as well as any parameters for the options. What's left is the list of files to resize.
  optparse.parse!
  begin
    if options[:dir] != nil
      #log = Logger.new("#{Rails.root}/log/song_craw.log")
      log = Logger.new("song_craw.log")
      robot = Darkportal::DiskCrawler.new
      robot.scan_and_process_files(options[:dir], Darkportal::Handlers::TagReader.new)
      puts "_________DONE__________"
    else
      raise 'Error: No top directory specified!'
    end
  rescue Exception => ex
    puts ex
  end
end