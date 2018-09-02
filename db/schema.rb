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

ActiveRecord::Schema.define(version: 20180613010805) do

  create_table "course_categories", force: :cascade do |t|
    t.integer  "course_id",  limit: 4
    t.string   "name",       limit: 255
    t.integer  "user_id",    limit: 4
    t.boolean  "final",                  default: false
    t.boolean  "deleted",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "course_categories", ["user_id"], name: "index_course_categories_on_user_id", using: :btree

  create_table "course_category_parameters", force: :cascade do |t|
    t.float   "value",              limit: 24,                 null: false
    t.integer "series",             limit: 4,                  null: false
    t.integer "course_category_id", limit: 4
    t.boolean "constant",                      default: false, null: false
    t.integer "course_id",          limit: 4,                  null: false
    t.integer "user_id",            limit: 4
  end

  add_index "course_category_parameters", ["course_category_id"], name: "index_course_category_parameters_on_course_category_id", using: :btree
  add_index "course_category_parameters", ["user_id"], name: "index_course_category_parameters_on_user_id", using: :btree

  create_table "custom_activities", force: :cascade do |t|
    t.integer "activity_id",        limit: 4
    t.integer "user_id",            limit: 4
    t.integer "course_category_id", limit: 4
  end

  add_index "custom_activities", ["course_category_id"], name: "index_custom_activities_on_course_category_id", using: :btree
  add_index "custom_activities", ["user_id"], name: "index_custom_activities_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255
    t.string   "access_token",           limit: 255
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "username",               limit: 255
    t.string   "moodle_token",           limit: 255
    t.integer  "moodle_user_id",         limit: 4
    t.datetime "expires_at"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "full_name",              limit: 255
    t.string   "picture_url",            limit: 255
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
