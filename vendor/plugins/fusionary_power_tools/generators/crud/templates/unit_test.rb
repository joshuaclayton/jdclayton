require File.dirname(__FILE__) + '/../test_helper'

class <%= class_name %>Test < Test::Unit::TestCase
  fixtures :<%= table_name %>
  
  def test_should_exist
    assert_kind_of <%= class_name %>, <%= table_name %>(:first)
  end
end
