class Lambchop::Client
  def self.start(source, path)
    self.new(source, path).start
  end

  def initialize(source, path)
    @source = source
    @path = path
  end

  def start
    p @source
    p @path
  end
end
