class Lambchop::Diff
  def self.diff(function_name, file, options = {})
    self.new(function_name, file, options).diff
  end

  def initialize(function_name, file, options = {})
    @function_name = function_name
    @file          = file
    @client        = options[:client] || Aws::Lambda::Client.new
    @out           = options[:out] || $stdout
    @options       = options
  end

  def diff
    file = @file

    if file.kind_of?(IO)
      file = file.read
    end

    file = Lambchop::Utils.remove_shebang(file)
    config, file = Lambchop::Utils.parse_magic_comment(file)

    page = @client.get_function(:function_name => @function_name).first

    Lambchop::Utils.open_source(page.code.location) do |func|
      @out.puts(Diffy::Diff.new(func, file))
    end
  end
end
