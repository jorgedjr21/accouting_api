# frozen_string_literal: true

# Account model: represents the bank account
class Account < ApplicationRecord
  has_secure_token :auth_token
end
