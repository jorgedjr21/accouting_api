# frozen_string_literal: true

# Account model: represents the bank account
class Account < ApplicationRecord
  has_secure_token :auth_token
  has_many :debts, -> { where type: 'debit' }, class_name: 'Transfer', foreign_key: 'account_id', inverse_of: :transfer
  has_many :credits, -> { where type: 'credit' }, class_name: 'Transfer', foreign_key: 'account_id', inverse_of: :transfer

  validates :name, :balance, presence: true
  validates :balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
