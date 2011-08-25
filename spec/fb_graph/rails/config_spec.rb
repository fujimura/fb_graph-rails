require 'spec_helper'

describe FbGraph::Rails::Config do
  FbGraph::Rails::Config.instance_variable_set '@canvas_url', nil
  FbGraph::Rails::Config.instance_variable_set '@u', nil
  describe '#canvas_url' do
    let(:canvas_url) { "http://apps.facebook.com/fb_graph-rails" } # see config/facebook.yml
    let(:client_id) { 115997921798478 } # see config/facebook.yml
    let(:another_client_id) { 222 } # see config/facebook.yml

    context 'with ENV' do
      it 'should return value in env' do
        stub(FbGraph::Rails::Config).from_yaml { nil }
        mock(ENV).[]("fb_client_id") { another_client_id }
        FbGraph::Rails::Config.client_id.should == another_client_id
      end
    end

    context 'with yaml' do
      it 'should return value in config file' do
        FbGraph::Rails::Config.canvas_url.should == canvas_url
      end
      it 'should memoize value' do
        dont_allow(YAML).load_file
        FbGraph::Rails::Config.canvas_url
      end
    end
  end
end
