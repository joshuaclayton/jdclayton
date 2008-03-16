require "test_help"

# Useful test helpers.
#
# Many have been looted from stellar test code seen in applications by technoweenie,
# zenspider, and topfunky.
class Fusionary::Test::TestCase < Test::Unit::TestCase  
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Work around a bug in test/unit caused by the default test being named
  # as a symbol (:default_test), which causes regex test filters
  # (like "ruby test.rb -n /foo/") to fail because =~ doesn't work on
  # symbols.
  def initialize(name) #:nodoc:
    super(name.to_s)
  end
  
  # Work around test/unit's requirement that every subclass of TestCase have
  # at least one test method. Note that this implementation extends to all
  # subclasses, as well, so subclasses of IntegrationTest may also exist
  # without any test methods.
  def run(*args) #:nodoc:
    return if @method_name == "default_test"
    super   
  end
  
  def assert_creates_file(path)
    assert !File.exists?(path), "#{path} should not exist"
    yield if block_given?
    assert File.exists?(path), "#{path} should have been created"
  end
  
  def assert_deletes_file(path)
    assert File.exists?(path), "#{path} should exist"
    yield if block_given?
    assert !File.exists?(path), "#{path} should have been deleted"
  end
  
  # http://project.ioni.st/post/217#post-217
  # and http://blog.caboo.se/articles/2006/06/13/a-better-assert_difference
  #
  #  def test_new_publication
  #    assert_changed_by 1, Publication, :count do
  #      post :create, :publication => {...}
  #      # ...
  #    end
  #  end
  # 
  # Is the number of items different?
  #
  # Can be used for increment and decrement.
  #
  # You can also send an array of class contants to check against.
  def assert_changed_by(difference, object, method)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference, object.send(method)
  end

  def assert_not_changed(object, method, &block)
    assert_changed_by 0, object, method, &block
  end
  
  ##
  # The opposite of an assert.
  #
  #  deny world.flat?, "A round world was expected, but it was found to be flat."
  def deny(condition, msg = nil)
    assert ! condition, msg
  end
  
  ##
  # Alias for assert_not_equal

  def deny_equal(*args)
    assert_not_equal(args)
  end

  ##
  # Asserts that +obj+ responds to #empty? and #empty? returns false.

  def deny_empty(obj)
    assert_respond_to obj, :empty?
    assert_equal false, obj.empty?
  end

  ##
  # Asserts that +obj+ responds to #include? and that obj includes +item+.

  def assert_includes(obj, item, message = nil)
    assert_respond_to obj, :include?
    assert_equal true, obj.include?(item), message
  end

  ##
  # Asserts that +obj+ responds to #include? and that obj does not include
  # +item+.

  def deny_includes(obj, item, message = nil)
    assert_respond_to obj, :include?
    assert_equal false, obj.include?(item), message
  end

end