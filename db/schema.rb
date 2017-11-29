# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170127023659) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activity", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "user_id",                  null: false
    t.integer  "festival_id"
    t.integer  "subject_id"
    t.string   "subject_type", limit: 255
    t.integer  "target_id"
    t.string   "target_type",  limit: 255
    t.text     "details"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "announcements", force: :cascade do |t|
    t.string   "subject",      limit: 255
    t.text     "contents"
    t.boolean  "published",                default: false
    t.datetime "published_at"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "festival_locations", force: :cascade do |t|
    t.integer  "festival_id", null: false
    t.integer  "location_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "festivals", force: :cascade do |t|
    t.string   "slug",        limit: 255,                 null: false
    t.string   "slug_group",  limit: 255,                 null: false
    t.string   "name",        limit: 255,                 null: false
    t.string   "place",       limit: 255,                 null: false
    t.string   "main_url",    limit: 255
    t.string   "updates_url", limit: 255
    t.date     "starts_on"
    t.date     "ends_on"
    t.boolean  "published",               default: false
    t.boolean  "scheduled",               default: false
    t.datetime "revised_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "has_press",               default: false
    t.string   "banner_name", limit: 255, default: "",    null: false
  end

  add_index "festivals", ["ends_on", "published"], name: "index_festivals_on_ends_on_and_published", using: :btree
  add_index "festivals", ["slug", "published"], name: "index_festivals_on_slug_and_published", using: :btree
  add_index "festivals", ["slug"], name: "index_festivals_on_slug", unique: true, using: :btree
  add_index "festivals", ["slug_group", "published"], name: "index_festivals_on_slug_group_and_published", using: :btree

  create_table "films", force: :cascade do |t|
    t.integer  "festival_id",              null: false
    t.string   "name",         limit: 255
    t.string   "sort_name",    limit: 255
    t.string   "short_name",   limit: 255
    t.text     "description"
    t.string   "url_fragment", limit: 255
    t.integer  "duration"
    t.string   "countries",    limit: 255
    t.float    "page"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "films", ["festival_id", "name"], name: "index_films_on_festival_id_and_name", unique: true, using: :btree
  add_index "films", ["festival_id", "page", "name"], name: "index_films_on_festival_id_and_page_and_name", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "place",           limit: 255
    t.string   "address",         limit: 255
    t.integer  "parking_minutes",             default: 10, null: false
  end

  create_table "picks", force: :cascade do |t|
    t.integer  "user_id",                      null: false
    t.integer  "festival_id",                  null: false
    t.integer  "film_id",                      null: false
    t.integer  "screening_id"
    t.integer  "priority"
    t.integer  "rating"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "auto",         default: false
  end

  add_index "picks", ["user_id", "festival_id", "film_id"], name: "index_picks_on_user_id_and_festival_id_and_film_id", unique: true, using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.text     "question"
    t.boolean  "acknowledged",             default: false
    t.boolean  "done",                     default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "name",         limit: 255
    t.integer  "user_id"
  end

  create_table "screenings", force: :cascade do |t|
    t.integer  "festival_id",                 null: false
    t.integer  "film_id",                     null: false
    t.integer  "venue_id",                    null: false
    t.integer  "location_id",                 null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "press",       default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "screenings", ["festival_id", "starts_at", "press"], name: "index_screenings_on_festival_id_and_starts_at_and_press", using: :btree
  add_index "screenings", ["film_id", "starts_at", "press"], name: "index_screenings_on_film_id_and_starts_at_and_press", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "festival_id",                                       null: false
    t.integer  "user_id",                                           null: false
    t.boolean  "show_press",                        default: false
    t.text     "restriction_text"
    t.string   "excluded_location_ids", limit: 255
    t.string   "key",                   limit: 10
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "ratings_token",         limit: 255
  end

  add_index "subscriptions", ["festival_id", "user_id"], name: "index_subscriptions_on_festival_id_and_user_id", unique: true, using: :btree

  create_table "travel_intervals", force: :cascade do |t|
    t.integer  "from_location_id", null: false
    t.integer  "to_location_id",   null: false
    t.integer  "user_id"
    t.integer  "seconds_from"
    t.integer  "seconds_to"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                   limit: 255,                 null: false
    t.string   "email",                  limit: 255,                 null: false
    t.string   "encrypted_password",     limit: 255,                 null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",                    default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.boolean  "admin",                              default: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "ffff",                               default: false
    t.hstore   "preferences"
    t.string   "calendar_token",         limit: 255
    t.datetime "welcomed_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["preferences"], name: "index_users_on_preferences", using: :gist
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "venues", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "abbreviation", limit: 255
    t.integer  "location_id",              null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "venues", ["location_id"], name: "index_venues_on_location_id", using: :btree

end
