module FbGraph::Rails
  module User

    extend ActiveSupport::Concern

    module ClassMethods
      def facebook_attributes(*args)
        args = args.dup
        options, attrs = args.extract_options!, args.flatten

        define_method :facebook_identifier do
          self.send(options[:identifier] || :identifier)
        end

        delegate *(attrs << {:to => :profile})
      end

      # Create or find user, and refresh token.
      #
      # @return user
      def identify(fb_user)
        user = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
        user.access_token = fb_user.access_token.to_s
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
        (requred_permissions.flatten - permissions).empty?
      end

    end

  end
end
