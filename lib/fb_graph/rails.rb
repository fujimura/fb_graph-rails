require 'fb_graph'
require 'rails'
require 'action_controller'

module FbGraph
  module Rails
  end
end

require File.join(File.dirname(__FILE__), 'rails', 'authentication')
require File.join(File.dirname(__FILE__), 'rails', 'node')
require File.join(File.dirname(__FILE__), 'rails', 'user')
require File.join(File.dirname(__FILE__), 'rails', 'utils')

ActionController::Base.send :include, FbGraph::Rails::Utils
ActionController::Base.send :include, FbGraph::Rails::Authentication
