module ActiveRecord
  class Base
    # 'Global' ActiveRecord methods
    cattr_accessor :to_param_attributes, :instance_writer => false
    @@to_param_attributes = [:full_name, :name, :title]
    
    cattr_accessor :to_param_separator, :instance_writer => false
    @@to_param_separator = "-"
    
    cattr_accessor :use_custom_params, :instance_writer => false # need to enable in environment.rb: ActiveRecord::Base.use_custom_params = true
    @@use_custom_params = false
    
    # Class methods per model
    class << self
      attr_accessor :to_param_attribute
      attr_writer   :custom_params_enabled

      def custom_params_enabled
        self.use_custom_params && (!@custom_params_enabled.nil? ? @custom_params_enabled : true)
      end
    end

    # model instance methods
    def to_param(options = {})
      if self.class.custom_params_enabled
        attributes, attribute = ([options[:attribute]] + [self.class.to_param_attribute] + self.class.to_param_attributes).flatten.compact, nil
      
        attributes.each do |att|
          attribute = att if self.respond_to?(att) && attribute.nil?
        end
      
        (id = self.id) ? "#{id}#{attribute ? "#{self.to_param_separator}#{self.send(attribute).to_s.paramatize(self.to_param_separator)}" : ""}" : nil
      else
        (id = self.id) ? id.to_s : nil
      end
    end
  end
end

class String
  def paramatize(separator = "-")
    self.scan(/\w+/).join(separator).downcase
  end
end