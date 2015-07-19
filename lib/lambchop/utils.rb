class Lambchop::Utils
  class << self
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

    def open_source(location)
      open(location) do |f|
        Zip::InputStream.open(f) do |zis|
          while entry = zis.get_next_entry
            next if entry.name =~ %r|\Anode_modules/|
            yield(entry.name, entry.get_input_stream.read)
          end
        end
      end
    end

    def with_error_logging
      begin
        yield
      rescue => e
        if debug?
          raise e
        else
          $stdout.puts("[ERROR] #{e.message}")
        end
      end
    end

    def camelize(obj)
      obj.to_s.gsub(/(?:\A|_)([a-z])/) { $1.upcase }
    end

    def debug?
      ENV['DEBUG'] == '1'
    end
  end # of class methods
end
