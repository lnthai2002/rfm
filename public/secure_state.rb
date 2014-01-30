module RFM
  module Public
    #Any class exposed to public must extend this class to be safer
    class SecureState
      @security_key = nil #to be injected by server init script
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

      #Call valid? before executing the declared methods
      #Method to be intercepted must have security key as its 1st argument 
      def self.intercept_and_secure(*syms, &block)
        syms.each do |sym|
          backup_method = "__#{sym}__bkup__"
          unless private_instance_methods.include?(backup_method)
            alias_method backup_method, sym     #backup original method
            private backup_method               #make backup private
            define_method sym do |*args|        #replace method
              #security check, assuming the first param is always the security key
              RFM::Public::SecureState.valid?(args[0])

              result = __send__ backup_method, *args    #execute original method
              if block
                block.call(self,                        #and the block
                  :method => sym, 
                  :args => args,
                  :return => result
                )
              end
              result
            end
          end
        end
      end
    end
  end
end