Thread::abort_on_exception = true

class Lambchop::WatchDog
  def self.start(function_name, options = {})
    self.new(function_name, options).start
  end

  def initialize(function_name, options = {})
    @function_name  = function_name
    @log_group_name = "/aws/lambda/#{@function_name}"
    @client         = options[:client] || Aws::CloudWatchLogs::Client.new(region: 'us-east-1')
    @start_time     = options[:start_time] || Time.now
    @out            = options[:out] || $stdout
    @last_timestamp = time_to_timestamp(@start_time) - 1
    @interval       = options[:interval] || 1
    @options        = options
  end

  def start
    @running = true

    Thread.start do
      while @running
        follow_logs
        sleep @interval
      end
    end
  end

  def stop
    @running = false
  end

  private

  def follow_logs
    all_events = []
    log_streams.each do |log_stream|
      last_ingestion_time = log_stream.last_ingestion_time

      if last_ingestion_time.nil? or last_ingestion_time < @last_timestamp
        next
      end

      log_events(log_stream.log_stream_name).each do |event|
        next if event.timestamp <= @last_timestamp
        all_events << event
      end
    end

    all_events.sort_by(&:timestamp).each do |event|
      @out.puts(event.message)
      @last_timestamp = event.timestamp
    end
  end

  def log_streams
    pages = @client.describe_log_streams(:log_group_name => @log_group_name)
    pages.map(&:log_streams).flatten(1)
  rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
    []
  end

  def log_events(log_stream_name)
    events = []

    pages = @client.get_log_events(
      :log_group_name  =>  @log_group_name,
      :log_stream_name => log_stream_name,
      :start_time      => @last_timestamp
    )

    pages.each do |page|
      break if page.events.empty?
      events.concat(page.events)
    end

    events
  end

  def time_to_timestamp(time)
    ts = time.to_i * 1000
    ts + time.usec / 1000
  end
end
