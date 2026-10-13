class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: true, index: { unique: true }
      t.string :otp_secret, null: true
      t.boolean :otp_enabled, null: false, default: false
      t.timestamps
    end

  end
end
