require 'minitest/autorun'

class Id58TestBase < MiniTest::Test

  def initialize(arg)
    @_test_id58 = nil
    @_test_name58 = nil
    super
  end

  @@args = (ARGV.sort.uniq - ['--']).map(&:upcase) # eg 2E4
  @@seen_ids = []
  @@timings = {}

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.test(id58_suffix, *lines, &test_block)
    src = test_block.source_location
    src_file = File.basename(src[0])
    src_line = src[1].to_s
    id58 = checked_id58(id58_suffix, lines)
    if @@args === [] || @@args.any?{ |arg| id58.include?(arg) }
      name58 = lines.join(space = ' ')
      execute_around = lambda {
        _id58_setup_caller(id58, name58)
        begin
          t1 = Time.now
          self.instance_eval(&test_block)
          t2 = Time.now
          @@timings[id58+':'+src_file+':'+src_line+':'+name58] = (t2 - t1)
        ensure
          puts $!.message unless $!.nil?
          _id58_teardown_caller
        end
      }
      name = "id58 '#{id58_suffix}',\n'#{name58}'"
      define_method("test_\n#{name}".to_sym, &execute_around)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  # :nocov:
  ObjectSpace.define_finalizer(self, proc {
    slow = @@timings.select{ |_name,secs| secs > 0.000 }
    sorted = slow.sort_by{ |name,secs| -secs }.to_h
    size = sorted.size < 5 ? sorted.size : 5
    puts
    puts "Slowest #{size} tests are..." if size != 0
    sorted.each_with_index { |(name,secs),index|
      puts "%3.4f - %-72s" % [secs,name]
      break if index == size
    }
    puts
  })
  # :nocov:

  # - - - - - - - - - - - - - - - - - - - - - -

  def self.checked_id58(id58_suffix, lines)
    method = 'def self.hex_prefix'
    pointer = ' ' * method.index('.') + '!'
    pointee = (['',pointer,method,'','']).join("\n")
    pointer.prepend("\n\n")
    raise "#{pointer}missing#{pointee}" unless respond_to?(:id58_prefix)
    raise "#{pointer}empty#{pointee}" if id58_prefix === ''
    raise "#{pointer}not id58#{pointee}" unless id58_prefix =~ /^[0-9A-F]+$/ # TODO

    method = "test '#{id58_suffix}',"
    pointer = ' ' * method.index("'") + '!'
    proposition = lines.join(space = ' ')
    pointee = ['',pointer,method,"'#{proposition}'",'',''].join("\n")
    id58 = id58_prefix + id58_suffix
    pointer.prepend("\n\n")
    raise "#{pointer}empty#{pointee}" if id58_suffix === ''
    raise "#{pointer}not id58#{pointee}" unless id58_suffix =~ /^[0-9A-F]+$/
    raise "#{pointer}duplicate#{pointee}" if @@seen_ids.include?(id58)
    raise "#{pointer}overlap#{pointee}" if id58_prefix[-2..-1] === id58_suffix[0..1]
    @@seen_ids << id58
    id58
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def _id58_setup_caller(id58, name58)
    ENV['TEST_ID58'] = id58
    @_test_id58 = id58
    @_test_name58 = name58
    id58_setup
  end

  def _id58_teardown_caller
    id58_teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id58_setup
  end

  def id58_teardown
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def test_id58
    @_test_id58
  end

  # :nocov:
  def test_name58
    @_test_name58
  end
  # :nocov:

end
