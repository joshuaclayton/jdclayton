module Fusionary
  module Util
    module StickySort
      def sticky_sort
        # See if params has an order and sort attribute.
        # Store sort and order in session based on action/controller key
        searchkey = "#{params[:controller]}-#{params[:action]}"
        init_keys(searchkey)
        if params.keys.find{|k| k.to_s =~ /sort|order|page/ } 
          store_sort(searchkey)
        else
          retrieve_sort(searchkey)
        end
      end
  
      def init_keys(searchkey)
        session[:sort] = {} unless session[:sort]
        session[:sort][searchkey] = {} unless session[:sort][searchkey]
      end

      def store_sort(searchkey)
        [:sort, :order, :page].each do |p| 
          if params[p]
            session[:sort][searchkey][p]  = params[p]  if params[p]
          else
            # clear any params not in request
            session[:sort][searchkey].delete p
          end
        end
      end
  
      def retrieve_sort(searchkey)
        params.merge!(session[:sort][searchkey]) if session[:sort][searchkey].keys.find{|k| k.to_s =~ /sort|order|page/ }  
      end
  
    end
  end
end