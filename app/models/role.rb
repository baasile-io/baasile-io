class Role < ApplicationRecord
  USER_ROLES = %i(admin commercial developer accountant).freeze

  CONTROLLER_AUTHORIZATIONS = {
    services: {
      show: USER_ROLES.dup,
      users: USER_ROLES.dup,
      edit: [:admin],
      update: [:admin]
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
    permissions: {}
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
