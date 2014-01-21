require "#{File.dirname(__FILE__)}/../lib/secure_state.rb"
module RFM
  module Handlers
    class Streamer
      #TODO: add security
      def get_file(filename, security_key)
        RFM::SecureState.valid?(security_key)
        return File.read(filename)
      end
    end
  end
end