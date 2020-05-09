require 'rails_helper'
# frozen_string_literal: true

RSpec.describe Account, type: :model do
  let(:source_account) { create(:account, :with_balance) }
  let(:destination_account) { create(:account, :with_balance) }
  let(:account_without_transfer) { create(:account) }
  let!(:transfer_1) { create(:transfer, account_id: source_account.id, amount: 2500) }
  let!(:transfer_2) { create(:transfer, account_id: destination_account.id, transaction_type: 'credit', amount: 2500) }

  describe '#balance' do
    context 'when has transfers' do
      it 'must show correct value of balance' do
        expect(source_account.balance).to eq(7500)
        expect(destination_account.balance).to eq(125_00)
      end
    end

    context 'when does not has transfers' do
      it 'must be have 0 of balance' do
        expect(account_without_transfer.balance).to be_zero
      end
    end
  end
end
