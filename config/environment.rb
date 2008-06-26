RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [:active_resource, :action_mailer ]
  config.action_controller.session = {
    :session_key => '_jdclayton_session',
    :secret      => 'bab6dfb8ac69435a9a1b398c3856c2e563ddaa5409c2a7ca6db1ef55d8cb062af61d57c1d79eae30ad6f7c97a7b56f34452d63c546f269b86d7073dd679cfc5a'
  }

  config.action_controller.session_store = :active_record_store
  config.action_controller.page_cache_directory = "#{RAILS_ROOT}/public/cache/"
end