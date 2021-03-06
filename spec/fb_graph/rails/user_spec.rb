require 'spec_helper'

describe FbGraph::Rails::User do
  let(:user) { FactoryGirl.create :user }
  let(:me) do
    me = FbGraph::User.new(user.identifier,
                           :email => "me@fujimuradaisuke.com",
                           :interested_in => [:female],
                           :access_token => user.access_token)
    stub(me).permissions {[:email, :interested_in]}
    me
  end

  describe '.facebook_attributes' do
    before do
      stub(FbGraph::User).fetch(user.identifier, :access_token => user.access_token) { me }
    end
    subject { user }
    its(:email) { should == "me@fujimuradaisuke.com" }
    its(:interested_in) { should == [:female] }
    its(:permissions) { should == [:email, :interested_in] }
    it 'should be memoized' do
      user.email
      user.permissions
      dont_allow(FbGraph::User).fetch
      user.email
      user.permissions
    end
  end

  describe '.identify' do
    context 'for existing user' do
      before do
        @user = User.identify me
      end
      subject { @user }
      its(:id)           { should == user.id }
      its(:identifier)   { should == user.identifier }
      its(:access_token) { should == user.access_token }
    end
    context 'for new user' do
      before do
        @identifier = rand(10**10).to_s
        @access_token = 86.times.inject('') {|r, i| r = r + ('a'..'z').to_a[rand(26)]}
        new_fb_user = FbGraph::User.new(@identifier,
                                        :email => "me@fujimuradaisuke.com",
                                        :interested_in => [:female],
                                        :access_token => @access_token)
        @new_user = User.identify new_fb_user
      end
      subject { @new_user }
      its(:persisted?)   { should == true }
      its(:identifier)   { should == @identifier }
      its(:access_token) { should == @access_token }
    end
  end

  describe '.facebook_attributes' do
  end

  describe '#permits?' do
    before do
      stub(FbGraph::User).fetch(user.identifier, :access_token => user.access_token) { me }
    end
    it 'should be true if :email was given' do
      user.permits?(:email).should be_true
    end
    it 'should be true if :interested_in was given' do
      user.permits?(:interested_in).should be_true
    end
    it 'should be true if :email and :interested_in was given' do
      user.permits?(:email, :interested_in).should be_true
    end
    it 'should be true if :email and :interested_in was given as array' do
      user.permits?([:email, :interested_in]).should be_true
    end
    it 'should be false if :education was given' do
      user.permits?(:education).should be_false
    end
    it 'should be false if :education and :interested_in was given' do
      user.permits?(:education, :interested_in).should be_false
    end
  end

  describe 'with options' do
    before :all do
      class Person
        include FbGraph::Rails::User
        attr_accessor :facebook_id, :access_token
        facebook_attributes :email, :identifier => :facebook_id
        def initialize(options)
          @facebook_id = options[:facebook_id]
          @access_token = options[:access_token]
        end
      end
    end
    let(:facebook_id)  { 1984 }
    let(:email)        { 'admin@fujimuradaisuke.com' }
    let(:access_token) { 'fififi' }
    let(:person)       { Person.new(:facebook_id => facebook_id, :access_token => access_token) }
    it 'should respect given options' do
      stub(FbGraph::User).fetch(facebook_id, :access_token => access_token) do
        FbGraph::User.new(facebook_id,
                          :email => email,
                          :access_token => access_token)
      end
      person.email.should == email
    end
  end
end

