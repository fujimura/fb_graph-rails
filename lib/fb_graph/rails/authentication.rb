module FbGraph::Rails
  #TODO move
  class CurrentUserDoesNotExist < StandardError ; end
  class CandidateUserDoesNotExist < StandardError ; end
  class JavaScriptAuthenticationFailed < StandardError ; end
  class Unauthorized < StandardError; end
  class UserDoesNotAuthenticated < StandardError
    attr_accessor :permissions
    def initialize(permissions)
      @permissions = permissions
    end
  end
  module Authentication

    extend ActiveSupport::Concern

    module ClassMethods
      # Check the login use has given permissions or not.
      # If not, redirect to Facebook's permissions dialog page.
      #
      # Actually, this method sets dynamically generated method to before_filter & rescue_from.
      #
      def require_user_with(*args)
        filter_options = args.last.is_a?(Hash) ? args.last : {}
        permissions = args[0..args.length-1]
        #TODO What happens with permission includes undersocre?
        require_method_name = "require_user_with_#{permissions.join('_')}".to_sym
        rescue_method_name  = "rescue_from_#{permissions.join('_')}".to_sym

        # Define method to check current_user has given permissions
        define_method require_method_name do
          auth_with_signed_request
          unless current_user && permissions.all? { |p| current_user.permissions.include? p }
            raise UserDoesNotAuthenticated.new(permissions)
          end
        end
        before_filter require_method_name, filter_options


        # Define method to handle the error which will be raised
        # when the user didn't have all required permissions
        define_method rescue_method_name do |exception|
          if exception.permissions == permissions
            #TODO use redirect?
            relocate_to oauth_permission_url_for(permissions)
          else
            raise exception
          end
        end
        rescue_from UserDoesNotAuthenticated, :with => rescue_method_name
      end
    end

    module InstanceMethods

      # Return current_user.
      # If it does not exist, returns nil.
      #
      # @return user or nil
      def current_user
        @current_user ||= ::User.find(session[:current_user])
      rescue ActiveRecord::RecordNotFound
        nil
      end

      # Return current_user exists or not
      #
      # @return [Boolean] Whether or not page's plan is updated.
      def authenticated?
        !current_user.blank?
      end

      # Store user in session as current_user
      #
      def authenticate(user)
        raise Unauthorized unless user
        session[:current_user] = user.id
      end

      # Create and authenticate current_user by signed_request.
      # if signed_request was not given, do nothing.
      # if signed_request was not authorized(means user didn't installed app), do nothing.
      #
      def auth_with_signed_request
        return unless params[:signed_request]

        auth = Facebook.auth.from_signed_request(params[:signed_request])
        unless auth.authorized?
          unauthenticate
          return
        end
        authenticate ::User.identify(auth.user)
      end

      # Delete current_user
      #
      def unauthenticate
        current_user.try(:destroy)
        @current_user = session[:current_user] = nil
      end
    end
  end
end
