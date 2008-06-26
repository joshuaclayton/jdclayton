# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def content(*args, &block)
    args.insert(0, :three_fourths) if args.empty?
    content_builder(:content, *args, &block)
  end
  
  def extra_content(*args, &block)
    args.insert(0, :one_fourth) if args.empty?
    content_builder(:extra_content, *(args + [:last]), &block)
  end
  
  private
  
  def content_builder(area, *args, &block)
    options = args.extract_options!
    size = args.shift
    
    section = content_for area do 
      column size, *[args, options].flatten do
        capture(&block)
      end
    end
    
    concat(section, block.binding)
  end
end
