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

ActiveRecord::Schema.define(version: 20170508183429) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "appconfigs", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "banking_details", force: :cascade do |t|
    t.string   "name"
    t.string   "iban"
    t.string   "bic"
    t.string   "account_owner"
    t.string   "bank_name"
    t.integer  "user_id"
    t.integer  "service_id"
    t.integer  "contract_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["contract_id"], name: "index_banking_details_on_contract_id", using: :btree
    t.index ["name", "service_id", "contract_id"], name: "index_on_name_service_contract", unique: true, using: :btree
    t.index ["service_id"], name: "index_banking_details_on_service_id", using: :btree
    t.index ["user_id"], name: "index_banking_details_on_user_id", using: :btree
  end

  create_table "bill_lines", force: :cascade do |t|
    t.integer  "bill_id"
    t.string   "title"
    t.decimal  "unit_cost",                default: "0.0"
    t.integer  "unit_num",                 default: 0
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "line_type",                default: 0
    t.decimal  "vat_rate",                 default: "0.0"
    t.decimal  "total_cost",               default: "0.0"
    t.decimal  "total_cost_including_vat", default: "0.0"
    t.index ["bill_id"], name: "index_bill_lines_on_bill_id", using: :btree
  end

  create_table "bills", force: :cascade do |t|
    t.integer  "contract_id"
    t.date     "bill_month"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.decimal  "total_cost",                 default: "0.0"
    t.decimal  "total_vat",                  default: "0.0"
    t.decimal  "total_cost_including_vat",   default: "0.0"
    t.date     "due_date"
    t.boolean  "paid",                       default: false
    t.decimal  "platform_contribution_rate", default: "0.0"
    t.index ["bill_month", "contract_id"], name: "index_bills_on_bill_month_and_contract_id", unique: true, using: :btree
    t.index ["contract_id", "bill_month"], name: "index_bills_on_contract_id_and_bill_month", unique: true, using: :btree
    t.index ["contract_id"], name: "index_bills_on_contract_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "commentable_type"
    t.integer  "commentable_id"
    t.integer  "user_id"
    t.text     "body"
    t.boolean  "deleted",          default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

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
    t.string   "name",                limit: 255
    t.string   "siret",               limit: 255
    t.string   "address_line1",       limit: 255
    t.string   "address_line2",       limit: 255
    t.string   "address_line3",       limit: 255
    t.string   "zip",                 limit: 255
    t.string   "city",                limit: 255
    t.string   "country",             limit: 255
    t.string   "phone",               limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "chamber_of_commerce", limit: 255
    t.index ["contactable_type", "contactable_id"], name: "index_contact_details_on_contactable_type_and_contactable_id", using: :btree
    t.index ["name", "contactable_type", "contactable_id"], name: "id_contdetails_name_type_and_id", using: :btree
  end

  create_table "contracts", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "client_id"
    t.integer  "company_id"
    t.integer  "startup_id"
    t.integer  "user_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.boolean  "is_active",                                   default: true
    t.integer  "status",                                      default: 1
    t.boolean  "production",                                  default: false
    t.integer  "proxy_id"
    t.string   "client_code"
    t.integer  "contract_duration"
    t.date     "expected_start_date"
    t.date     "expected_end_date"
    t.integer  "expected_contract_duration",                  default: 1
    t.boolean  "is_evergreen",                                default: false
    t.integer  "general_condition_id"
    t.integer  "general_condition_validated_client_user_id"
    t.datetime "general_condition_validated_client_datetime"
    t.integer  "expected_free_count"
    t.string   "startup_code"
    t.index ["client_id", "startup_id", "proxy_id"], name: "index_contracts_on_client_id_and_startup_id_and_proxy_id", unique: true, using: :btree
  end

  create_table "dictionaries", force: :cascade do |t|
    t.string   "localizable_type"
    t.integer  "localizable_id"
    t.string   "locale",           default: "fr"
    t.text     "title"
    t.text     "subtitle"
    t.text     "body"
    t.text     "footer"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["localizable_type", "localizable_id", "locale"], name: "index_on_localizable_and_locale", using: :btree
  end

  create_table "documentations", force: :cascade do |t|
    t.integer  "documentation_type", default: 1
    t.string   "ancestry"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "public",             default: false
  end

  create_table "error_measurements", force: :cascade do |t|
    t.string   "error_type"
    t.text     "request_detail"
    t.integer  "contract_id"
    t.integer  "route_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "error_code"
    t.integer  "response_http_status"
    t.index ["contract_id"], name: "index_error_measurements_on_contract_id", using: :btree
    t.index ["route_id"], name: "index_error_measurements_on_route_id", using: :btree
  end

  create_table "general_conditions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "gc_version"
    t.date     "effective_start_date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "identifiers", force: :cascade do |t|
    t.string   "client_id"
    t.string   "encrypted_secret"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "identifiable_type"
    t.integer  "identifiable_id"
    t.index ["identifiable_type", "identifiable_id", "client_id"], name: "identifiable_type_id_client_id", unique: true, using: :btree
    t.index ["identifiable_type", "identifiable_id"], name: "identifiable_type_id", using: :btree
  end

  create_table "measure_tokens", force: :cascade do |t|
    t.string   "value"
    t.string   "contract_status"
    t.integer  "contract_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["value", "contract_status", "contract_id"], name: "value_status_contract_index", unique: true, using: :btree
  end

  create_table "measurements", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "requests_count",   default: 0, null: false
    t.integer  "service_id"
    t.integer  "proxy_id"
    t.integer  "route_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "measure_token_id"
    t.integer  "contract_id"
    t.string   "contract_status"
    t.index ["proxy_id"], name: "index_measurements_on_proxy_id", using: :btree
    t.index ["route_id"], name: "index_measurements_on_route_id", using: :btree
    t.index ["service_id"], name: "index_measurements_on_service_id", using: :btree
  end

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree
  end

  create_table "price_parameters", force: :cascade do |t|
    t.integer  "price_parameters_type", default: 1
    t.string   "parameter"
    t.decimal  "cost",                  default: "0.0"
    t.integer  "free_count",            default: 0
    t.integer  "user_id"
    t.integer  "route_id"
    t.integer  "query_parameter_id"
    t.boolean  "activate",              default: true
    t.boolean  "attached",              default: false
    t.integer  "price_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "deny_after_free_count", default: true
    t.index ["price_id"], name: "index_price_parameters_on_price_id", using: :btree
  end

  create_table "prices", force: :cascade do |t|
    t.string   "name"
    t.decimal  "base_cost",             default: "0.0"
    t.decimal  "cost",                  default: "0.0"
    t.integer  "user_id"
    t.boolean  "activate",              default: true
    t.integer  "proxy_id"
    t.integer  "service_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "contract_id"
    t.integer  "pricing_duration_type", default: 0
    t.integer  "pricing_type",          default: 0
    t.integer  "free_count",            default: 0
    t.boolean  "deny_after_free_count", default: true
    t.decimal  "unit_cost",             default: "0.0"
    t.integer  "route_id"
    t.integer  "query_parameter_id"
    t.index ["contract_id"], name: "index_prices_on_contract_id", using: :btree
    t.index ["proxy_id"], name: "index_prices_on_proxy_id", using: :btree
    t.index ["query_parameter_id"], name: "index_prices_on_query_parameter_id", using: :btree
    t.index ["route_id"], name: "index_prices_on_route_id", using: :btree
    t.index ["service_id"], name: "index_prices_on_service_id", using: :btree
  end

  create_table "proxies", force: :cascade do |t|
    t.string   "name",                    limit: 255
    t.string   "alias",                   limit: 25
    t.string   "description"
    t.integer  "service_id"
    t.integer  "user_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "proxy_parameter_id"
    t.integer  "proxy_parameter_test_id"
    t.integer  "category_id"
    t.string   "subdomain"
    t.boolean  "public",                              default: false
    t.boolean  "is_active",                           default: true
    t.index ["service_id"], name: "index_proxies_on_service_id", using: :btree
    t.index ["user_id"], name: "index_proxies_on_user_id", using: :btree
  end

  create_table "proxy_parameters", force: :cascade do |t|
    t.integer  "protocol"
    t.string   "hostname"
    t.integer  "port"
    t.string   "authorization_url"
    t.integer  "authorization_mode", default: 0
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "realm"
    t.string   "grant_type"
    t.boolean  "follow_url",         default: false
    t.integer  "follow_redirection", default: 10
    t.string   "scope"
  end

  create_table "query_parameters", force: :cascade do |t|
    t.string   "name"
    t.integer  "mode"
    t.integer  "route_id"
    t.integer  "user_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "query_parameter_type", default: 1
    t.string   "description"
    t.string   "default_value"
    t.index ["name", "query_parameter_type", "route_id"], name: "name_query_parameter_type_route_index", unique: true, using: :btree
    t.index ["route_id"], name: "index_query_parameters_on_route_id", using: :btree
    t.index ["user_id"], name: "index_query_parameters_on_user_id", using: :btree
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.string   "value"
    t.integer  "service_id"
    t.datetime "expires_at"
    t.string   "scope"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id"], name: "index_refresh_tokens_on_service_id", using: :btree
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
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.text     "allowed_methods",         default: [],                 array: true
    t.integer  "protocol_test"
    t.string   "hostname_test"
    t.string   "port_test"
    t.string   "subdomain"
    t.boolean  "measure_token_activated", default: false
    t.index ["proxy_id"], name: "index_routes_on_proxy_id", using: :btree
    t.index ["user_id"], name: "index_routes_on_user_id", using: :btree
  end

  create_table "services", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "alias"
    t.string   "description"
    t.string   "website"
    t.string   "client_id"
    t.string   "client_secret"
    t.integer  "user_id"
    t.datetime "confirmed_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "subdomain"
    t.boolean  "public",                         default: false
    t.integer  "company_id"
    t.integer  "service_type",                   default: 1
    t.string   "ancestry"
    t.integer  "main_commercial_id"
    t.integer  "main_developer_id"
    t.integer  "main_accountant_id"
    t.text     "description_long"
    t.index ["ancestry"], name: "index_services_on_ancestry", using: :btree
    t.index ["main_accountant_id"], name: "index_services_on_main_accountant_id", using: :btree
    t.index ["main_commercial_id"], name: "index_services_on_main_commercial_id", using: :btree
    t.index ["main_developer_id"], name: "index_services_on_main_developer_id", using: :btree
    t.index ["name"], name: "index_services_on_name", unique: true, using: :btree
  end

  create_table "services_roles", id: false, force: :cascade do |t|
    t.integer "service_id"
    t.integer "role_id"
    t.index ["service_id", "role_id"], name: "index_services_roles_on_service_id_and_role_id", using: :btree
  end

  create_table "tickets", force: :cascade do |t|
    t.string   "subject"
    t.integer  "ticket_type"
    t.integer  "ticket_status"
    t.integer  "user_id"
    t.integer  "service_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["service_id"], name: "index_tickets_on_service_id", using: :btree
    t.index ["user_id"], name: "index_tickets_on_user_id", using: :btree
  end

  create_table "user_associations", force: :cascade do |t|
    t.string   "associable_type"
    t.integer  "associable_id"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["associable_type", "associable_id"], name: "index_user_associations_on_associable_type_and_associable_id", using: :btree
    t.index ["user_id", "associable_type", "associable_id"], name: "id_userassociations_user_associable", using: :btree
    t.index ["user_id"], name: "index_user_associations_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",   null: false
    t.string   "encrypted_password",                default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                   default: 0,    null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "gender"
    t.string   "phone"
    t.datetime "password_changed_at"
    t.string   "unique_session_id",      limit: 20
    t.datetime "last_activity_at"
    t.datetime "expired_at"
    t.boolean  "is_active",                         default: true
    t.string   "ancestry"
    t.string   "language",                          default: "en"
    t.index ["ancestry"], name: "index_users_on_ancestry", using: :btree
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

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "bill_lines", "bills"
  add_foreign_key "bills", "contracts"
end
