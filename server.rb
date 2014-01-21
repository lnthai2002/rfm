#!/usr/bin/env ruby
=begin
CURRENT_OBJECT_STORE = File.expand_path("..", __FILE__)
RAILS_ROOT = File.expand_path("../../..", __FILE__)
%W{#{RAILS_ROOT}/lib/ #{CURRENT_OBJECT_STORE} #{RAILS_ROOT}/vendor/ #{RAILS_ROOT}/lib/extensions/ #{RAILS_ROOT}/app/models/f1_common/ #{RAILS_ROOT}/app/models/dataset/ #{RAILS_ROOT}/lib/overlay_adapter/adapters #{RAILS_ROOT}/app/controllers/f1 #{RAILS_ROOT}/lib/authentication/ #{RAILS_ROOT}/app/controllers/observers #{RAILS_ROOT}/app/controllers/filters)}.each do |path|
  $: << path
end
=end
require 'yaml'
require 'drb'
require 'drb/acl'
require 'rubygems'
require './lib/disk_crawler.rb'
require './handlers/tag_reader.rb'
require './handlers/tag_writer.rb'
require './handlers/streamer.rb'
#Dir[File.dirname(__FILE__) + '/handlers/*.rb'].each {|file| require file }

CONFIG_FILE="#{File.expand_path(File.dirname(__FILE__))}/config.yml"
CONFIG = YAML.load(File.open(CONFIG_FILE) {|f| f.read})

#TODO: enable access control list
#acl = ACL.new(%w{deny all
#                 allow localhost})
#DRb.install_acl(acl)

#Expose classes
CONFIG['classes'].each do |klass|
  DRb.start_service("druby://#{CONFIG['host']}:#{klass['port']}", 
                    Object::const_get(klass['name']).new,
                    DRb.config.merge({:load_limit=>CONFIG['message_size'].to_i}))  
end

DRb.thread.join