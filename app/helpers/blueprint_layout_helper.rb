module BlueprintLayoutHelper
  # Hash of constantized ratios
  MULTIPLES = {
    :one_twentyfourth =>          (1/24.to_f),
    :one_twelfth =>               (1/12.to_f),
    :one_eigth =>                 (1/8.to_f),
    :one_sixth =>                 (1/6.to_f),
    :five_twentyfourths =>        (5/24.to_f),
    :one_fourth =>                (1/4.to_f),
    :seven_twentyfourths =>       (7/24.to_f),
    :one_third =>                 (1/3.to_f),
    :three_eigths =>              (3/8.to_f),
    :five_twelfths =>             (5/12.to_f),
    :eleven_twentyfourths =>      (11/24.to_f),
    :one_half =>                  (1/2.to_f),
    :half =>                      (1/2.to_f),
    :thirteen_twentyfourths =>    (13/24.to_f),
    :seven_twelfths =>            (7/12.to_f),
    :five_eigths =>               (5/8.to_f),
    :two_thirds =>                (2/3.to_f),
    :seventeen_twentyfourths =>   (17/24.to_f),
    :three_fourths =>             (3/4.to_f),
    :nineteen_twentyfourths =>    (19/24.to_f),
    :five_sixths =>               (5/6.to_f),
    :seven_eigths =>              (7/8.to_f),
    :eleven_twelfths =>           (11/12.to_f),
    :twentythree_twentyfourths => (23/24.to_f),
    :full =>                      (1.to_f)
  }

  # Worker method that generates all Blueprint columns
  # 
  # ==== Options
  # * <tt>size</tt> -- Number or symbol from multiples hash.  Generates span relative to parent, so if parent is a span-12 and :half is used, it will be span-6.  Defaults to :full
  # * <tt>args</tt> -- Args last item should be options ActionView::Helpers::TagHelper::content_tag accepts, as well as
  #   * <tt>:suppress_span</tt> -- This is used if you want to get nested widths without including the Blueprint span class on the div
  #     
  # ==== Examples
  #   <!-- base of 24 col -->
  #   <% column do %>
  #     <% column :one_third do %>
  #       <% column do %>
  #         <h2>Header</h2>
  #       <% end %>
  #       <% column :half do %>
  #         One col
  #       <% end %>
  #       <% column :half, :class => 'last' do %>
  #         Two col
  #       <% end %>
  #     <% end %>
  #     <% column :two_thirds, :class => 'last', :id => 'content' do %>
  #       <h1>Content!</h1>
  #     <% end %>
  #   <% end %>
  #   
  # would generate
  #   
  #   <div class="span-24 last">
  #     <div class="span-8">
  #       <div class="span-8 last">
  #         <h2>Header</h2>
  #       </div>
  #       <div class="span-4">
  #         One col
  #       </div>
  #       <div class="span-4">
  #         Two col
  #       </div>
  #     </div>
  #     <div class="span-16 last" id="content">
  #       <h1>Content!</h1>
  #     </div>
  #   </div>
  # 
  # Example using numbers instead of referencing <tt>BlueprintLayoutHelper::MULTIPLES</tt>
  #
  #   <!-- base of 24 col -->
  #   <% column do %>
  #     <% column 12 do %>
  #       <% column :one_third do %>
  #         Hello!
  #       <% end %>
  #       <% column :two_thirds, :class => 'last' do %>
  #         Two thirds of 12 is 8
  #       <% end %>
  #     <% end %>
  #     <% colum 8 do %>
  #       <% column :half do %>
  #         First half
  #       <% end %>
  #       <% column :half, :class => 'last' do %>
  #         Second half
  #       <% end %>
  #     <% end %>
  #     <% column :one_sixth, :class => 'last' do %>
  #       Last child
  #     <% end %>
  #   <% end %>
  # 
  # would generate
  #   
  #   <div class="span-24">
  #     <div class="span-12">
  #       <div class="span-4">
  #         Hello!
  #       </div>
  #       <div class="span-8 last">
  #         Two thirds of 12 is 8
  #       </div>
  #     </div>
  #     <div class="span-8">
  #       <div class="span-4">
  #         First half
  #       </div>
  #       <div class="span-4 last">
  #         Second half
  #       </div>
  #     </div>
  #     <div class="span-4 last">
  #       Last child
  #     </div>
  #   </div>
  def column(size="", *args, &block)
    @blueprint_grid_width ||= ApplicationController::BLUEPRINT_CONTENT_WIDTH
    col(size, *args, &block)
  end

  def col(size="", *args, &block)
    size = :full if size.blank?
    options = args.extract_options!
    
    @blueprint_level = @blueprint_level ? @blueprint_level + 1 : 1
    current_width = @blueprint_grid_width.to_s
    @blueprint_grid_width = size.to_s =~ /^\d+$/ ? size.to_s.to_i : (@blueprint_grid_width*MULTIPLES[size]).to_i
    css_classes = []
    !(opt_classes = options.delete(:class)).blank? ? opt_classes.split(/ /).each {|c| css_classes << c } : ""
    
    css_classes << "span-#{@blueprint_grid_width}" unless options[:suppress_span]
    css_classes << "last" if size == :full
    args.each {|a| css_classes << a.to_s} if args.any?

    output_tag = content_tag(:div, capture(&block), {:class => css_classes.uniq.join(" ")}.merge(options))
    
    if block_given? && block_is_within_action_view?(block)
      concat(output_tag, block.binding)
      @blueprint_grid_width = size.is_a?(Integer) ? current_width.to_i : (@blueprint_grid_width/MULTIPLES[size]).to_i
      @blueprint_level -= 1
    else
      @blueprint_grid_width = size.is_a?(Integer) ? current_width.to_i : (@blueprint_grid_width/MULTIPLES[size]).to_i
      @blueprint_level -= 1
      output_tag
    end
  end
  
  private :col
  
  # Generates a header based on Blueprint nesting.
  # Every nested column steps down; move outside that block and it goes back up a step.  Limit is 6, and initial is 2 (h2 - h6)
  # Accepts options like ActionView::Helpers::TagHelper::content_tag, and you can pass in :with_rule before the options hash to append an <tt><hr/></tt> after the header
  # 
  # ==== Options
  # * <tt>args</tt> -- pass any arguments, including
  #   * <tt>:with_rule</tt> -- Appends an <tt><hr/></tt> after the heading
  #   * <tt>options</tt> -- Additional options are all all options ActionView::Helpers::TagHelper::content_tag accepts
  # ==== Example
  # 
  #   <% column do %>
  #     <% header do %>Column Header<% end %>
  #     <% column :half do %>
  #       <% header :with_rule do %>Half Header<% end %>
  #       <p>Half col</p>
  #     <% end %>
  #     <% column :half, :class => 'last' do %>
  #       <% header do %>Half header #2<% end %>
  #       <p>Half col</p>
  #       <% column do %>
  #         <% header :with_rule, :class => "notice" do %>Sub-header<% end %>
  #         <% column do %>
  #           <% header do %>Sub-header<% end %>
  #           <% column do %>
  #             <% header do %>Sub-header<% end %>
  #             <p>content</p>
  #           <% end %>
  #         <% end %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  # 
  # would generate
  # 
  #   <div class="span-24 last">
  #     <h2>Column Header</h2>
  #     <div class="span-12">
  #       <h3>Half Header</h3><hr/>
  #       <p>Half col</p>
  #     </div>
  #     <div class="span-12 last">
  #       <h3>Half header #2</h3>
  #       <p>Half col</p>
  #       <div class="span-12 last">
  #         <h4 class="notice">Sub-header</h4><hr/>
  #         <div class="span-12 last">
  #           <h5>Sub-header</h5>
  #           <div class="span-12 last">
  #             <h6>Sub-header</h6>
  #             <p>content</p>
  #           </div>
  #         </div>
  #       </div>
  #     </div>
  #   </div>
  def header(*args, &block)
    options = args.extract_options!
    size = (temp_size = (@blueprint_level || 1) + 1) > 6 ? 6 : temp_size
    concat(content_tag("h#{size}", capture(&block), options) + (args.include?(:with_rule) ? "<hr/>" : ""), block.binding)
  end

  # Container method to be called in application.html.erb/.rhtml or similar primary layouts
  # 
  # ==== Example
  # (Within application.html.erb)
  #
  #   <html>
  #     <head>
  #       <title>Page title</title>
  #     </head>
  #     <body>
  #       <% container do %>
  #         Stuff within container
  #       <% end %>
  #     </body>
  #   </html>
  def container(options = {}, &block)
    @blueprint_grid_width = options.delete(:size) || (ApplicationController::BLUEPRINT_WIDTH rescue 24)
    concat(content_tag(:div, capture(&block), {:class => 'container'}.merge(options)), block.binding)
  end

  # Overrides method missing for dynamically-generated classes
  # 
  # ==== Examples
  #   
  #   <% column 6 do %>
  #     <%= content_tag :h1, 'Header', one_third() %>
  #   <% end %>
  # 
  # generates
  #   
  #   <div class="span-6">
  #     <h1 class="span-2">Header</h1>
  #   </div>
  # 
  # and
  #  
  #   <% column 24 do %>
  #     <% column :three_fourths, :class => push_one_fourth() do %>
  #       Primary content as the right column
  #     <% end %>
  #     <% column :one_fourth, :class => "#{pull_full()} last" do %>
  #       Secondary content as the left column
  #     <% end %>
  #   <% end %>
  # 
  # generates
  #   
  #   <div class="span-24">
  #     <div class="span-18 push-6">
  #       Primary content as the right column
  #     </div>
  #     <div class="span-6 pull-24 last">
  #       Secondary content as the left column
  #     </div>
  #   </div>
  def method_missing(call, *args)
    call.to_s =~ /^((append|prepend|push|pull|span)_)?(.+)$/
    class_name = $2 || 'span'
    class_width = $3

    if MULTIPLES.keys.include?(class_width.to_sym)
      width = @blueprint_grid_width || ApplicationController::BLUEPRINT_CONTENT_WIDTH
      "#{class_name}-#{(width*MULTIPLES[class_width.to_sym]).to_i}"
    else
      super(call, args)
    end
  end
  
  private
  
  def block_is_within_action_view?(block)
    eval("defined? _erbout", block.binding)
  end
end