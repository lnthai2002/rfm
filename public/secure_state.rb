module RFM
  module Public
    #Any class exposed to public must extend this class to be safer
    class SecureState
      @security_key = nil #tobe injected by server
      #block all unsafe method
      safe_methods = %i(private_methods protected_methods send __send__ object_id __id__ respond_to? to_s)
      (instance_methods - safe_methods).each do |method|
        undef_method method
      end

      def self.valid?(security_key)
        if security_key != @security_key
          raise ArgumentError, "authentication fail"
        end
      end
    end
  end
end