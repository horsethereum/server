# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170916211431) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bets", force: :cascade do |t|
    t.integer "bettor_id", null: false
    t.integer "race_id", null: false
    t.integer "horse_id", null: false
    t.decimal "amount", null: false
    t.index ["bettor_id", "race_id", "horse_id"], name: "index_bets_on_bettor_id_and_race_id_and_horse_id"
    t.index ["bettor_id"], name: "index_bets_on_bettor_id"
    t.index ["horse_id"], name: "index_bets_on_horse_id"
    t.index ["race_id"], name: "index_bets_on_race_id"
  end

  create_table "bettors", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.index ["email"], name: "index_bettors_on_email", unique: true
  end

  create_table "horses", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_horses_on_name", unique: true
  end

  create_table "races", force: :cascade do |t|
    t.date "date", null: false
    t.integer "race_number", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.index ["date", "race_number"], name: "index_races_on_date_and_race_number", unique: true
  end

  create_table "races_horses", force: :cascade do |t|
    t.integer "race_id", null: false
    t.integer "horse_id", null: false
    t.decimal "odds", null: false
    t.integer "finish"
    t.index ["horse_id"], name: "index_races_horses_on_horse_id"
    t.index ["race_id", "horse_id"], name: "index_races_horses_on_race_id_and_horse_id", unique: true
    t.index ["race_id"], name: "index_races_horses_on_race_id"
  end

  add_foreign_key "bets", "bettors"
  add_foreign_key "bets", "horses"
  add_foreign_key "bets", "races"
  add_foreign_key "races_horses", "horses"
  add_foreign_key "races_horses", "races"
end
