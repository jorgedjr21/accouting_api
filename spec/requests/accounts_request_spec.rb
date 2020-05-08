require 'rails_helper'
# frozen_string_literal: true

RSpec.describe 'Accounts', type: :request do
  describe 'POST /create' do
    context 'with valid params' do
      let(:valid_params) do
        {
          id: rand(1..100),
          name: 'Account',
          balance: 100
        }
      end

      context 'when account not exists' do
        it 'must create a new account' do
          expect { post '/accounts', params: valid_params }.to change(Account, :count).by(1)
        end

        it 'must return the new account auth token' do
          post '/accounts', params: valid_params
          body = JSON.parse(response.body)

          expect(body['auth_token']).not_to be_nil
        end

        it 'must create the account with the given id' do
          expected_id = valid_params[:id]
          post '/accounts', params: valid_params
          body = JSON.parse(response.body)

          expect(body['account_id']).to eq(expected_id)
        end
      end

      context 'when id is not informed' do
        let(:valid_params_no_id) do
          {
            name: 'No Id Account',
            balance: 200
          }
        end

        it 'must create the new account' do
          expect { post '/accounts', params: valid_params_no_id }.to change(Account, :count).by(1)
        end

        it 'must set the id automaticaly' do
          post '/accounts', params: valid_params_no_id
          body = JSON.parse(response.body)

          expect(body['account_id']).not_to be_nil
        end
      end

      context 'when account already exists' do
        let!(:account) { create(:account) }
        let(:params_with_account) do
          {
            id: account.id,
            name: 'teste',
            balance: 123_456
          }
        end

        it 'must not create a new account' do
          expect { post '/accounts', params: params_with_account }.not_to change(Account, :count)
        end

        it 'must return info from created account' do
          post '/accounts', params: params_with_account
          body = JSON.parse(response.body)

          expect(body['account_id']).to eq(account.id)
          expect(body['auth_token']).to eq(account.auth_token)
        end
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          name: nil,
          balance: 'hundred'
        }
      end

      it 'must not create the account' do
        expect { post '/accounts', params: invalid_params }.not_to change(Account, :count)
      end

      it 'must show the json errors' do
        post '/accounts', params: invalid_params
        body = JSON.parse(response.body)

        expect(body).to include('errors')
      end
    end
  end
end
