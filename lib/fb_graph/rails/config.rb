module FbGraph::Rails
  class Config

    # Configuration class.
    # Config.client_id, Config.client_secret, Config.canvas_url, Config.site_url can be used.
    # Each values will be loaded from /config/facebook.yml or ENV.
    #
    # Sample:
    # facebook.yml
    #
    #   development:
    #     client_id: 115997921798478
    #     client_secret: e98l8888l888888l888888l88888e877
    #     canvas_url: http://apps.facebook.com/fb_graph-rails
    #     site_url: http://example.com/app
    #   test:
    #     client_id: 115997921798478
    #     client_secret: e98l8888l888888l888888l88888e877
    #     canvas_url: http://apps.facebook.com/fb_graph-rails
    #     site_url: http://example.com/app
    #   production:
    #     client_id: 115997921798478
    #     client_secret: e98l8888l888888l888888l88888e877
    #     canvas_url: http://apps.facebook.com/fb_graph-rails
    #     site_url: http://example.com/app
    #
    # ENV:
    #   fb_client_id, fb_client_secret, fb_canvas_url, fb_site_url
    #
    class << self
      [:canvas_url, :client_id, :client_secret, :site_url].each do |conf|
        define_method conf do
          from_yaml(conf) || from_env(conf)
        end
      end

      private

      def from_yaml(name)
        (@yaml_conf ||= YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env].symbolize_keys)[name] rescue nil
      end

      def from_env(name)
        ENV["fb_#{name}"]
      end

    end
  end
end
