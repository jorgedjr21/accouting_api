require 'rails_helper'

RSpec.describe 'Transfers', type: :request do
  let!(:source_account) { create(:account, :with_balance) }
  let!(:destination_account) { create(:account, :with_balance) }

  describe 'POST accounts/transfer' do
    
    context 'when not providing auth_token' do
      let(:params) do
        {
          source_account_id: source_account.id,
          destination_account_id: destination_account.id,
          amount: 900
        }
      end

      it 'must not save the transfer' do
        expect { post '/accounts/transfer', params: params }.not_to change(Transfer, :count)
      end

      it 'must have status 403' do
        post '/accounts/transfer', params: params
        expect(response).to have_http_status(403)
      end
    end

    context 'when providing wrong auth_token' do
      let(:params) do
        {
          source_account_id: source_account.id,
          destination_account_id: destination_account.id,
          auth_token: 'wrong',
          amount: 900
        }
      end

      it 'must not save the transfer' do
        expect { post '/accounts/transfer', params: params }.not_to change(Transfer, :count)
      end

      it 'must have status 403' do
        post '/accounts/transfer', params: params
        expect(response).to have_http_status(403)
      end
    end

    context 'when providing destination_account token' do
      let(:params) do
        {
          source_account_id: source_account.id,
          destination_account_id: destination_account.id,
          auth_token: destination_account.auth_token,
          amount: 900
        }
      end

      it 'must not save the transfer' do
        expect { post '/accounts/transfer', params: params }.not_to change(Transfer, :count)
      end

      it 'must have status 403' do
        post '/accounts/transfer', params: params
        expect(response).to have_http_status(403)
      end
    end

    context 'providing auth_token' do
      context 'with valid params' do
        let(:valid_params) do
          {
            source_account_id: source_account.id,
            destination_account_id: destination_account.id,
            auth_token: source_account.auth_token,
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
          expect(transfer.amount).to eq(900)
        end

        it 'must have http status 201' do
          post '/accounts/transfer', params: valid_params
          expect(response).to have_http_status(201)
        end
      end

      context 'with invalid params' do
        let(:invalid_params) do
          {
            source_account_id: source_account.id,
            destination_account_id: destination_account.id,
            auth_token: source_account.auth_token,
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

      context 'when source-account does not has balance' do
        let(:transfer_params) do
          {
            source_account_id: source_account.id,
            destination_account_id: destination_account.id,
            auth_token: source_account.auth_token,
            amount: 900_000
          }
        end

        it 'must not do the transfers' do
          expect { post '/accounts/transfer', params: transfer_params }.not_to change(Transfer, :count)
        end

        it 'must have the balance error message' do
          post '/accounts/transfer', params: transfer_params
          body = JSON.parse(response.body)

          expect(body['message']).to eq("The source account #{source_account.id} doesn't has available balance to do this transaction!")
        end

        it 'must have status 400' do
          post '/accounts/transfer', params: transfer_params
          expect(response).to have_http_status(400)
        end
      end
    end
  end
end
