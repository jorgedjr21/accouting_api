# frozen_string_literal: true

# Handle the accounts requests render json: { errors: new_account.errors }, status: :bad_request
class AccountsController < ApplicationController
  before_action :validate_token, only: :balance
  before_action :set_account

  # GET accounts/:id/balance shows the account balance
  def balance
    return render json: { message: "Account doesn't exists, please try again!" }, status: :not_found if @account.blank?

    render json: { account_id: @account.id, balance: @account.balance.to_f / 100 }, status: :ok
  end

  # POST accounts/ create new account
  def create
    return render json: { message: "Account #{@account.id} already exists", account_id: @account.id, auth_token: @account.auth_token }, status: :ok if @account.present?

    feedback, status = handle_account_creation
    render json: feedback, status: status
  end

  private

  def account_params
    params.permit(:id, :name)
  end

  def first_transfer_params(params, account)
    params.permit(:amount).merge(account_id: account.id, transaction_type: 'credit')
  end

  def set_account
    @account = Account.find_by(id: account_params[:id]) if account_params[:id].present?
  end

  def handle_account_creation
    account_status = :created
    account_feedback = {}

    Account.transaction do
      new_account = Account.new(account_params)

      unless new_account.save
        account_status = :bad_request
        account_feedback = { message: 'Cant create the account', errors: new_account.errors }
        return [account_feedback, account_status]
      end

      account_feedback = { message: 'Account created with success', auth_token: new_account.auth_token, account_id: new_account.id }
      transfer_params = first_transfer_params(params, new_account)
      transfer = Transfer.new(transfer_params)
      unless transfer.save
        account_feedback = { message: 'Cant create the account', errors: transfer.errors }
        account_status = :bad_request
        raise ActiveRecord::Rollback
      end
    end

    [account_feedback, account_status]
  end
end
