module FbGraph::Rails
  module Utils

    extend ActiveSupport::Concern

    included do

      # similar to url_for but returns a canvas_url for given options
      #
      #   canvas_url_for 'foo/bar'    #=> 'http://apps.facebook.com/myapp/foo/bar'
      #   canvas_url_for '/foo/bar'   #=> 'http://apps.facebook.com/myapp/foo/bar'
      #   canvas_url_for Page.find(1) #=> 'http://apps.facebook.com/myapp/pages/1'
      def canvas_url_for(options = {})
        options ||= {}
        path = case options
               when String, :back
                 url_for options
               when Hash
                 url_for options.reverse_merge(:only_path => true)
               else
                 url_for polymorphic_path(options, :only_path => true)
               end
      "#{Config.canvas_url.sub(/\/\z/, '')}/#{path.sub(/\A\//, '')}"
      end

      # Rewrite url of inner frame and force user to access 'apps.facebook.com' type url.
      # This makes user to make a request with signed_request.
      #
      def relocate_to(url_for_options)
        to = url_for(url_for_options)
        render :text => "<script>top.location = '#{to}'</script>"
      end
    end
  end

end
