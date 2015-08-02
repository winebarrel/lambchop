class Lambchop::Cat
  def self.cat(function_name, invoke_args, options = {})
    self.new(function_name, invoke_args, options).cat
  end

  def initialize(function_name, invoke_args, options = {})
    @function_name = function_name
    @invoke_args   = invoke_args
    @client        = options[:client] || Aws::Lambda::Client.new
    @out           = options[:out] || $stdout
    @options       = options
  end

  def cat
    invoke_args = @invoke_args

    if invoke_args.kind_of?(IO)
      invoke_args = invoke_args.read
    end

    resp = @client.invoke(
      :function_name => @function_name,
      :payload => invoke_args,
      :invocation_type => Lambchop::Utils.camelize(@options[:invocation_type] || :request_response),
      :log_type => Lambchop::Utils.camelize(@options[:log_type] || :none)
    )

    out = {
      'status_code' => resp[:status_code],
      'function_error' => resp[:function_error],
      'payload' => nil
    }

    log_result = resp[:log_result]
    payload = resp[:payload]

    if log_result
      log_result = Base64.strict_decode64(log_result)
      log_result.gsub!("\t", '    ').gsub!(/\s+\n/, "\n").strip!
      def log_result.yaml_style() Psych::Nodes::Scalar::LITERAL end
      out['log_result'] = log_result
    end

    if payload
      payload_string = payload.string
      out['payload'] = JSON.parse(payload_string) rescue payload_string
    end

    @out.puts YAML.dump(out)
  end
end
