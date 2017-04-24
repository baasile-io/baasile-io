class Role < ApplicationRecord
  USER_ROLES = %i(admin commercial developer accountant).freeze

  CONTROLLER_AUTHORIZATIONS = {
    services: {
      show: USER_ROLES.dup,
      edit: [:admin],
      update: [:admin],
      logo: [:admin]
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
      update: [:admin, :developer]
    },
    identifiers: {
      index: [:admin, :developer]
    },
    routes: {
      index: [:admin, :developer],
      new: [:admin, :developer],
      create: [:admin, :developer],
      show: [:admin, :developer],
      edit: [:admin, :developer],
      update: [:admin, :developer]
    },
    query_parameters: {
      index: [:admin, :developer],
      create: [:admin, :developer],
      edit: [:admin, :developer],
      update: [:admin, :developer]
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
      edit: [:admin, :commercial, :accountant],
      update: [:admin, :commercial, :accountant],
      comments: [:admin, :commercial, :accountant],
      reject: [:admin, :commercial, :accountant],
      validate: [:admin, :commercial, :accountant],
      general_condition: [:admin, :commercial, :accountant],
      validate_general_condition: [:admin, :commercial],
      cancel: [:admin]
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
