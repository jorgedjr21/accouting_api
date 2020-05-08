class Transfer < ApplicationRecord
  belongs_to :account
  validates :account_id, :transaction_type, :amount, presence: true
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
