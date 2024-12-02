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

ActiveRecord::Schema[7.1].define(version: 2024_12_02_161944) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.bigint "step_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address"
    t.index ["step_id"], name: "index_activities_on_step_id"
  end

  create_table "chatrooms", force: :cascade do |t|
    t.bigint "first_user_id", null: false
    t.bigint "second_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["first_user_id"], name: "index_chatrooms_on_first_user_id"
    t.index ["second_user_id"], name: "index_chatrooms_on_second_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "sloopy_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sloopy_id"], name: "index_favorites_on_sloopy_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.boolean "status"
    t.bigint "sender_id", null: false
    t.bigint "chatroom_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "preferences", force: :cascade do |t|
    t.string "category"
    t.string "choice"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.integer "rating"
    t.bigint "sloopy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sloopy_id"], name: "index_reviews_on_sloopy_id"
  end

  create_table "sloopies", force: :cascade do |t|
    t.string "origin"
    t.string "destination"
    t.date "departure_date"
    t.date "return_date"
    t.integer "budget"
    t.integer "duration"
    t.boolean "status", default: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "summary"
    t.float "origin_latitude"
    t.float "origin_longitude"
    t.float "destination_latitude"
    t.float "destination_longitude"
    t.string "budget_estimated"
    t.index ["user_id"], name: "index_sloopies_on_user_id"
  end

  create_table "steps", force: :cascade do |t|
    t.string "city"
    t.bigint "sloopy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transport"
    t.string "cost"
    t.integer "duration"
    t.float "latitude"
    t.float "longitude"
    t.string "city_stop"
    t.integer "stays"
    t.index ["sloopy_id"], name: "index_steps_on_sloopy_id"
  end

  create_table "user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "preference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preference_id"], name: "index_user_preferences_on_preference_id"
    t.index ["user_id"], name: "index_user_preferences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname"
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "steps"
  add_foreign_key "chatrooms", "users", column: "first_user_id"
  add_foreign_key "chatrooms", "users", column: "second_user_id"
  add_foreign_key "favorites", "sloopies"
  add_foreign_key "favorites", "users"
  add_foreign_key "messages", "chatrooms"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "reviews", "sloopies"
  add_foreign_key "sloopies", "users"
  add_foreign_key "steps", "sloopies"
  add_foreign_key "user_preferences", "preferences"
  add_foreign_key "user_preferences", "users"
end
