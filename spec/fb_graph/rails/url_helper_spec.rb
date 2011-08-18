require 'spec_helper'

describe FbGraph::Rails::UrlHelper do
  include RSpec::Rails::ControllerExampleGroup

  controller do
    def index
      render :nothing => true, :status => 200
    end
  end
  describe '#canvas_url_for' do
    it 'should return valid url' do
      controller.canvas_url_for('foo/bar').should == 'http://apps.facebook.com/fb_graph-rails/foo/bar'
    end

    it 'should remove duplicating /s' do
      controller.canvas_url_for('/foo/bar').should == 'http://apps.facebook.com/fb_graph-rails/foo/bar'
    end

    it 'should return url for resource' do
      u = Factory.create :user
      controller.canvas_url_for(User.find(u.id)).should ==  "http://apps.facebook.com/fb_graph-rails/users/#{u.id}"
    end
  end
end
