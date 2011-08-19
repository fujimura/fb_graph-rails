require 'rails'
require 'fb_graph'
require 'action_controller'

module FbGraph
  module Rails
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
  end
end

require File.join(File.dirname(__FILE__), 'rails', 'node')
require File.join(File.dirname(__FILE__), 'rails', 'user')
require File.join(File.dirname(__FILE__), 'rails', 'utils')
require File.join(File.dirname(__FILE__), 'rails', 'authentication')

ActionController::Base.send :include, FbGraph::Rails::Utils
ActionController::Base.send :include, FbGraph::Rails::Authentication
