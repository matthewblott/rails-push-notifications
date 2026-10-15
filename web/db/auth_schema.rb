# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_27_140340) do
  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "device_token"
    t.integer "platform"
    t.string "push_token"
    t.string "push_endpoint"
    t.boolean "push_enabled", default: true
    t.datetime "push_token_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["device_token"], name: "index_sessions_on_device_token", unique: true
    t.index ["push_endpoint"], name: "index_sessions_on_push_endpoint", unique: true
    t.index ["push_token"], name: "index_sessions_on_push_token", unique: true
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "otp_secret"
    t.boolean "otp_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "sessions", "users"
end
