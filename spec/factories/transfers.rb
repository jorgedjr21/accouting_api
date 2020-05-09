FactoryBot.define do
  factory :transfer do
    amount { 1 }
    transaction_type { 'debit' }
    association :account
  end
end
