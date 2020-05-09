class TransfersController < ApplicationController
  before_action :set_accounts, only: :create

  def create
    return handle_transfer_creation if (@source_account.balance - debit_params[:amount].to_i).positive?

    render json: { message: "The source account #{@source_account.id} doesn't has available balance to do this transaction!" }, status: :bad_request
  end

  private

  def transfer_params
    params.permit(:source_account_id, :destination_account_id, :amount)
  end

  def debit_params
    debit = transfer_params
    debit.delete(:destination_account_id)
    debit[:account_id] = debit.delete(:source_account_id)
    debit[:transaction_type] = 'debit'
    debit
  end

  def credit_params
    credit = transfer_params
    credit.delete(:source_account_id)
    credit[:account_id] = credit.delete(:destination_account_id)
    credit[:transaction_type] = 'credit'
    credit
  end

  def set_accounts
    @source_account = Account.find_by(id: transfer_params[:source_account_id]) if transfer_params[:source_account_id].present?
    @destination_account = Account.find_by(id: transfer_params[:destination_account_id]) if transfer_params[:destination_account_id].present?
    return render json: { message: 'Source Account or Destination Account not found' }, status: :bad_request if @source_account.blank? || @destination_account.blank?
  end

  def handle_transfer_creation
    transfer_status = :created
    transfer_feedback = { message: 'Debit and Credit transactions done with success' }

    Transfer.transaction do
      debit = Transfer.new(debit_params)
      credit = Transfer.new(credit_params)

      unless debit.save
        transfer_feedback = { message: 'Cant debit the value in the source account', errors: debit.errors }
        transfer_status = :bad_request
        raise ActiveRecord::Rollback
      end

      unless credit.save
        transfer_feedback = { message: 'Cant do the credit in the destination account', errors: credit.errors }
        transfer_status = :bad_request
        raise ActiveRecord::Rollback
      end
    end

    render json: transfer_feedback, status: transfer_status
  end
end
