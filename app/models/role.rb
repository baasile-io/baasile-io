class Role < ApplicationRecord
  USER_ROLES = %i(admin developer commercial accountant).freeze

  CONTROLLER_AUTHORIZATIONS = {
    bank_details: {
      index: [:accountant],
      show: [:accountant],
      edit: [:accountant],
      new: [:accountant],
      update: [:accountant],
      create: [:accountant],
    },
    services: {
      show: USER_ROLES.dup,
      edit: [:admin],
      update: [:admin],
      logo: [:admin],
      audit: [:admin],
      activation_request: [:admin],
      error_measurements: [:admin, :developer]
    },
    users: {
      index: USER_ROLES.dup,
      new: [:admin],
      create: [:admin],
      edit: [:admin],
      update: [:admin],
      destroy: [:admin],
      disassociate: [:admin],
      toggle_role: [:admin],
      invite_by_id: [:admin],
      invite_by_email: [:admin]
    },
    proxies: {
      index: USER_ROLES.dup,
      show: USER_ROLES.dup,
      new: [:admin, :developer],
      create: [:admin, :developer],
      edit: [:admin, :developer],
      update: [:admin, :developer],
      error_measurements: [:admin, :developer],
      destroy: [:admin],
      confirm_destroy: [:admin],
      audit: [:admin, :developer]
    },
    identifiers: {
      index: [:admin, :developer]
    },
    routes: {
      audit: [:admin, :developer],
      index: [:admin, :developer],
      new: [:admin, :developer],
      create: [:admin, :developer],
      show: [:admin, :developer],
      edit: [:admin, :developer],
      update: [:admin, :developer],
      destroy: [:admin, :developer]
    },
    query_parameters: {
      index: [:admin, :developer],
      create: [:admin, :developer],
      edit: [:admin, :developer],
      update: [:admin, :developer],
      destroy: [:admin, :developer]
    },
    permissions: {},
    contracts: {
      index: [:admin, :commercial, :accountant],
      prices: [:admin, :commercial, :accountant],
      select_price: [:admin, :commercial],
      select_client: [:admin, :commercial],
      catalog: [:admin, :commercial],
      new: [:admin, :commercial],
      create: [:admin, :commercial],
      show: [:admin, :commercial, :accountant],
      audit: [:admin],
      edit: [:admin, :commercial, :accountant],
      update: [:admin, :commercial, :accountant],
      comments: [:admin, :commercial, :accountant],
      reject: [:admin, :commercial, :accountant],
      validate: [:admin, :commercial, :accountant],
      general_condition: [:admin, :commercial, :accountant],
      validate_general_condition: [:admin, :commercial],
      destroy: [:admin, :commercial],
      error_measurements: [:admin, :developer],
      error_measurement: [:admin, :developer],
      print_current_month_consumption: [:admin, :accountant],
      client_bank_details: [:admin, :accountant],
      client_select_bank_detail: [:admin, :accountant],
      client_bank_details_selection: [:admin, :accountant],
      startup_bank_details: [:admin, :accountant],
      startup_bank_details_selection: [:admin, :accountant],
      startup_select_bank_detail: [:admin, :accountant],
      delete_client_bank_detail: [:admin, :accountant],
      delete_startup_bank_detail: [:admin, :accountant],
      reset_free_count_limit: [:admin, :developer]
    },
    bills: {
      index: [:admin, :accountant],
      show: [:admin, :accountant],
      print: [:admin, :accountant],
      mark_as_paid: [:admin, :accountant],
      mark_platform_contribution_as_paid: []
    },
    prices: {
      index: [:admin, :commercial],
      show: [:admin, :commercial],
      new: [:admin, :commercial],
      create: [:admin, :commercial],
      edit: [:admin, :commercial],
      update: [:admin, :commercial],
      destroy: [:admin, :commercial]
    },
    price_parameters: {
      index: [:admin, :commercial],
      show: [:admin, :commercial],
      new: [:admin, :commercial],
      create: [:admin, :commercial],
      edit: [:admin, :commercial],
      update: [:admin, :commercial],
      destroy: [:admin, :commercial]
    },
    error_measurements: {
      index: [:admin, :developer],
      show: [:admin, :developer]
    }
  }.freeze

  has_and_belongs_to_many :users, :join_table => :users_roles
  has_and_belongs_to_many :services, :join_table => :services_roles

  belongs_to :resource,
             :polymorphic => true,
             :optional => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
end
