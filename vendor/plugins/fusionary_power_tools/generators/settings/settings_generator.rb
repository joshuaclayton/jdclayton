class SettingsGenerator < Rails::Generator::Base
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :class_path,
                :class_name
  alias_method  :controller_file_name,  :controller_singular_name
  alias_method  :controller_table_name, :controller_plural_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    # Take controller name from the next argument.  Default to the pluralized model name.
    @controller_name = args.first
    
    
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_singular_name, @controller_plural_name = inflect_names(base_name)
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
  end
  
  def manifest
    record do |m|
      
      # Check for class naming collisions.
      m.class_collisions controller_class_path, "#{controller_class_name}Controller", 
                                                "#{controller_class_name}ControllerTest", 
                                                "#{controller_class_name}Helper"
      m.class_collisions class_path,            "#{class_name}"
                                                #"#{class_name}Test"
      
      # Controller, helper, views, and test directories.
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      
      m.template 'controllers/settings_controller.rb',
        File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      
      m.template 'helpers/helper.rb',
        File.join('app/helpers', controller_class_path, "#{controller_file_name}_helper.rb")
      
      
      m.file "index.rhtml",
          File.join('app/views', controller_class_path, controller_file_name, "index.rhtml")
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} [ControllerName]"
    end
    
    # NamedBase does not give us what we need, but we do need these methods (which are protected)
    def extract_modules(name)
      modules = name.include?('/') ? name.split('/') : name.split('::')
      name    = modules.pop
      path    = modules.map { |m| m.underscore }
      file_path = (path + [name.underscore]).join('/')
      nesting = modules.map { |m| m.camelize }.join('::')
      [name, path, file_path, nesting, modules.size]
    end

    def inflect_names(name)
      camel  = name.camelize
      under  = camel.underscore
      plural = under.pluralize
      [camel, under, plural]
    end
    
end