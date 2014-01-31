module RFM
  module Handlers
    module Streamable
      def get_file(filename, security_key)
        return File.read(filename)
      end
    end
  end
end