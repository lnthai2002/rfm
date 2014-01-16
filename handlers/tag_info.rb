#require "mp3info"
module RFM
  module Handlers
    module TagInfo
      USEFULL_TAGS = ['title', 'artist', 'album', 'tracknum', 'genre', 'comments']
      def tag_of(file)
        Mp3Info.open(file, :encoding => 'utf-8') do |mp3info|
          byebug
          return mp3info.tag
        end
      end
    end
  end
end