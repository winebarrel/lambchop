class Lambchop::Dump
  def self.dump(function_name, options = {})
    self.new(function_name, options).dump
  end

  def initialize(function_name, options = {})
    @function_name = function_name
    @client        = options[:client] || Aws::Lambda::Client.new
    @out           = options[:out] || $stdout
    @options       = options
  end

  def dump
    page = @client.get_function(:function_name => @function_name).first
    puts_shebang
    puts_magic_comment(page.configuration)
    puts_source(page.code.location)
  end

  def puts_shebang
    @out.puts('#!/usr/bin/env lambchop')
  end

  def puts_magic_comment(configuration)
    comment_attrs = {}

    %w(
      function_name
      runtime
      role
      handler
      mode
      description
      timeout
      memory_size
    ).each do |name|
      comment_attrs[name] = configuration.send(name)
    end

    yaml = YAML.dump(comment_attrs).sub(/\A---\n/, '')
    @out.puts("/*\n#{yaml}*/")
  end

  def puts_source(location)
    Lambchop::Utils.open_source(location) do |src|
      @out.puts(src)
    end
  end
end
