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
    src = @source

    if @options[:use_erb]
      src = ERB.new(src, nil, '-').result
    end

    src = Lambchop::Utils.remove_shebang(src)
    config, src = Lambchop::Utils.parse_magic_comment(src)

    config['function_name'] ||= File.basename(@path, '.js')
    function_name = config['function_name']

    config['runtime'] ||= 'nodejs'

    create_or_update_function(config, src)

    exit if @options[:detach]

    trap(:INT) { exit } unless Lambchop::Utils.debug?
    Lambchop::WatchDog.start(function_name, @options[:watch_dog] || {})

    sleep
  end

  private

  def create_or_update_function(config, src)
    params = {}
    config.each {|k, v| params[k.to_sym] = v }
    buf, node_modules = zip_source(src)

    begin
      params[:code] = {:zip_file => buf.string}
      resp = @client.create_function(params)
    rescue Aws::Lambda::Errors::ResourceConflictException => e
      if e.message =~ /\AFunction already exist:/
        params = {
          :function_name => config['function_name'],
          :zip_file => buf.string
        }

        resp = @client.update_function_code(params)
      else
        raise e
      end
    end
    resp_h = {}

    [
      :function_name,
      :function_arn,
      :runtime,
      :role,
      :handler,
      :code_size,
      :description,
      :timeout,
      :memory_size,
      :last_modified,
    ].each do |key|
      resp_h[key] = resp[key]
    end

    $stderr.puts('Function was uploaded:')
    $stderr.puts(JSON.pretty_generate(resp_h))
    $stderr.puts('Node modules:')
    $stderr.puts(JSON.pretty_generate(node_modules))
  end

  def zip_source(src)
    src_dir = File.dirname(@path)
    node_modules = []

    Dir.glob("#{src_dir}/node_modules/**/*") do |file|
      if File.file?(file)
        node_modules << file
      end
    end

    buf = Zip::OutputStream.write_buffer do |out|
      out.put_next_entry(File.basename(@path))
      out.write(src)

      node_modules.each do |file|
        out.put_next_entry(file.sub(%r|\A#{src_dir}/|, ''))
        out.write(open(file, &:read))
      end
    end

    node_modules = node_modules.map {|file|
      file.sub(%r|\A#{src_dir}/|, '').split('/', 3)[1]
    }.uniq.sort

    [buf, node_modules]
  end
end
