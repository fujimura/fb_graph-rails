FactoryGirl.define do

  factory :user do
    identifier { rand(10**10).to_s }
    access_token { 86.times.inject('') {|r, i| r = r + ('a'..'z').to_a[rand(26)]} }
  end

end
