require File.dirname(__FILE__) + '/../test_helper'

class <%= controller_class_name %>ControllerTest < Test::Unit::TestCase
  fixtures :<%= table_name %>
  
  def test_should_list_<%= table_name %>
    get :index
    assert_success
    assert_assigned :<%= table_name %>
    assert_links_to "/<%= table_name %>/new", "Create"
    #assert_links_to "/<%= table_name %>/1", "<%= class_name %> 1"
  end
  
  def test_should_show_new_form
    get :new
    assert_success
    assert_assigned :<%= file_name %>
    assert_post_form "/<%= table_name %>"
    assert_submit "/<%= table_name %>", "Create"
    #assert_input "/<%= table_name %>", :text, "<%= file_name %>[attribute]"
  end
  
  def test_should_create_<%= file_name %>
    assert_changed_by 1, <%= class_name %>, :count do
      post :create, :<%= file_name %> => new_<%= file_name %>
    end
    assert_redirected_to :action => "show"
  end
  
  def test_should_require_post_method_to_create_<%= file_name %>
    assert_not_changed <%= class_name %>, :count do
      get :create, :<%= file_name %> => new_<%= file_name %>
    end
    assert_redirected_to :action => "index"
  end
  
  def test_should_show_<%= file_name %>
    get :show, :id => <%= table_name %>(:first).id
    assert_success
    assert_assigned :<%= file_name %>, <%= table_name %>(:first)
    assert_links_to "/<%= table_name %>/1;edit", "Edit"
    assert_links_to "/<%= table_name %>/1", "Destroy"
  end
  
  def test_should_show_edit_form
    get :edit, :id => <%= table_name %>(:first).id
    assert_success
    assert_assigned :<%= file_name %>, <%= table_name %>(:first)
    assert_put_form "/<%= table_name %>/1"
    assert_submit "/<%= table_name %>/1", "Update"
    #assert_input "/<%= table_name %>/1", :text, "<%= file_name %>[attribute]"
  end
  
  def test_should_update_<%= file_name %>
    put :update, :id => <%= table_name %>(:first).id, :<%= file_name %> => new_<%= file_name %>
    assert_redirected_to :action => "show"
    # <%= table_name %>(:first).reload
    # assert_equal new_<%= file_name %>[:attribute], <%= table_name %>(:first).attribute
  end
  
  def test_should_require_put_method_to_update_<%= file_name %>
    get :update, :id => <%= table_name %>(:first).id, :<%= file_name %> => new_<%= file_name %>
    assert_redirected_to :action => "index"
  end
  
  def test_should_destroy_<%= file_name %>
    assert_changed_by -1, <%= class_name %>, :count do
      delete :destroy, :id => <%= table_name %>(:first).id
    end
    assert_redirected_to :action => "index"
  end
  
  def test_should_require_delete_method_to_destroy_<%= file_name %>
    assert_not_changed <%= class_name %>, :count do
      get :destroy, :id => <%= table_name %>(:first).id
    end
    assert_redirected_to :action => "index"
  end
  
  protected
  
    def new_<%= file_name %>
      {
        # :attribute => "Value"
      }
    end
end