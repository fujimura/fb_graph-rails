require 'spec_helper'

RSpec.configure do |c|
  c.include RSpec::Rails::ControllerExampleGroup
end

describe ApplicationController do
  let(:user) { Factory.create :user }

  describe 'filter method' do
    let(:filter_method_name) { :require_user_with_user_birthday_email }
    controller do
      require_user_with :user_birthday, :email
      def index
        render :nothing => true, :status => 200
      end
    end

    it 'should be defined' do
      controller.respond_to?(:require_user_with_user_birthday_email).should be_true
    end
    it 'should raise UserDoesNotAuthenticated unless current_user' do
      stub(controller).current_user { nil }
      lambda { controller.send(filter_method_name) }.should raise_error FbGraph::Rails::UserDoesNotAuthenticated
    end
    it 'should raise UserDoesNotAuthenticated with no permissions' do
      controller.instance_variable_set '@current_user', user
      user.instance_variable_set '@permissions', []
      lambda { controller.send(filter_method_name) }.should raise_error FbGraph::Rails::UserDoesNotAuthenticated
    end
    it 'should raise UserDoesNotAuthenticated if lacking some permissions' do
      controller.instance_variable_set '@current_user', user
      user.instance_variable_set '@permissions', [:user_birthday]
      lambda { controller.send(filter_method_name) }.should raise_error FbGraph::Rails::UserDoesNotAuthenticated
    end
    it 'should be set as before filter' do
      controller._process_action_callbacks.any? do |filter|
        filter.kind == :before && filter.raw_filter == filter_method_name
      end.should be_true
    end
  end

  describe 'filter method with condition' do
    controller do
      require_user_with :user_birthday, :if => lambda { 1 == 1 }
      def index
        render :nothing => true, :status => 200
      end
    end

    it 'should be set as before filter' do
      controller._process_action_callbacks.any? do |filter|
        filter.options[:if].any?
      end.should be_true
    end
  end

  describe 'rescue method' do
    controller do
      require_user_with :user_birthday, :email
      def index
        render :nothing => true, :status => 200
      end
    end

    let(:rescue_method_name) { :rescue_from_user_birthday_email }
    let(:exception) { FbGraph::Rails::UserDoesNotAuthenticated.new [:user_birthday, :email] }
    let(:other_exception) { FbGraph::Rails::UserDoesNotAuthenticated.new [:read_stream, :user_website] }

    it 'should be defined' do
      controller.respond_to?(:rescue_from_user_birthday_email).should be_true
    end
    it 'should rescue exception with given permission' do
      mock(controller).relocate_to(controller.send(:oauth_permission_url_for, [:user_birthday, :email]))
      lambda { controller.send(rescue_method_name, exception) }.should_not raise_error
    end
    it "should raise exception with permission which doesn't match with given ones" do
      lambda {
        controller.send(rescue_method_name, other_exception)
      }.should raise_error FbGraph::Rails::UserDoesNotAuthenticated
    end
    it 'should be registered as rescue handler' do
      controller.rescue_handlers.any? do |handler|
        handler.first == FbGraph::Rails::UserDoesNotAuthenticated.to_s && handler.second == rescue_method_name
      end.should be_true
    end
  end

  describe 'require user_birthday and email' do
    controller do
      require_user_with :user_birthday, :email
      def index
        render :nothing => true, :status => 200
      end
    end

    context "access by user with permissions" do
      before do
        user.instance_variable_set '@permissions', [:user_birthday, :email]
        controller.instance_variable_set '@current_user', user
        get :index
      end
      it { should respond_with :success }
    end

    context "access by user without permissions" do
      before do
        user.instance_variable_set '@permissions', []
        controller.instance_variable_set '@current_user', user
        get :index
      end
      it { should relocate_to controller.send(:oauth_permission_url_for, [:user_birthday, :email]) }
    end

  end

end
