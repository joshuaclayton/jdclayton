module Fusionary
  module Helpers
    module FusionaryHelper
      # Wrapper for a div classed as text (or any other args passed in) OR radio|checkbox (and any other args passed in).  Extracts options hash if last item in args splat
      # 
      # ==== Options
      # * <tt>*args</tt> -- Splat array of additionall classes to be assigned besides set.  Extracts options if last item is a hash (all options ActionView::Helpers::TagHelper::content_tag accepts)
      # 
      # ==== Example
      # 
      #   <% set do %>
      #     <p>Test!</p>
      #   <% end %>
      #   
      # produces
      # 
      #   <div class="text">
      #     <p>Test!</p>
      #   </div>
      #   
      # with *args set,
      # 
      #   <% set :first, :warning, "warning-notification", :id => "warn", :style => "border: 2px solid red;" do %>
      #     <h3>You've made a big error!</h3>
      #   <% end %>
      #   
      # produces
      # 
      #   <div class="first warning warning-notification text" id="warn" style="border: 2px solid red;">
      #     <h3>You've made a big error!</h3>
      #   </div>
      def set(*args, &block)
        options = args.extract_options!
        css_classes = [] << options.delete(:class) << args
        css_classes << "text" unless (args & [:radio, :checkbox, "radio", "checkbox"]).any? # add text unless radio or checkbox class is present
        concat(content_tag(:div, capture(&block), options.merge(:class => "#{css_string(css_classes)}")), block.binding)
      end
      
      # Used to wrap a string within another based on a boolean flag
      # 
      # ==== Options
      # * <tt>boolean</tt> -- Flag switching whether what's yielded is wrapped in element
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts, as well as
      #   * <tt>:html_tag</tt> -- Tag to wrap yield within.  Defaults to <tt>div</tt>
      # 
      # ==== Example
      #   
      #   <% words.split(/ /).map do |word| %>
      #     <% wrap_content_if word =~ /cruel|unusual/, :html_tag => 'span', :class => 'highlight' do %> 
      #       <%= word %>
      #     <% end %>
      #   <% end %>
      def wrap_content_if(boolean, options = {}, &block)
        options[:html_tag] ||= 'div'
        output = boolean ? content_tag(options.delete(:html_tag).to_sym, capture(&block), options) : capture(&block)
        concat(output, block.binding)
      end
      
      # Simplifies to a link_to with 'cancel' as the default text
      # 
      # ==== Options
      # * <tt>path</tt> -- accepts same as <tt>url_for</tt>
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts
      #
      # ==== Example
      #
      #   <%= cancel_link stories_path %> # => <a href="/stories">cancel</a>
      def cancel_link(path, options = {})
        link_to 'cancel', path, options
      end
      
      # This wraps a link_to within a li with other options
      # 
      # ==== Options
      # * <tt>name</tt> -- inner text of anchor
      # * <tt>path</tt> -- accepts same as <tt>url_for</tt>
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts, as well as
      #   * <tt>:active</tt> -- string to denote what is active by comparing to :active_compare. 
      #   * <tt>:active_compare</tt> -- compares against :active to determine if <tt><li/></tt> is active.  Defaults to controller.controller_name 
      #   * <tt>:active_name</tt> -- this is the class the list item gets if it is the active element
      #   * <tt>:compare</tt> -- boolean value to determine if <tt><li/></tt> is active
      # 
      # ==== Examples
      # Within users_controller, the users tab would have the class active automatically
      #   <ul id="navigation">
      #     <%= tab "Home", home_path, :class => 'first' %>
      #     <%= tab "Users", users_path %>
      #     <%= tab "Orders", orders_path, :class => 'last' %>
      #   </ul>
      # 
      # or, to set active based on query string:
      #   
      #   <ul>
      #     <%= tab "#{image_tag "icn-approved.gif", :alt => 'Approved'}Approved", 
      #             filter_catalogs_path(:state => 'approved'), 
      #             {}, 
      #             :compare => params[:state] == 'approved' %>
      #             
      #     <%= tab "#{image_tag "icn-submitted.gif", :alt => 'Ordered'}Ordered", 
      #             filter_catalogs_path(:state => 'submitted'), 
      #             {}, 
      #             :compare => params[:state] == 'submitted' %>
      #   </ul>
      def tab(name, path, options = {}, li_options = {})
        active =            li_options.delete(:active) || name.gsub(/\s/, '').tableize || ""
        comparison =        li_options.delete(:active_compare) || controller.controller_name
        active_name =       li_options.delete(:active_name) || "active"
        compare =           li_options.delete(:compare) || false
        li_class_options =  li_options.delete(:class)
        content_tag(:li, link_to(name, path, options), li_options.merge(:class => "#{li_class_options}#{" #{active_name}" if active == comparison || compare}"))
      end
      
      # ==== Basic structure:
      # 
      #   <div class="section">
      #     <h3>{title}</h3>
      #     <div class="value">
      #       {block}
      #     </div>
      #   </div>
      #   
      # 
      # ==== Options
      # * <tt>title</tt> -- the title of the section
      # * <tt>args</tt>
      #   * if first arg is either a true or false, it determines whether this element is rendered or not. Allows for easy conditional chunks of data based on an initial check.
      #   * also extracts options from args (if last item in args is a hash, pops it from end and sets it to an options hash) that's merged with the default classes
      # 
      # ==== Examples
      #   <% section "#{@user.full_name}'s Favorite Books", @user.books.favorite.any? do %>
      #     <ul>
      #     <% @user.books.favorite.each do |book| %>
      #       <%= tab book.title, book %>
      #     <% end %>
      #     </ul>
      #   <% end %>
      #   
      # or
      #   
      #   <% section "Description" do %>
      #     <%= @item.description %>
      #   <% end %>
      def section(title, *args, &block)
        options = args.extract_options!
        display = !args.first.nil? ? args.shift : true
        
        css_classes = ["section"] << options.delete(:class) << args
        
        class_options = options.delete(:class)
        if display
          html = content_tag(:div, 
                    (title.blank? ? "" : content_tag(:h3, title, :class => 'alt')) + 
                    content_tag(:div, 
                      capture(&block), 
                      :class => 'value'), 
                  {:class => "#{css_string(css_classes)}"}.merge(options))
          concat(html, block.binding)
        end
      end

      # Easily builds a tr element with alternating rows
      # 
      # ==== Options
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts, as well as
      #   * <tt>:cycle_list</tt> -- Array of classes to use.  Defaults to ["odd", "even"]
      #
      # ==== Examples:
      #   <% recordset :headers => %w(Name Email Age) do %>
      #     <% @users.each do |user| %>
      #       <% zebra_row do %>
      #         <td><%= user.full_name %></td>
      #         <td><%= link_to_email user.email %></td>
      #         <td><%= user.age %></td>
      #       <% end %>
      #     <% end %>
      #   <% end %>
      #   
      # or 
      #   
      #   <% recordset :headers => %w(Name Email Age) do %>
      #     <% @patriotic_americans.each do |user| %>
      #       <% zebra_row :id => "user-#{user.id}", :cycle_list => %w(red white blue) do %>
      #         <td><%= user.full_name %></td>
      #         <td><%= link_to_email user.email %></td>
      #         <td><%= user.age %></td>
      #       <% end %>
      #     <% end %>
      #   <% end %>
      def zebra_row(options = {}, &block)
        cycle_list = options.delete(:cycle_list) || ["odd", "even"]
        css_classes = [cycle(*cycle_list)] << options.delete(:class)
        html = content_tag(:tr, capture(&block),
          options.merge(:class => css_string(css_classes)))
        concat(html, block.binding)
      end

      # Easily generates an email link
      # 
      # ==== Options
      # * <tt>email_address</tt> -- this is the email address the link will point to
      # * <tt>args</tt> -- runs extract_options on the array for options on the link.  If first arg is a string, that is what is displayed as the text within the link
      #   
      # ==== Examples
      #   <%= link_to_email("everyone@fusionary.com") %> 
      #     <a href="mailto:everyone@fusionary.com">everyone@fusionary.com</a>
      #   
      #   <%= link_to_email("everyone@fusionary.com", "Everyone at Work", :class => 'email') %>
      #     <a href="mailto:everyone@fusionary.com" class="email">Everyone at Work</a>
      def link_to_email(email_address, *args)
        options = args.extract_options!
        link = args.first.is_a?(String) ? h(args.first) : email_address
        link_to link, "mailto:#{email_address}", options
      end
      
      # Generates the structured HTML of a recordset-driven table
      # 
      # ==== Structure
      # 
      #   <table class="recordset">
      #     <thead>
      #       <tr>
      #         <th>{header}</th>
      #         <th>{header}</th>
      #         <th>{header}</th>
      #       </tr>
      #     </thead>
      #     {block}
      #   </table>
      # 
      # ==== Options
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts, as well as
      #   * <tt>:table</tt> -- options hash for the table element.  Accepts anything that content_tag would
      #   * <tt>headers</tt> -- Array of items for the th elements
      #     * if an array is passed as a header item, it will be broken into <tt>["name of header", {:hash_of_options => "to be applied to that th element"}]</tt>
      #     * if a string is passed, the string is placed inside the th
      #     * if the header is a string beginning with <tt>'<th'</tt>, it just returns the string, seeing that it's already within a <tt><th/></tt> tag
      # 
      # ==== Examples
      # 
      #   <% recordset :headers => [
      #       ["", {:class => 'first'}], 
      #       sortable_table_header('orders.state', {:title => "Status"}, :class => 'status'), 
      #       sortable_table_header('companies.name', {:title => 'Company'}, :class => 'company')
      #     ] do %>
      #     <tbody>
      #       <% @catalogs.each do |catalog| %>
      #         <% if @current_user.can_show_catalog?(catalog) %>
      #           <% zebra_row do %>
      #             <td class="first"><input type="checkbox" /></td>
      #             <td class="status"><%= image_tag "icn-#{catalog.order.state}.gif", :alt => catalog.order.state.humanize, :title => catalog.order.state.humanize %></td>
      #             <td class="company"><%= link_to catalog.name, catalog_path(catalog) %></td>
      #           <% end %>
      #         <% end %>
      #       <% end %>
      #     </tbody>
      #   <% end %>
      #   
      # or
      #   
      #   <% recordset :headers => %w(Name Email Age) do %>
      #     <% @patriotic_americans.each do |user| %>
      #       <% zebra_row do %>
      #         <td><%= user.full_name %></td>
      #         <td><%= link_to_email user.email %></td>
      #         <td><%= user.age %></td>
      #       <% end %>
      #     <% end %>
      #   <% end %>
      def recordset(options = {}, &block)
        options[:table] ||= {}
        headers = []
        options[:headers].each_with_index do |header, index|
          head = [header].flatten
          opts = head.extract_options!
          
          css_classes = [] << case index
            when 0 then "first"
            when (options[:headers].size - 1) then "last"
          end
          
          css_classes << opts.delete(:class)

          headers << if head.first =~ /^\<th/
            if head.first =~ /^(\<th[^\>]+)(class=\"([\w\-\_\ ]+)\")(.+)/
              if $3
                css_classes << $3.split(' ')
                "#{$1}class=\"#{css_string(css_classes)}\"#{$4}"
              end
            else
              head.first.gsub(/^(\<th)([\>]+)(.+)/, "#{$1}#{$2} class=\"#{css_string(css_classes)}\"#{$3}")
            end
          else
            content_tag(:th, head.first, opts.merge(:class => css_string(css_classes)))
          end
        end
        
        table_css_classes = ["recordset"] << options[:table][:class]
        
        html = content_tag(:table, 
          content_tag(:thead, content_tag(:tr, headers.to_s)) + capture(&block), 
            options[:table].merge(:class => css_string(table_css_classes)))
        concat(html, block.binding)
      end
      
      # Generate sortable <tt><th/></tt>'s that work hand-in-hand with sticky-sort (if being used)
      # 
      # ==== Options
      # * <tt>property</tt> -- column you'll be sorting on in the controller.  You can sort on associated tables if you use the table name and it's :included in the query
      # * <tt>options</tt> -- Options are all options ActionView::Helpers::TagHelper::content_tag accepts
      #   * <tt>:params</tt> -- params to use for keys to pass to anchor tag.  Defaults to standard params
      #   * <tt>:active_class</tt> -- class name to use on anchor tag if currently sorting on that column.  Defaults to 'active'
      #   * <tt>:asc_class</tt> -- class name to be appended to anchor when sorting ascending.  Defaults to 'asc'
      #   * <tt>:desc_class</tt> -- class name to be appended to anchor when sorting descending.  Defaults to 'desc'
      #   * <tt>:title</tt> -- text to go within anchor tag (header text).  Defaults to property that's had called humanize on it
      # 
      # ==== Examples
      #   <%= sortable_table_header('orders.state', {:title => "Status"}, :class => 'status') %>
      #   <%= sortable_table_header('name') %>
      def sortable_table_header(property, options = {}, th_options = {})
        options[:params] ||= params || {}
        options[:sort] = property
        options[:order] = params[:order] || "asc"
        options[:active_class] ||= "active"
        options[:asc_class] ||= "asc"
        options[:desc_class] ||= "desc"
        options[:title] ||= property.humanize

        th_class, sort_order, anchor_class = [], "desc", []

        if options[:sort] == params[:sort]
          th_class << options[:active_class]
          case options[:order]
          when "asc"
            sort_order = "desc"
            anchor_class << "asc"
          when "desc"
            sort_order = "asc"
            anchor_class << "desc"
          end
        end

        th_class << th_options.delete(:class)

        content_tag(:th, 
          link_to(options[:title], 
                  options[:params].merge(
                    :controller => controller.controller_name, 
                    :action => controller.action_name, 
                    :sort => options[:sort], 
                    :order => sort_order), 
                  :class => css_string(anchor_class)), 
          th_options.merge(:class => css_string(th_class)))
      end
      
      protected
      
      # helper method turning array into string
      def css_string(css)
        return css unless css.is_a?(Array)
        css.flatten.compact.uniq.join(' ')
      end
    end
  end
end