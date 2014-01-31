require 'disk_crawler'
require 'mp3'
#$SAFE=1
module RFM
  module Public
    class FileSystem < SecureState
      def find_mp3(security_key, folder, recursive=false)
        folder = folder.chomp("/")
        
        if not File.realpath(folder).start_with?(CONFIG['top_dir'])
          raise ArgumentError, "#{folder} is not in the folder being exposed!"
        else
          crawler = RFM::Lib::DiskCrawler.new
          tag_reader = RFM::Handlers::Mp3.new
          return crawler.scan_and_process_files(folder, tag_reader, recursive){|file|
            tag_reader.get_tags(file)
          }
        end
      end

      def write_mp3_tags(security_key, files)
        tag_writer = RFM::Handlers::Mp3.new
        results = Hash.new
        files.each do |file, tags|
          if not File.realpath(file).start_with?(CONFIG['top_dir'])
            raise ArgumentError, "#{file} is not in the folder being exposed!"
          else
            results.merge!(tag_writer.set_tags(file, tags))
          end
        end
        return results
      end

      def get_mp3_file(security_key, filename)
        if not File.realpath(filename).start_with?(CONFIG['top_dir'])
          raise ArgumentError, "#{file} is not in the folder being exposed!"
        else
          streamer = RFM::Handlers::Mp3.new
          return streamer.get_file(filename, security_key)
        end
      end

      #this must be at the end because methods to be intercepted must be defined above
      intercept_and_secure :find_mp3, :write_mp3_tags, :get_mp3_file
    end
  end
end