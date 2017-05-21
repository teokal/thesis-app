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

ActiveRecord::Schema.define(version: 20170522010111) do

  create_table "course_categories", force: true do |t|
    t.string   "name",                                 default: "",   null: false
    t.string   "idnumber",          limit: 100
    t.text     "description",       limit: 2147483647
    t.integer  "descriptionformat", limit: 1,          default: 0,    null: false
    t.integer  "parent",            limit: 8,          default: 0,    null: false
    t.integer  "sortorder",         limit: 8,          default: 0,    null: false
    t.integer  "coursecount",       limit: 8,          default: 0,    null: false
    t.boolean  "visible",                              default: true, null: false
    t.boolean  "visibleold",                           default: true, null: false
    t.integer  "timemodified",      limit: 8,          default: 0,    null: false
    t.integer  "depth",             limit: 8,          default: 0,    null: false
    t.string   "path",                                 default: "",   null: false
    t.string   "theme",             limit: 50
    t.integer  "moodle_id",         limit: 8,          default: 0,    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "courses", force: true do |t|
    t.integer  "coursecategory",    limit: 8,          default: 0,        null: false
    t.integer  "sortorder",         limit: 8,          default: 0,        null: false
    t.string   "fullname",          limit: 254,        default: "",       null: false
    t.string   "shortname",                            default: "",       null: false
    t.string   "idnumber",          limit: 100,        default: "",       null: false
    t.text     "summary",           limit: 2147483647
    t.integer  "summaryformat",     limit: 1,          default: 0,        null: false
    t.string   "format",            limit: 21,         default: "topics", null: false
    t.integer  "showgrades",        limit: 1,          default: 1,        null: false
    t.integer  "newsitems",         limit: 3,          default: 1,        null: false
    t.integer  "startdate",         limit: 8,          default: 0,        null: false
    t.integer  "marker",            limit: 8,          default: 0,        null: false
    t.integer  "maxbytes",          limit: 8,          default: 0,        null: false
    t.integer  "legacyfiles",       limit: 2,          default: 0,        null: false
    t.integer  "showreports",       limit: 2,          default: 0,        null: false
    t.boolean  "visible",                              default: true,     null: false
    t.boolean  "visibleold",                           default: true,     null: false
    t.integer  "groupmode",         limit: 2,          default: 0,        null: false
    t.integer  "groupmodeforce",    limit: 2,          default: 0,        null: false
    t.integer  "defaultgroupingid", limit: 8,          default: 0,        null: false
    t.string   "lang",              limit: 30,         default: "",       null: false
    t.string   "theme",             limit: 50,         default: "",       null: false
    t.integer  "timecreated",       limit: 8,          default: 0,        null: false
    t.integer  "timemodified",      limit: 8,          default: 0,        null: false
    t.boolean  "requested",                            default: false,    null: false
    t.boolean  "enablecompletion",                     default: false,    null: false
    t.boolean  "completionnotify",                     default: false,    null: false
    t.integer  "cacherev",          limit: 8,          default: 0,        null: false
    t.string   "calendartype",      limit: 30,         default: "",       null: false
    t.integer  "moodle_id",         limit: 8,          default: 0,        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
