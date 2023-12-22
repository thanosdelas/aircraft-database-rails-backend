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

ActiveRecord::Schema[7.1].define(version: 2023_12_09_193417) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "user_groups", force: :cascade do |t|
    t.string "group"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group"], name: "index_user_groups_on_group", unique: true
  end

  #
  # Default Hardcoded User Groups
  #
  [
    {
      id: 100,
      group: 'admin'
    },
    {
      id: 200,
      group: 'user'
    },
    {
      id: 300,
      group: 'guest'
    }
  ].each do |group|
    UserGroup.find_or_create_by!(id: group[:id], group: group[:group])
  end

  create_table "users", force: :cascade do |t|
    t.references :user_group, foreign_key: true
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_email_on_users", unique: true
    t.index ["username"], name: "index_username_on_users", unique: true
  end

  create_table "opensky_network_raw", force: :cascade do |t|
    t.string "icao24"
    t.string "registration"
    t.string "manufacturericao"
    t.string "manufacturername"
    t.string "model"
    t.string "typecode"
    t.string "serialnumber"
    t.string "linenumber"
    t.string "icaoaircrafttype"
    t.string "operator"
    t.string "operatorcallsign"
    t.string "operatoricao"
    t.string "operatoriata"
    t.string "owner"
    t.string "testreg"
    t.string "registered"
    t.string "reguntil"
    t.string "status"
    t.string "built"
    t.string "firstflightdate"
    t.string "seatconfiguration"
    t.string "engines"
    t.string "modes"
    t.string "adsb"
    t.string "acars"
    t.string "notes"
    t.string "categoryDescription"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "aircraft", force: :cascade do |t|
    t.string "model"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
