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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130205164436) do

  create_table "announcements", :force => true do |t|
    t.string   "subject"
    t.text     "contents"
    t.boolean  "published",    :default => false
    t.datetime "published_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "festival_locations", :force => true do |t|
    t.integer  "festival_id", :null => false
    t.integer  "location_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "festivals", :force => true do |t|
    t.string   "slug",                           :null => false
    t.string   "slug_group",                     :null => false
    t.string   "name",                           :null => false
    t.string   "location",                       :null => false
    t.string   "main_url"
    t.string   "updates_url"
    t.date     "starts_on"
    t.date     "ends_on"
    t.boolean  "published",   :default => false
    t.boolean  "scheduled",   :default => false
    t.datetime "revised_at"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "festivals", ["ends_on", "published"], :name => "index_festivals_on_ends_on_and_published"
  add_index "festivals", ["slug", "published"], :name => "index_festivals_on_slug_and_published"
  add_index "festivals", ["slug"], :name => "index_festivals_on_slug", :unique => true
  add_index "festivals", ["slug_group", "published"], :name => "index_festivals_on_slug_group_and_published"

  create_table "films", :force => true do |t|
    t.integer  "festival_id",  :null => false
    t.string   "name"
    t.string   "sort_name"
    t.text     "description"
    t.string   "url_fragment"
    t.integer  "duration"
    t.string   "countries"
    t.float    "page"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "films", ["festival_id", "name"], :name => "index_films_on_festival_id_and_name", :unique => true
  add_index "films", ["festival_id", "page", "name"], :name => "index_films_on_festival_id_and_page_and_name"

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "picks", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "festival_id",  :null => false
    t.integer  "film_id",      :null => false
    t.integer  "screening_id"
    t.integer  "priority"
    t.integer  "rating"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "picks", ["user_id", "festival_id", "film_id"], :name => "index_picks_on_user_id_and_festival_id_and_film_id", :unique => true

  create_table "questions", :force => true do |t|
    t.string   "email"
    t.text     "question"
    t.boolean  "acknowledged", :default => false
    t.boolean  "done",         :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "screenings", :force => true do |t|
    t.integer  "festival_id",                    :null => false
    t.integer  "film_id",                        :null => false
    t.integer  "venue_id",                       :null => false
    t.integer  "location_id",                    :null => false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "press",       :default => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "screenings", ["festival_id", "starts_at", "press"], :name => "index_screenings_on_festival_id_and_starts_at_and_press"
  add_index "screenings", ["film_id", "starts_at", "press"], :name => "index_screenings_on_film_id_and_starts_at_and_press"

  create_table "subscriptions", :force => true do |t|
    t.integer  "festival_id",                                            :null => false
    t.integer  "user_id",                                                :null => false
    t.boolean  "show_press",                          :default => false
    t.text     "restriction_text"
    t.string   "excluded_location_ids"
    t.string   "key",                   :limit => 10
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "subscriptions", ["festival_id", "user_id"], :name => "index_subscriptions_on_festival_id_and_user_id", :unique => true

  create_table "travel_intervals", :force => true do |t|
    t.integer  "from_location_id", :null => false
    t.integer  "to_location_id",   :null => false
    t.integer  "user_id"
    t.integer  "seconds_from"
    t.integer  "seconds_to"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "name",                   :default => "",    :null => false
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "admin",                  :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.string   "abbreviation"
    t.integer  "location_id",  :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "venues", ["location_id"], :name => "index_venues_on_location_id"

end
