require 'disk_crawler'
require 'tag_writer'
require 'tag_reader'
require 'streamer'
$SAFE=1
module RFM
  module Public
    #TODO: hook a call to check valid? for each method
    class FileSystem < SecureState
      def find_mp3(folder, recursive=false, security_key)
        RFM::Public::SecureState.valid?(security_key)
        
        folder = folder.chomp("/")
        
        if not File.realpath(folder).start_with?(CONFIG['top_dir'])
          raise ArgumentError, "#{folder} is not a subdirectory of the folder being exposed!"
        else
          crawler = RFM::Lib::DiskCrawler.new
          tag_reader = RFM::Handlers::Mp3TagEditor.new
          return crawler.scan_and_process_files(folder, tag_reader, recursive){|file|
            tag_reader.get_tags(file)
          }
        end
      end

      def write_mp3_tags(files, security_key)
        RFM::Public::SecureState.valid?(security_key)
        tag_writer = RFM::Handlers::Mp3TagEditor.new
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

      def get_audio_file(filename, security_key)
        RFM::Public::SecureState.valid?(security_key)
        if not File.realpath(filename).start_with?(CONFIG['top_dir'])
          raise ArgumentError, "#{file} is not in the folder being exposed!"
        else
          streamer = RFM::Handlers::Streamer.new
          return streamer.get_file(filename, security_key)
        end
      end
    end
  end
end