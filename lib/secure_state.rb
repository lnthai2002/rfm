require 'yaml'
module RFM
  class SecureState
    #block all unsafe method
    safe_methods = %i(private_methods protected_methods send __send__ object_id __id__ respond_to? to_s)
    (instance_methods - safe_methods).each do |method|
      undef_method method
    end

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