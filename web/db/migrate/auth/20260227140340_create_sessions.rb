class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :device_token, null: true, index: { unique: true }

      t.integer :platform                    # enum: ios / android
      t.string :push_token                   # APNs device token (iOS)
      t.string :push_endpoint                # UnifiedPush endpoint URL (Android)
      t.boolean :push_enabled, default: true
      t.datetime :push_token_updated_at
      t.index :push_token, unique: true
      t.index :push_endpoint, unique: true

      t.timestamps
    end
  end
end
