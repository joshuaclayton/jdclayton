# Shamelessly looted from http://svn.techno-weenie.net/projects/plugins/gems/init.rb
#
# Adds vendor directories to the load path.
#
# You still need to +require+ the libraries you are using.
standard_dirs = ['rails', 'plugins', 'engines']
gems          = Dir["vendor/**"]
if gems.any?
  gems.each do |dir|
    next if standard_dirs.include?(File.basename(dir))
    lib = File.join(RAILS_ROOT, dir, 'lib')
    $LOAD_PATH.unshift(lib) if File.directory?(lib)
  end
end

ActionView::Base.class_eval do
  include Fusionary::Helpers::FusionaryHelper
  
  # In order to use any of the helper methods from BlueprintLayoutHelper,
  # you will need to set constants within ApplicationController e.g.
  # 
  #   class ApplicationController < ActionController::Base
  #     BLUEPRINT_CONTENT_WIDTH =       24
  #     BLUEPRINT_EXTRA_CONTENT_WIDTH = 0
  #     BLUEPRINT_WIDTH =               BLUEPRINT_CONTENT_WIDTH + BLUEPRINT_EXTRA_CONTENT_WIDTH
  #     # whatever other code here
  #   end
  include Fusionary::Helpers::BlueprintLayoutHelper
end

unless Array.respond_to?("extract_options!")
  class Array
    def extract_options!
      last.is_a?(::Hash) ? pop : {}
    end
  end
end

require 'fusionary/util/custom_params'