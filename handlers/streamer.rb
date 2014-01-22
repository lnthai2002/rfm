module RFM
  module Handlers
    class Streamer
      def get_file(filename, security_key)
        RFM::Lib::SecureState.valid?(security_key)
        return File.read(filename)
      end
    end
  end
end