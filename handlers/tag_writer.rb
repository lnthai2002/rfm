require "#{File.dirname(__FILE__)}/../lib/secure_state.rb"
require 'taglib'
$SAFE=1
module RFM
  module Handlers
    class TagWriter
      def write_mp3(files, security_key)
        RFM::SecureState.valid?(security_key)
        files.each do |file|
          TagLib::MPEG::File.open(file['file']) do |fh|
            if File.mtime(file['file']).to_s == file['timestamp']#only write if file has not been modified
              tag = fh.id3v2_tag
              tag.title  = file['title']
              tag.artist = file['artist']
              tag.album  = file['album']
              tag.year   = file['year'].to_i
              tag.track  = file['track'].to_i
              tag.genre  = file['genre']
              tag.comment= file['comment']

              file.delete_if{|k,v| k != 'file'} #to return only the filename and save status
              file['saved'] = fh.save
            end
          end
        end
        return files
      end

      def write_tags(file, tags)
        # tags v2 will be read and written according to the :encoding settings
        mp3 = Mp3Info.open(file, :encoding => 'utf-8')
        
        Mp3Info.open(file, :encoding => 'utf-8') do |mp3|
          # you can access four letter v2 tags like this
          puts mp3.tag2.TIT2
          mp3.tag2.TIT2 = "new TIT2"
          # or like that
          mp3.tag2["TIT2"]
          # at this time, only COMM tag is processed after reading and before writing
          # according to ID3v2#options hash
          mp3.tag2.options[:lang] = "FRE"
          mp3.tag2.COMM = "my comment in french, correctly handled when reading and writing"
        end
      end
    end
  end
end