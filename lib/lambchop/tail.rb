class Lambchop::Tail
  def self.tail(function_name, options = {})
    self.new(function_name, options).tail
  end

  def initialize(function_name, options = {})
    @function_name = function_name
    @options       = options
  end

  def tail
    Lambchop::WatchDog.start(@function_name, @options)
    sleep
  end
end
