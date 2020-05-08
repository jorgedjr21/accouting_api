require 'rails_helper'

RSpec.describe 'Transfers', type: :request do
  let!(:source_account) { create(:account, balance: 100_000) }
  let!(:destination_account) { create(:account, balance: 1000) }

  describe 'POST accounts/transfer' do
    context 'with valid params' do
      let(:valid_params) do
        {
          source_account_id: source_account.id,
          destination_account_id: destination_account.id,
          amount: 900
        }
      end

      it 'must save the transfers' do
        expect { post '/accounts/transfer', params: valid_params }.to change(Transfer, :count).by(2)
      end

      it 'must have the debit transfer for source account' do
        post '/accounts/transfer', params: valid_params
        transfer = Transfer.where(account_id: source_account.id).last
        expect(transfer.transaction_type).to eq('debit')
      end

      it 'must have the credit transfer for destination account' do
        post '/accounts/transfer', params: valid_params
        transfer = Transfer.where(account_id: destination_account.id).last
        expect(transfer.transaction_type).to eq('credit')
      end

      it 'must have http status 201' do
        post '/accounts/transfer', params: valid_params
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          source_account_id: nil,
          destination_account_id: destination_account.id,
          amount: 'test'
        }
      end

      it 'must not save the transfers' do
        expect { post '/accounts/transfer', params: invalid_params }.not_to change(Transfer, :count)
      end

      it 'must have status 400' do
        post '/accounts/transfer', params: invalid_params
        expect(response).to have_http_status(400)
      end
    end
  end
end
