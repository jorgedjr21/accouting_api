# frozen_string_literal: true

# Account model: represents the bank account
class Account < ApplicationRecord
  has_secure_token :auth_token
  validates :name, :balance, presence: true
  validates :balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
