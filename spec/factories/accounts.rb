# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    id { rand(1..1000) }
    name { 'Account Name' }
    balance { 100 }
    auth_token { SecureRandom.hex(10) }
  end
end
