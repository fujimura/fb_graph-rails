require 'spec_helper'

describe ApplicationController do
  include RSpec::Rails::ControllerExampleGroup
  let(:user) { FactoryGirl.create :user }

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
    it 'should raise UserDoesNotAuthenticated if Unauthorized was raised at asking permissions' do
      mock(user).permits?.with_any_args { raise FbGraph::Unauthorized.new('aaa') }
      controller.instance_variable_set '@current_user', user
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
      mock(controller).redirect_to.with_any_args
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
      it { should respond_with :redirect }
      it 'should redirect to facebook with current request uri' do
        response.header['Location'].should =~ /#{"redirect_uri=" + CGI.escape(request.url)}/
      end
    end
  end

  describe 'require with array of permissions' do
    controller do
      require_user_with [:user_birthday, :email]
      def index
        render :nothing => true, :status => 200
      end
    end

    before do
      user.instance_variable_set '@permissions', [:user_birthday, :email]
      controller.instance_variable_set '@current_user', user
      get :index
    end
    it { should respond_with :success }
  end

  describe 'require user_birthday and email, rescue with given block' do
    controller do
      require_user_with :user_birthday, :email do
        relocate_to oauth_permission_url_for([:user_birthday, :email])
      end

      def index
        render :nothing => true, :status => 200
      end
    end

    before do
      user.instance_variable_set '@permissions', []
      controller.instance_variable_set '@current_user', user
      get :index
    end

    it { should relocate_to controller.send(:oauth_permission_url_for, [:user_birthday, :email]) }
  end

  describe '#current_user' do
    context 'user in session' do
      before do
        session[:current_user] = user.id
      end
      subject { controller.current_user }
      it { should == user }
    end
    context 'no user in session' do
      before do
        session[:current_user] = nil
      end
      subject { controller.current_user }
      it { should be_nil }
    end
    context 'user who does not exists' do
      before do
        session[:current_user] = user.id + 1
      end
      subject { controller.current_user }
      it { should be_nil }
    end
  end

  describe '#authenticate' do
    context 'with user' do
      it 'should set users id to sessin' do
        controller.authenticate user
        session[:current_user].should == user.id
      end
    end
    context 'with nil' do
      it 'should raise Unauthorized' do
        lambda { controller.authenticate nil }.should raise_error FbGraph::Rails::Unauthorized
      end
    end
  end

  describe '#auth_with_signed_request' do
    it 'should do nothing unless signed_request was given in params' do
      dont_allow(FbGraph::Auth).new
      controller.params[:signed_request] = nil
      controller.auth_with_signed_request
      true.should be_true # hmmm
    end

    context 'authorization succeed' do
      let(:new_user) { FactoryGirl.create(:user) }
      before do
        controller.instance_variable_set '@current_user', user
        auth = FbGraph::Auth.new('a', 'b')
        stub(FbGraph::Auth).new.with_any_args do
          auth.access_token = 'aaa'
          auth.user = new_user
          auth
        end
        controller.params[:signed_request] = 'a'
        controller.auth_with_signed_request
      end
      it 'should authenticate with new user' do
        controller.current_user.should == new_user
      end
    end
    context 'authorization failed' do
      before do
        auth = FbGraph::Auth.new('a', 'b')
        stub(FbGraph::Auth).new.with_any_args do
          auth.access_token = false
          auth
        end
        controller.instance_variable_set '@current_user', user
        controller.params[:signed_request] = 'a'
        controller.auth_with_signed_request
      end
      it 'should unauthenticate user' do
        controller.current_user.should be_nil
      end
    end

    context '#unauthenticate' do
      before do
        controller.instance_variable_set '@current_user', user
        controller.unauthenticate
      end
      it 'should delete access_token of user' do
        ::User.find_by_id(user.id).access_token.should be_nil
      end
      it 'should delete user id in session' do
        controller.session[:current_user].should be_nil
      end
      it 'should delete current_user' do
        controller.current_user.should be_nil
      end
      it 'should not raise even current_user does not exist' do
        lambda { controller.unauthenticate }.should_not raise_error
      end
    end
  end
end
