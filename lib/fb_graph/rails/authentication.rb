module FbGraph::Rails
  module Authentication

    extend ActiveSupport::Concern
    included do |base|
      base.class_eval do
        helper_method :current_user
      end
    end

    module ClassMethods

      # Check the login use has given permissions or not.
      # If not, user should be redirected to Facebook's permissions dialog page,
      # and returns to originally requested path.
      # If the request was not GET, user will be returned to root.
      #
      # Actually, this method sets dynamically generated method to before_filter & rescue_from.
      # Can take :if => cond hash at last and it will be attached to before_filter.
      #
      def require_user_with(*args, &block)
        args = args.dup
        options, permissions = args.extract_options!, args.flatten
        relocation, filter_options = options.delete(:relocation), options

        #TODO Handle permission includes underscore
        #     This is not actually harmful but the name of defined method
        #     could be confusing.
        require_method_name = "require_user_with_#{permissions.join('_')}".to_sym
        rescue_method_name  = "rescue_from_#{permissions.join('_')}".to_sym

        # Define method to check current_user has given permissions
        define_method require_method_name do
          authenticate_with_signed_request || authenticate_with_code

          authorized = begin
                         current_user && current_user.permits?(permissions)
                       rescue FbGraph::Unauthorized
                         # This will be raised if user does not authorized app
                         false
                       end
          raise UserDoesNotAuthenticated.new(permissions) unless authorized
        end

        before_filter require_method_name, filter_options

        # Define method to handle the error which will be raised
        # when the user didn't have all required permissions
        define_method rescue_method_name do |exception|
          raise exception unless exception.permissions == permissions

          client = FbGraph::Auth.new(Config.client_id,
                                     Config.client_secret).client

          if relocation
            client.redirect_uri = Config.canvas_url + (request.get? ? request.path : root_path)
            relocate_to client.authorization_uri(:scope => permissions)
          else
            client.redirect_uri = request.get? ? request.url : root_url
            redirect_to client.authorization_uri(:scope => permissions)
          end
        end
        rescue_from UserDoesNotAuthenticated, :with => rescue_method_name
      end
    end

    module InstanceMethods

      # Store user id in session.
      #
      def authenticate(user)
        raise Unauthorized unless user
        session[:current_user] = user.id
      end

      # Return current_user.
      # If it does not exist, returns nil.
      #
      # @return user or nil
      def current_user
        @current_user ||= ::User.find(session[:current_user])
      rescue ActiveRecord::RecordNotFound
        nil
      end

      # Return current_user exists or not.
      #
      # @return [Boolean] Whether or not page's plan is updated.
      def authenticated?
        !current_user.blank?
      end

      # Create and authenticate current_user by signed_request.
      # If signed_request was not given, do nothing.
      # If signed_request was not authorized(means mainly user didn't installed app), do nothing.
      #
      def authenticate_with_signed_request
        return unless params[:signed_request]

        auth = FbGraph::Auth.new(Config.client_id,
                                 Config.client_secret,
                                 :signed_request => params[:signed_request])
        unauthenticate
        authenticate ::User.identify(auth.user) if auth.authorized?
      end

      def authenticate_with_code
        #TODO test
        return unless params[:code]

        auth = FbGraph::Auth.new(Config.client_id,
                                 Config.client_secret)
        client = auth.client
        client.redirect_uri = url_for(request.params.merge :code => nil)
        client.authorization_code = params[:code]
        access_token = client.access_token!

        unauthenticate
        me = FbGraph::User.me(access_token).fetch
        authenticate ::User.identify(me)

      end

      # Delete current_user from database and session.
      #
      def unauthenticate
        return unless current_user
        current_user.update_attribute :access_token, nil
        @current_user = session[:current_user] = nil
      end
    end
  end
end
