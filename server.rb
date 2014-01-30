#!/usr/bin/env ruby
require 'optparse'
require 'byebug'
require 'yaml'
require 'drb'
require 'drb/acl'
require 'rubygems'
require 'taglib'
require 'securerandom'

if $0 == __FILE__
  options = {}
  optparse = OptionParser.new do|opts|
    opts.banner = "Usage: server.rb [-h | -d directory]"
    # Define the options, and what they do
    options[:dir] = nil
    opts.on( '-d path_to_folder_to_expose',"Specify the top directory you want to expose" ) do |d|
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
      #declare path to search when require file
      ['public', 'lib', 'handlers'].each do |dir|
        dir = "#{File.dirname(__FILE__)}/"+dir
        $LOAD_PATH.unshift(dir) unless $LOAD_PATH.include?(dir)
      end

      require 'support'
      require 'secure_state.rb'

      #Inject security key
      class RFM::Public::SecureState
        security_key = SecureRandom.hex
        puts "Security key: #{security_key}"
        @security_key = security_key
      end

      #TODO: enable access control list
      #acl = ACL.new(%w{deny all
      #                 allow localhost})
      #DRb.install_acl(acl)

      CONFIG = YAML.load(File.open('config.yml') {|f| f.read})
      CONFIG['top_dir'] = options[:dir].chomp("/")
      #Expose classes
      CONFIG['classes'].each do |klass|
        require klass["name"].underscore.split('/').last
      
        DRb.start_service("druby://#{CONFIG['host']}:#{klass['port']}", 
                          Object::const_get(klass['name']).new,
                          DRb.config.merge({:load_limit=>CONFIG['message_size'].to_i}))  
      end
      
      DRb.thread.join
    else
      raise 'Error: No top directory specified!'
    end
  rescue Exception => ex
    puts ex
  end
end