require "#{File.dirname(__FILE__)}/secure_state.rb"

module RFM
  module Lib
    class DiskCrawler
      def scan_and_process_files(top_dir, handler, recursive=false, security_key, &block)
        RFM::SecureState.valid?(security_key)

        top_dir = top_dir.chomp("/")
        if not File.exist?(top_dir)
          raise ArgumentError, "Folder #{top_dir} does not exist!"
        else
          results = Array.new
          craw(top_dir, handler, recursive){|file|
            results << block.call(file)
          }
          return results
        end
      end

      private

      def craw(node, handler, recursive=false, &block)
        if File.directory?(node)
          Dir.new(node).each do |name|
            if name !~ /^\./ #exclude hidden, current, parent directories
              if recursive
                craw("#{node}/#{name}", handler, recursive, &block)
              else
                if !File.directory?("#{node}/#{name}")
                  yield "#{node}/#{name}"
                end
              end
            end
          end
        else #file
          yield node
        end
      end
    end
  end
end