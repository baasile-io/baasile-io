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

ActiveRecord::Schema.define(version: 20170104120710) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "proxies", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "alias",              limit: 25
    t.string   "description"
    t.integer  "service_id"
    t.integer  "user_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "proxy_parameter_id"
    t.index ["service_id"], name: "index_proxies_on_service_id", using: :btree
    t.index ["user_id"], name: "index_proxies_on_user_id", using: :btree
  end

  create_table "proxy_parameters", force: :cascade do |t|
    t.integer  "protocol"
    t.string   "hostname"
    t.integer  "port"
    t.string   "authentication_url"
    t.integer  "authentication_mode"
    t.string   "client_id"
    t.string   "client_secret"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "query_parameters", force: :cascade do |t|
    t.string   "name"
    t.integer  "mode"
    t.integer  "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_query_parameters_on_name", unique: true, using: :btree
    t.index ["route_id"], name: "index_query_parameters_on_route_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "routes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "protocol"
    t.string   "hostname"
    t.string   "port"
    t.string   "url"
    t.integer  "proxy_id"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "allowed_methods", default: [],              array: true
    t.index ["proxy_id"], name: "index_routes_on_proxy_id", using: :btree
    t.index ["user_id"], name: "index_routes_on_user_id", using: :btree
  end

  create_table "services", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "alias"
    t.string   "description"
    t.string   "website"
    t.string   "client_id"
    t.string   "client_secret"
    t.integer  "user_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "subdomain"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
