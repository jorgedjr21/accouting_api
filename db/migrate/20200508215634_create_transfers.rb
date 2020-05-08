class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.integer :amount
      t.string :transaction_type, default: 'debit'
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
