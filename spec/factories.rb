FactoryGirl.define do
  factory :user do
    identifier { rand(10**10) }
    access_token 'abcdefg'
  end
end
