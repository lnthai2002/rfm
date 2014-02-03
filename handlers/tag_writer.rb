module RFM
  module Handlers
    class TagWriter
      def write_mp3(file, tags)
        ret = {file => false}
        TagLib::MPEG::File.open(file) do |fh|
          if File.mtime(file).to_s == tags['timestamp']#only write if file has not been modified
            tag = fh.id3v2_tag
            tag.title  = tags['title']
            tag.artist = tags['artist']
            tag.album  = tags['album']
            tag.year   = tags['year'].to_i
            tag.track  = tags['track'].to_i
            tag.genre  = tags['genre']
            tag.comment= tags['comment']

            tags.delete_if{|k,v| k != 'file'} #to return only the filename and save status
            ret[file] = fh.save
          end
        end
        return ret
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