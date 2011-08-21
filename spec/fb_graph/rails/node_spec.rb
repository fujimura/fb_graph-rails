require 'spec_helper'

describe FbGraph::Rails::Node, '#delegate_to_facebook' do
  let(:identifier) { 2030 }
  let(:name) { 'FbGraph Rails Page' }
  describe 'with default setting' do
    let(:like_count) { 120 }
    before :all do
      class Page
        include FbGraph::Rails::Node
        attr_accessor :identifier
        delegate_to_facebook :name, :like_count #, :rescue_nil => true

        def initialize(identifier)
          @identifier = identifier
        end
      end
    end
    context 'fetch succeed' do
      before do
        stub(FbGraph::Page).fetch(identifier) do
          FbGraph::Page.new(identifier,
                            :name => name,
                            :likes => like_count)
        end
      end
      subject { Page.new(identifier) }
      its(:name) { should == name }
      its(:like_count) { should == like_count }
    end
    context 'fetch failed' do
      before do
        stub(FbGraph::Page).fetch(identifier) do
          raise FbGraph::NotFound.new 'not found'
        end
      end
      it 'should raise FbGraph::NotFound' do
        expect {
          Page.new(identifier).name
        }.to raise_error FbGraph::NotFound
      end
    end
  end
  describe 'with specifying identifier attribute and ignore errors' do
    let(:fb_id) { 30010 }
    let(:location) { 'Kawasaki' }
    before :all do
      class Event
        include FbGraph::Rails::Node
        attr_accessor :fb_id
        delegate_to_facebook :name, :location, :identifier => :fb_id, :ignore_errors => true

        def initialize(options)
          @fb_id = options[:fb_id]
        end
      end
    end
    context 'fetch succeed' do
      before do
        stub(FbGraph::Event).fetch(fb_id) do
          FbGraph::Event.new(fb_id,
                             :name => name,
                             :location => location)
        end
      end
      subject { Event.new(:fb_id => fb_id) }
      its(:name) { should == name }
      its(:location) { should == location }
    end
    context 'fetch succeed' do
      before do
        stub(FbGraph::Event).fetch(fb_id) do
          raise FbGraph::NotFound.new 'not found'
        end
      end
      subject { Event.new(:fb_id => fb_id) }
      its(:name) { should be_nil }
    end
  end
end
