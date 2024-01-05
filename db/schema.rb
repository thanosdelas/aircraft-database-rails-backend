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

ActiveRecord::Schema[7.1].define(version: 2024_01_05_135712) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aircraft", force: :cascade do |t|
    t.string "model", null: false
    t.boolean "wikipedia_info_collected", default: false
    t.string "wikipedia_title"
    t.string "featured_image"
    t.string "infobox_hash"
    t.string "infobox_raw"
    t.string "description"
    t.string "snippet"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aircraft_images", force: :cascade do |t|
    t.string "url", null: false
    t.string "filename", null: false
    t.string "description"
    t.bigint "aircraft_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id", "url"], name: "index_aircraft_images_on_url_and_aircraft_id", unique: true
    t.index ["aircraft_id"], name: "index_aircraft_images_on_aircraft_id"
    t.index ["filename"], name: "index_aircraft_images_on_filename"
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "group"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_user_groups_on_group", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "user_group_id"
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_on_users", unique: true
    t.index ["user_group_id"], name: "index_users_on_user_group_id"
    t.index ["username"], name: "index_username_on_users", unique: true
  end

  add_foreign_key "aircraft_images", "aircraft"
  add_foreign_key "users", "user_groups"
end
