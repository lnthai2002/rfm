require 'yaml'
module RFM
  class SecureState
    #load and record security key
    CONFIG_FILE="#{File.expand_path(File.dirname(__FILE__))}/..//config.yml"
    CONFIG = YAML.load(File.open(CONFIG_FILE) {|f| f.read})
    @security_key = CONFIG['security_key']
    
    def self.valid?(security_key)
      if security_key != @security_key
        raise ArgumentError, "authentication fail"
      end
    end
  end
end