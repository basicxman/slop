require File.dirname(__FILE__) + '/helper'

class OptionTest < TestCase
  def option(*args, &block)
    Slop.new.option(*args, &block)
  end

  def option_with_argument(*args, &block)
    options = args.shift
    slop = Slop.new
    option = slop.opt(*args)
    slop.parse(options)
    slop.find {|opt| opt.key == option.key }
  end

  def option_value(*args, &block)
    option_with_argument(*args, &block).argument_value
  end

  test 'expects an argument if argument is true' do
    assert option(:f, :foo, 'foo', true).expects_argument?
    assert option(:f, :argument => true).expects_argument?

    refute option(:f, :foo).expects_argument?
  end

  test 'accepts an optional argument if optional is true' do
    assert option(:f, :optional => true).accepts_optional_argument?
    assert option(:f, false, :optional => true).accepts_optional_argument?

    refute option(:f, true).accepts_optional_argument?
  end

  test 'has a callback when passed a block or callback option' do
    assert option(:f){}.has_callback?
    assert option(:callback => proc {}).has_callback?

    refute option(:f).has_callback?
  end

  test 'splits argument_value with :as => array' do
    assert_equal %w/lee john bill/, option_value(
      %w/--people lee,john,bill/, :people, true, :as => Array
    )

    assert_equal %w/lee john bill/, option_value(
      %w/--people lee:john:bill/,
      :people, true, :as => Array, :delimiter => ':'
    )

    assert_equal ['lee', 'john,bill'], option_value(
      %w/--people lee,john,bill/,
      :people, true, :as => Array, :limit => 2
    )

    assert_equal ['lee', 'john:bill'], option_value(
      %w/--people lee:john:bill/,
      :people, true, :as => Array, :limit => 2, :delimiter => ':'
    )
  end

  test 'returns a symbol with :as => Symbol' do
    assert_equal :foo, option_value(%w/--name foo/, :name, true, :as => Symbol)
  end

  test 'returns an integer with :as => Integer' do
    assert_equal 30, option_value(%w/--age 30/, :age, true, :as => Integer)
  end

  test 'printing options' do
    slop = Slop.new
    slop.opt :n, :name, 'Your name', true
    slop.opt :age, 'Your age', true
    slop.opt :V, 'Display the version'

    assert_equal "    -n, --name      Your name", slop.options[:name].to_s
    assert_equal "        --age       Your age", slop.options[:age].to_s
    assert_equal "    -V,             Display the version", slop.options[:V].to_s
  end
end
