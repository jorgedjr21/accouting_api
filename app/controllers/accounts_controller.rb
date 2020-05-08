# frozen_string_literal: true

# Handle the accounts requests
class AccountsController < ApplicationController
  before_action :set_account, only: :create

  # POST accounts/ create new account
  def create
    return render json: { message: "Account #{@account.id} already exists", account_id: @account.id, auth_token: @account.auth_token }, status: :ok if @account.present?

    new_account = Account.new(account_params)
    if new_account.save
      render json: { message: "The account #{new_account.id} was created!", account_id: new_account.id, auth_token: new_account.auth_token }, status: :created
    else
      render json: { errors: new_account.errors }, status: :bad_request
    end
  end

  private

  def account_params
    params.permit(:id, :name, :balance)
  end

  def set_account
    @account = Account.find_by(id: account_params[:id]) if account_params[:id].present?
  end
end
