require 'taglib'
class Handlers::TagWriter
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