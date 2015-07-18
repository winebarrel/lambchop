class Lambchop::Cat
  def self.cat(function_name, invoke_args, options = {})
    self.new(function_name, invoke_args, options).cat
  end

  def initialize(function_name, invoke_args, options = {})
    @function_name = function_name
    @invoke_args   = invoke_args
    @client        = options[:client] || Aws::Lambda::Client.new
    @options       = options
  end

  def cat
    invoke_args = @invoke_args

    if invoke_args.kind_of?(IO)
      invoke_args = invoke_args.read
    end

    p @client.invoke(
      :function_name => @function_name,
      :payload => invoke_args
    )
  end
end
