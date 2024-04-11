class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :meta_mask_address
      t.string :meta_mask_nonce

      t.timestamps
    end
  end
end
