class Lambchop::Client
  def self.start(source, path)
    self.new(source, path).start
  end

  def initialize(source, path)
    @source = source
    @path = path
  end

  def start
    src = remove_shebang(@source)
    magic_comment = parse_magic_comment(src)
    p magic_comment
    p src
  end

  private

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
    YAML.load(comment)
  end
end
