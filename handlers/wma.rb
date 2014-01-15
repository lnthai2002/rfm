class Handlers::Wma
  def process(file)
    if file =~ /\.wma$/
        puts file
    end
  end
end