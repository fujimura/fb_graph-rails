module FbGraph::Rails
  module User
    extend ActiveSupport::Concern

    module ClassMethods
      def facebook_attributes(*args)
        args = args.dup
        options = args.last.is_a?(Hash) ? args.pop : {}

        define_method :facebook_identifier do
          self.send(options[:identifier] || :identifier)
        end

        delegate *(args << {:to => :profile})
      end

      # Create or find user, and refresh token.
      #
      # @return user
      def identify(fb_user)
        user = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
        user.access_token = fb_user.access_token
        user.save!
        user
      end
    end

    module InstanceMethods

      def profile
        @profile ||= FbGraph::User.fetch(facebook_identifier,
                                         :access_token => access_token)
      end

      def permissions
        @permissions ||= FbGraph::User.fetch(facebook_identifier,
                                             :access_token => access_token).permissions
      end

      def permits?(*requred_permissions)
        (requred_permissions - permissions).empty?
      end

    end

  end
end
