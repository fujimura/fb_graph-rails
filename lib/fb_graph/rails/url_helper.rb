module FbGraph::Rails
  module UrlHelper

    # Returns url to ask user to allow use his/her datas, according to passed permissions.
    #
    # @return [String]
    def oauth_permission_url_for(permissions)
      redirect_uri = if request.get?
                       canvas_url_for request.path
                     else
                       canvas_url_for root_path
                     end
      "https://www.facebook.com/dialog/oauth?client_id=#{Facebook.client_id}&redirect_uri=#{redirect_uri}&scope=#{permissions.join(',')}"
    end

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
      "#{Facebook.canvas_url.sub(/\/\z/, '')}/#{path.sub(/\A\//, '')}"
    end
  end
end
