class Lambchop::Client
  def self.start(source, path, options = {})
    self.new(source, path, options).start
  end

  def initialize(source, path, options = {})
    @source  = source
    @path    = path
    @client  = options[:client] || Aws::Lambda::Client.new
    @options = options
  end

  def start
    src = remove_shebang(@source)
    config, src = parse_magic_comment(src)

    config['function_name'] ||= File.basename(@path, '.js')
    function_name = config['function_name']

    config['mode']    ||= 'event'
    config['runtime'] ||= 'nodejs'

    resp = upload_function(config, src)
    $stderr.puts('Function was uploaded:')
    $stderr.puts(JSON.pretty_generate(resp.to_h))

    exit if @options[:detach]

    Lambchop::WatchDog.start(function_name, @options[:watch_dog] || {})

    sleep
  end

  private

  def upload_function(config, src)
    params = {}
    config.each {|k, v| params[k.to_sym] = v }
    params[:function_zip] = zip_source(src).string
    @client.upload_function(params)
  end

  def zip_source(src)
    src_dir = File.dirname(@path)
    node_modules = []

    Dir.glob("#{src_dir}/node_modules/**/*") do |file|
      if File.file?(file)
        node_modules << file
      end
    end

    Zip::OutputStream.write_buffer do |out|
      out.put_next_entry(File.basename(@path))
      out.write(src)

      node_modules.each do |file|
        out.put_next_entry(file.sub(%r|\A#{src_dir}/|, ''))
        out.write(open(file, &:read))
      end
    end
  end

  def remove_shebang(src)
    src.sub(/\A#![^\n]*\n/, '')
  end

  def parse_magic_comment(src)
    ss = StringScanner.new(src)

    unless ss.scan(%r|\A\s*/\*|)
      raise 'Cannot find magic comment'
    end

    unless comment = ss.scan_until(%r|\*/|)
      raise 'Cannot find magic comment'
    end

    comment.sub!(%r|\*/\z|, '')

    [YAML.load(comment), ss.rest.sub(/\A\n/, '')]
  end
end
