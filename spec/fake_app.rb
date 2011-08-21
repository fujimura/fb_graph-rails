# Stolen from https://github.com/amatsuda/kaminari/blob/master/spec/fake_app.rb
# Thanks a_matsuda ;-)

require 'active_record'
require 'action_dispatch'
require 'action_controller'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'fb_graph/rails'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => File.join(File.dirname(__FILE__), 'db')}}
ActiveRecord::Base.establish_connection('test')

# config
app = Class.new(Rails::Application)
app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
app.config.secret_token = "3csos08ef99qwed99vjaskf9urjeeeel"
app.config.session_store :cookie_store, :key => "_myapp_session"
app.config.active_support.deprecation = :log
app.initialize!

# routes
app.routes.draw do
  root :to => 'users#index'
  resources :users
end

# models
class User < ActiveRecord::Base
  include FbGraph::Rails::User
  delegate_to_facebook :email, :interested_in
end

# controllers
class ApplicationController < ActionController::Base; end

# helpers
Object.const_set(:ApplicationHelper, Module.new)

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string   "identifier", :limit => 20
      t.string   "access_token"
    end
  end
end

class Facebook
  class << self
    def config
      @config ||= {
          :client_id     => 'abc',
          :client_secret => 'def',
          :canvas_url => 'http://apps.facebook.com/fb_graph-rails'
      }
    end

    def canvas_url
      config[:canvas_url]
    end

    def client_id
      config[:client_id]
    end

    def auth
      FbGraph::Auth.new config[:client_id], config[:client_secret]
    end

    def auth_from_signed_request(signed_request)
      auth.from_signed_request signed_request
    end
  end
end
