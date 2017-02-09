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

ActiveRecord::Schema.define(version: 20170209144626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.integer  "parent_id"
    t.integer  "uuid"
    t.string   "name",             limit: 255
    t.integer  "administrator_id"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["name"], name: "index_companies_on_name", unique: true, using: :btree
  end

  create_table "contact_details", force: :cascade do |t|
    t.string   "contactable_type"
    t.integer  "contactable_id"
    t.string   "name",             limit: 255
    t.string   "siret",            limit: 255
    t.string   "address_line1",    limit: 255
    t.string   "address_line2",    limit: 255
    t.string   "address_line3",    limit: 255
    t.string   "zip",              limit: 255
    t.string   "city",             limit: 255
    t.string   "country",          limit: 255
    t.string   "phone",            limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["contactable_type", "contactable_id"], name: "index_contact_details_on_contactable_type_and_contactable_id", using: :btree
    t.index ["name", "contactable_type", "contactable_id"], name: "id_contdetails_name_type_and_id", using: :btree
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree
  end

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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "realm"
    t.string   "grant_type"
    t.boolean  "follow_url",          default: false
    t.integer  "follow_redirection",  default: 10
    t.string   "scope"
  end

  create_table "query_parameters", force: :cascade do |t|
    t.string   "name"
    t.integer  "mode"
    t.integer  "route_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "route_id"], name: "index_query_parameters_on_name_and_route_id", unique: true, using: :btree
    t.index ["route_id"], name: "index_query_parameters_on_route_id", using: :btree
    t.index ["user_id"], name: "index_query_parameters_on_user_id", using: :btree
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
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "subdomain"
    t.boolean  "public",                    default: false
    t.integer  "company_id"
    t.integer  "service_type",              default: 1
    t.index ["name"], name: "index_services_on_name", unique: true, using: :btree
  end

  create_table "services_roles", id: false, force: :cascade do |t|
    t.integer "service_id"
    t.integer "role_id"
    t.index ["service_id", "role_id"], name: "index_services_roles_on_service_id_and_role_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                   default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "current_subdomain"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender"
    t.string   "phone"
    t.datetime "password_changed_at"
    t.string   "unique_session_id",      limit: 20
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.boolean  "is_active",                         default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["expired_at"], name: "index_users_on_expired_at", using: :btree
    t.index ["last_activity_at"], name: "index_users_on_last_activity_at", using: :btree
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
