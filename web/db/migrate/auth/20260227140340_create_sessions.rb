class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_token, null: true, index: { unique: true }
      t.timestamps
    end
  end
end
