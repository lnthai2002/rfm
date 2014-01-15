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

CONFIG_FILE="#{File.expand_path(File.dirname(__FILE__))}/config.yml"
config = YAML.load(File.open(CONFIG_FILE) {|f| f.read})

acl = ACL.new(%w{deny all
                 allow localhost})
DRb.install_acl(acl)

#List of class to expose and their port
DRb.start_service("druby://#{config['host']}:#{config['port']}", 
                  FortiusOne::ObjectStore.new(config['target'].to_i,
                                              config['max'],
                                              File.dirname(__FILE__)+config['basedir']),
                  DRb.config.merge({:load_limit=>config['message_size'].to_i}))
DRb.thread.join

$processor = nil

