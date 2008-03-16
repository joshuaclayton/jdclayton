class Fusionary::Test::FunctionalTestCase < Fusionary::Test::TestCase
  include ViewTestHelper
  
  DEFAULT_ASSIGNS = %w[
    action_name before_filter_chain_aborted cookies flash headers
    ignore_missing_templates loggedin_user logger params request
    request_origin response session template template_class template_root url
    user variables_added
  ]
  
  NOTHING = Object.new

  def setup
      return if self.class.name =~ /TestCase$/

      @controller_class_name ||= self.class.name.sub 'Test', ''
      @controller_class = Object.path2class @controller_class_name

      raise "Can't determine controller class for #{self.class}" if @controller_class.nil?

      @controller = @controller_class.new
      @controller_class.send(:define_method, :rescue_action) { |e| raise e }

      @session = ActionController::TestSession.new

      @flash = ActionController::Flash::FlashHash.new
      @session['flash'] = @flash

      @request = ActionController::TestRequest.new
      @request.session = @session

      @response = ActionController::TestResponse.new

      @deliveries = []
      ActionMailer::Base.deliveries = @deliveries

      # used by util_audit_assert_assigns
      @assigns_asserted = []
      @assigns_ignored ||= [] # untested assigns to ignore
  end
  
  def reset!(*instance_vars)
    instance_vars = [:controller, :request, :response] unless instance_vars.any?
    instance_vars.collect! { |v| "@#{v}".to_sym }
    instance_vars.each do |var|
      instance_variable_set(var, instance_variable_get(var).class.new)
    end
  end
  
  ##
  # Flash accessor.  The flash can be assigned to before calling process or
  # render and it will Just Work (yay!)
  #
  # view:
  #   <div class="error"><%= flash[:error] %></div>
  #
  # test:
  #   flash[:error] = 'You did a bad thing.'
  #   render
  #   assert_tag :tag => 'div', :attributes => { :class => 'error' },
  #              :content => 'You did a bad thing.'

  attr_reader :flash

  ##
  # Session accessor.  The session can be assigned to before calling process
  # or render and it will Just Work (yay!)
  #
  # test:
  #
  #   def test_logout
  #     session[:user] = users(:herbert)
  #     post :logout
  #     assert_equal nil, session[:user]
  #   end

  attr_reader :session
  
  def login_as(user)
    session[:user] = user ? users(user).id : nil
  end
  
  def logout
    login_as nil
  end
  
  # Assert the block redirects to the login
  # 
  #   assert_requires_login(:bob) { get :edit, :id => 1 }
  #
  def assert_requires_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  # Assert the block accepts the login
  # 
  #   assert_accepts_login(:bob) { get :edit, :id => 1 }
  #
  # Accepts anonymous logins:
  #
  #   assert_accepts_login { get :list }
  #
  def assert_accepts_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_response :success
  end
  
  ##
  # Asserts that the assigns variable +ivar+ is assigned to +value+. If
  # +value+ is omitted, asserts that assigns variable +ivar+ exists.

  def assert_assigned(ivar, value = NOTHING)
    ivar = ivar.to_s
    @assigns_asserted << ivar
    assert_includes assigns, ivar, "#{ivar.inspect} missing from assigns"
    assert_equal value, assigns[ivar] unless value.equal? NOTHING
  end

  ##
  # Asserts that the assigns variable +ivar+ is not set.

  def deny_assigned(ivar)
    deny_includes assigns, ivar
  end
  
  ##
  # Asserts the response content type matches +type+.

  def assert_content_type(type, message = nil)
    assert_equal type, @response.headers['Content-Type'], message
  end
  
  ##
  # Asserts that +key+ of flash has +content+. If +content+ is a Regexp, then
  # the assertion will fail if the Regexp does not match.
  #
  # controller:
  #   flash[:notice] = 'Please log in'
  #
  # test:
  #   assert_flash :notice, 'Please log in'

  def assert_flash(key, content)
    assert flash.include?(key),
           "#{key.inspect} missing from flash, has #{flash.keys.inspect}"

    case content
    when Regexp then
      assert_match content, flash[key],
                   "Content of flash[#{key.inspect}] did not match"
    else
      assert_equal content, flash[key],
                   "Incorrect content in flash[#{key.inspect}]"
    end
  end
  
  # Compares a regular expression to the body text returned by a functional test.
  #
  #  assert_match_body /<doctype/
  def assert_match_body(regex)
    assert_match regex, @response.body
  end
  
  def assert_no_match_body(regex)
    assert_no_match regex, @response.body
  end
  
  def assert_match_headers(header, regex)
    assert_match regex, @response.headers[header]
  end
  
  ##
  # Checks your assert_assigned tests against the instance variables in
  # assigns. Fails if the two don't match.
  #
  # Add util_audit_assert_assigned to your teardown. If you have instance
  # variables that you don't need to set (for example, were set in a
  # before_filter in ApplicationController) then add them to the
  # @assigns_ignored instance variable in your setup.
  #
  # = Example
  #
  # == Controller method
  #
  #   class UserController < ApplicationController
  #     def new
  #       # ...
  #
  #       @login_form = false
  #     end
  #   end
  #
  # == Test setup:
  #
  #   class UserControllerTest < Test::Rails::ControllerTestCase
  #     
  #     def teardown
  #       super
  #       util_audit_assert_assigned
  #     end
  #     
  #     def test_new
  #       get :new
  #       
  #       assert_response :success
  #       # no assert_assigns for @login_form
  #     end
  #     
  #   end
  #
  # == Output
  #     1) Failure:
  #   test_new(UserControllerTest)
  #       [[...]/controller_test_case.rb:331:in `util_audit_assert_assigned'
  #        [...]/user_controller_test.rb:14:in `teardown_without_fixtures'
  #        [...]fixtures.rb:555:in `teardown']:
  #   You are missing these assert_assigned assertions:
  #       assert_assigned :login_form #, some_value
  #   .

  def util_audit_assert_assigned
    return unless @controller.send :performed?
    all_assigns = assigns.keys.sort

    assigns_ignored = DEFAULT_ASSIGNS | @assigns_ignored

    assigns_created = all_assigns - assigns_ignored
    assigns_asserted = @assigns_asserted - assigns_ignored

    assigns_created = assigns_created
    assigns_asserted = assigns_asserted

    assigns_missing = assigns_created - assigns_asserted

    return if assigns_missing.empty?

    message = []
    message << "You are missing these assert_assigned assertions:"
    assigns_missing.sort.each do |ivar|
      message << "    assert_assigned #{ivar.intern.inspect} #, some_value"
    end
    message << nil # stupid '.'

    flunk message.join("\n")
  end
  
end

class Object # :nodoc:
  def self.path2class(klassname)
    klassname.split('::').inject(Object) { |k,n| k.const_get n }
  end
end