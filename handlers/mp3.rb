require './tag_info.rb'
class Handlers::Mp3
  include TagInfo

  def initialize(logger)
    @log = logger
  end
  
  #Extract mp3 tags and store in DB
  def process(file)
    byebug
    if file =~ /\.mp3$/
      begin
        tag = tag_of(file)

        if tag.title.blank?
          tag.title = File.base_name(file, '.mp3')
        end

        tag.delete_if{|key, val| not (TagInfo::USEFULL_TAGS.include?(key))} #only take valid tag
        tag[:location] = file

        song = Song.new(tag)
        song.save!
      rescue Exception=>e
        @log.error(e) #and silently continue
      end
    end
  end
end