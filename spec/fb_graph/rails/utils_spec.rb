require 'spec_helper'

describe FbGraph::Rails::Utils do
  include RSpec::Rails::ControllerExampleGroup

  describe '#canvas_url_for' do
    controller do
      def index ; render :nothing => true, :status => 200 ; end
    end
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

  describe '#relocate_to' do
    controller do
      def index
        relocate_to root_path
      end
    end
    it 'should render relocation code to given url' do
      get :index
      should relocate_to root_path
      response.body.should == "<script>top.location = '/'</script>"
    end
  end
end
