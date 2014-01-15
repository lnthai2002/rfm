require 'taglib'
module Darkportal
  module Handlers
    class TagReader
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
      
      def process(file)
        tags = {}
        TagLib::MPEG::File.open(file) do |fh|
          properties = fh.audio_properties
          tag = fh.id3v2_tag
          tags = {:title  => tag.title,
                  :artist => tag.artist,
                  :albulm => tag.album,
                  :year   => tag.year,
                  :track  => tag.track,
                  :genre  => tag.genre,
                  :comment=> tag.comment,
                  :length => properties.length
                  }
        
          # Attached picture frame
          cover = tag.frame_list('APIC').first
          if cover
            tags[:apic] = {:mime_type=>cover.mime_type, :pic=>cover.picture}
          end
        end
        return tags
      end
    end
  end
end