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

    Lambchop::Utils.open_source(page.code.location) do |name, func|
      @out.puts("--- #{@function_name}:#{name}")
      @out.puts("+++ #{@file.path}")
      diff = Diffy::Diff.new(func, file, :include_diff_info => true).to_s
      @out.puts(diff.each_line.to_a.slice(2..-1).join)
    end
  end
end
