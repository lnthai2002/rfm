module Darkportal
  class DiskCrawler
    def scan_and_process_files(top_dir, handler)
      if not File.exist?(top_dir)
        raise "Folder #{top_dir} does not exist!"
      else
        top_dir = top_dir.chomp("/")
        ret = []
        res = craw(top_dir, handler, ret)
        byebug
        return res
      end
    end
    
    def craw(node, handler, ret)
      if File.directory?(node)
        puts "Dir: #{node}"
        Dir.new(node).each do |name|
          if name !~ /^\./ #no hidden, no current, no parent directories
            path = "#{node}/#{name}"
            craw(path, handler,ret)
          end
        end
      else #file
        ret << handler.process(node)
      end
      return ret
    end
  end
end