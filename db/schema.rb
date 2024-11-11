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

ActiveRecord::Schema[7.1].define(version: 2024_11_11_201220) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aircraft", force: :cascade do |t|
    t.string "model", null: false
    t.boolean "wikipedia_info_collected", default: false
    t.string "wikipedia_title"
    t.string "featured_image"
    t.string "infobox_json"
    t.string "infobox_raw"
    t.string "description"
    t.string "snippet"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "wikipedia_page_id"
    t.index ["model"], name: "index_aircraft_on_model", unique: true
    t.index ["wikipedia_page_id"], name: "index_aircraft_on_wikipedia_page_id", unique: true
  end

  create_table "aircraft_images", force: :cascade do |t|
    t.string "url", null: false
    t.string "filename", null: false
    t.string "description"
    t.bigint "aircraft_id", null: false
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["aircraft_id", "url"], name: "index_aircraft_images_on_url_and_aircraft_id", unique: true
    t.index ["aircraft_id"], name: "index_aircraft_images_on_aircraft_id"
    t.index ["filename"], name: "index_aircraft_images_on_filename"
  end

  create_table "aircraft_manufacturers", force: :cascade do |t|
    t.bigint "aircraft_id", null: false
    t.bigint "manufacturer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id", "manufacturer_id"], name: "idx_on_aircraft_id_manufacturer_id_08ae9e99ec", unique: true
    t.index ["aircraft_id"], name: "index_aircraft_manufacturers_on_aircraft_id"
    t.index ["manufacturer_id"], name: "index_aircraft_manufacturers_on_manufacturer_id"
  end

  create_table "aircraft_types", force: :cascade do |t|
    t.bigint "aircraft_id", null: false
    t.bigint "type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_id", "type_id"], name: "index_aircraft_types_on_aircraft_id_and_type_id", unique: true
    t.index ["aircraft_id"], name: "index_aircraft_types_on_aircraft_id"
    t.index ["type_id"], name: "index_aircraft_types_on_type_id"
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "manufacturer", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manufacturer"], name: "index_manufacturers_on_manufacturer", unique: true
  end

  create_table "types", force: :cascade do |t|
    t.string "aircraft_type", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aircraft_type"], name: "index_types_on_aircraft_type", unique: true
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "group"
    t.text "description"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["group"], name: "index_user_groups_on_group", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "user_group_id"
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["email"], name: "index_email_on_users", unique: true
    t.index ["user_group_id"], name: "index_users_on_user_group_id"
    t.index ["username"], name: "index_username_on_users", unique: true
  end

  add_foreign_key "aircraft_images", "aircraft"
  add_foreign_key "aircraft_manufacturers", "aircraft"
  add_foreign_key "aircraft_manufacturers", "manufacturers"
  add_foreign_key "aircraft_types", "aircraft"
  add_foreign_key "aircraft_types", "types"
  add_foreign_key "users", "user_groups"
end
