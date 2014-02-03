require 'streamable'

module RFM
  module Handlers
    class Mp3
      include Streamable

      #TODO: move this to a generic tag editor and delegate to that class
      def read_generic_file(file)
        TagLib::FileRef.open(file) do |fileref|
          tag = fileref.tag
        
          # Read basic attributes
          puts 'title: ' + tag.title.to_s   #=> "Wake Up"
          puts 'artist: ' + tag.artist.to_s  #=> "Arcade Fire"
          puts 'albulm: ' + tag.album.to_s   #=> "Funeral"
          puts 'year: ' + tag.year.to_s    #=> 2004
          puts 'track ' + tag.track.to_s   #=> 7
          puts 'genre ' + tag.genre.to_s   #=> "Indie Rock"
          puts 'comment ' +tag.comment.to_s #=> nil
        
          properties = fileref.audio_properties
          puts 'prop.length ' + properties.length.to_s  #=> 335 (song length in seconds)
        end
      end
      
      def get_tags(file)
        tags = {}
        TagLib::MPEG::File.open(file) do |fh|
          properties = fh.audio_properties
          tag = fh.id3v2_tag
          tags = {:timestamp=>File.mtime(file).to_s,
                  :title    => tag.title,
                  :artist   => tag.artist,
                  :album    => tag.album,
                  :year     => tag.year == 0 ? nil : tag.year, #taglib return 0 if no year frame found
                  :track    => tag.track == 0? nil : tag.track,#taglib return 0 if no track frame found
                  :genre    => tag.genre,
                  :comment  => tag.comment,
                  :length   => properties.length}
        
          # Attached picture frame
          cover = tag.frame_list('APIC').first
          if cover
            tags[:apic] = {:mime_type=>cover.mime_type, :pic=>cover.picture}
          end
        end
        return {file => tags}
      end

      #TODO: Remove all v1,v2 tags before save new. Only save v2 tag. If a tag is blank, remove it 
      def set_tags(file, tags)
        ret = {file => false}
        TagLib::MPEG::File.open(file) do |fh|
          if File.mtime(file).to_s == tags['timestamp']#only write if file has not been modified
            tag = fh.id3v2_tag
            tags.each do |id, value|
              if tags[id] != nil && ['title', 'artist', 'year', 'track', 'album', 'genre', 'comment'].include?(id)
                if tags[id].strip.empty?
                  tags[id] = nil
                end
              end
            end

            tag.title  = tags['title']
            tag.artist = tags['artist']
            tag.album  = tags['album']
            tag.year   = tags['year'].to_i  #taglib doesnt allow set year to nil
            tag.track  = tags['track'].to_i #taglib doesnt allow set track to nil
            tag.genre  = tags['genre']
            tag.comment= tags['comment']

            tags.delete_if{|k,v| k != 'file'} #to return only the filename and save status
            ret[file] = fh.save(TagLib::MPEG::File::ID3v2) #only save v2, v1 will be stripped
          end
        end
        return ret
      end
    end
  end
end