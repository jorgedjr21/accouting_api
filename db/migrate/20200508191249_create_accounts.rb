class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :auth_token

      t.timestamps
    end
    add_index :accounts, :auth_token, unique: true
  end
end
