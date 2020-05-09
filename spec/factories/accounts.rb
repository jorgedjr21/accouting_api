# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    id { rand(1..1000) }
    name { 'Account Name' }
    auth_token { SecureRandom.hex(10) }

    trait :with_balance do
      after :create do |acc|
        create :transfer, amount: 100_00, transaction_type: 'credit', account: acc
      end
    end
  end
end
