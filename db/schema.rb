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

ActiveRecord::Schema.define(version: 20150130102000) do

  create_table "chat_messages", force: true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chat_id"
    t.string   "type",       default: ""
  end

  create_table "chats", force: true do |t|
    t.integer  "host_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flowers_chat", default: false
  end

  create_table "chats_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "chat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "chats_users", ["user_id", "chat_id"], name: "index_chats_users_on_user_id_and_chat_id"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "dice_games", force: true do |t|
    t.string   "type"
    t.integer  "capacity"
    t.integer  "bet"
    t.string   "state"
    t.integer  "chat_id"
    t.integer  "winner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stage",               default: 1
    t.boolean  "websockets_informed", default: false
    t.integer  "pot"
  end

  create_table "dice_games_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "dice_game_id"
    t.boolean  "winner",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dice_games_users", ["user_id", "dice_game_id"], name: "index_dice_games_users_on_user_id_and_dice_game_id"

  create_table "dice_rolls", force: true do |t|
    t.integer  "dice_game_id"
    t.integer  "user_id"
    t.integer  "roll"
    t.boolean  "winning_roll",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stage"
    t.boolean  "websockets_informed", default: false
  end

  add_index "dice_rolls", ["dice_game_id"], name: "index_dice_rolls_on_dice_game_id"

  create_table "flower_game_hosts", force: true do |t|
    t.integer  "host_id"
    t.integer  "min_bet",     limit: 5
    t.integer  "max_bet",     limit: 5
    t.boolean  "online",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stream_link"
  end

  add_index "flower_game_hosts", ["host_id"], name: "index_flower_game_hosts_on_host_id"

  create_table "flower_games", force: true do |t|
    t.string   "color"
    t.integer  "host_id"
    t.integer  "bettor_id"
    t.boolean  "user_won",                 default: false
    t.string   "state"
    t.integer  "bet",            limit: 5
    t.integer  "pot",            limit: 5
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "user_confirmed",           default: false
    t.integer  "creator_id"
  end

  create_table "tickets", force: true do |t|
    t.text     "message"
    t.integer  "amount"
    t.string   "type"
    t.string   "state"
    t.integer  "user_id"
    t.string   "currency"
    t.integer  "recipient_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chat_id"
    t.boolean  "reported",          default: false
  end

  add_index "tickets", ["recipient_user_id"], name: "index_tickets_on_recipient_user_id"
  add_index "tickets", ["user_id"], name: "index_tickets_on_user_id"

  create_table "user_roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["name"], name: "index_user_roles_on_name", unique: true

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "username"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "muted",                  default: false
    t.datetime "muted_until"
    t.boolean  "banned",                 default: false
    t.boolean  "chatbox_banned",         default: false
    t.string   "ip"
    t.boolean  "ip_banned",              default: false
    t.datetime "last_online_at"
    t.integer  "bet_rank",               default: 0
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

  create_table "wallets", force: true do |t|
    t.integer  "user_id"
    t.integer  "value",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallets", ["user_id"], name: "index_wallets_on_user_id", unique: true

end
