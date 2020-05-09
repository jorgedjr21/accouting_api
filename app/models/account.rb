# frozen_string_literal: true

# Account model: represents the bank account
class Account < ApplicationRecord
  has_secure_token :auth_token
  has_many :debts, -> { where transaction_type: 'debit' }, class_name: 'Transfer', foreign_key: 'account_id'
  has_many :credits, -> { where transaction_type: 'credit' }, class_name: 'Transfer', foreign_key: 'account_id'

  validates :name, presence: true

  def balance
    (credits.pluck(:amount).map(&:to_i).sum + (debts.pluck(:amount).map(&:to_i).sum * -1))
  end
end
