class Contract < ApplicationRecord

  CONTRACT_STATUSES = {
    deletion: {
      index: 0,
      can: {
        show: {
          client: ['admin']
        },
        validate: {
          client: ['admin']
        }
      },
      conditions: {
        validate: Proc.new {|c| true}
      },
      notifications: {},
      allowed_parameters: [],
      next: :creation,
      prev: nil
    },
    creation: {
      index: 1,
      can: {
        show: {
          client: ['commercial']
        },
        edit: {
          client: ['commercial']
        },
        update: {
          client: ['commercial']
        },
        validate: {
          client: ['commercial']
        },
        cancel: {
          client: ['commercial']
        },
        comments: {
          startup: ['commercial']
        }
      },
      conditions: {
        startup: Proc.new {|c| true}
      },
      notifications: {
        startup: ['admin', 'commercial']
      },
      allowed_parameters: [:code, :name, :contract_duration_type, :expected_start_date, :expected_end_date, :is_evergreen, :proxy_id, :client_id],
      next: :commercial_validation_sp,
      prev: nil
    },
    commercial_validation_sp: {
      index: 4,
      can: {
        show: {
          client: ['commercial'],
          startup: ['commercial']
        },
        edit: {
          client: ['commercial']
        },
        update: {
          client: ['commercial']
        },
        validate: {
          startup: ['commercial']
        },
        reject: {
          startup: ['commercial']
        },
        select_price: {
          startup: ['commercial']
        },
        prices: {
          startup: ['commercial']
        },
        comments: {
          client: ['commercial'],
          startup: ['commercial']
        }
      },
      conditions: {
        validate: Proc.new {|c| !c.price.nil? && c.price.persisted?}
      },
      notifications: {
        client: ['admin', 'commercial']
      },
      allowed_parameters: [:contract_duration_type, :expected_start_date, :expected_end_date, :is_evergreen, :proxy_id],
      next: :commercial_validation_client,
      prev: :creation
    },
    commercial_validation_client: {
      index: 7,
      can: {
        show: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        validate: {
          client: ['commercial']
        },
        reject: {
          client: ['commercial']
        },
        comments: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        }
      },
      conditions: {
        validate: Proc.new {|c| true}
      },
      notifications: {
        startup: ['admin', 'commercial']
      },
      allowed_parameters: [],
      next: :validation,
      prev: :commercial_validation_sp
    },
=begin
    price_validation_sp: {
      index: 10,
      scope: 'accounting',
      roles: ['admin', 'commercial'],
      can: {
        see: ['client', 'startup']
      },
      can_validate: 'startup',
      can_reject: 'startup',
      can_edit: 'startup',
      can_set_price: 'startup',
      allowed_parameters: [],
      next: :price_validation_client,
      next_condition: Proc.new {|c| !c.price.nil? && c.price.persisted?},
      prev: :commercial_validation_client
    },
    price_validation_client: {
      index: 13,
      scope: 'accounting',
      roles: ['admin', 'commercial'],
      can: {
        see: ['client', 'startup']
      },
      can_validate: 'client',
      can_reject: 'client',
      can_edit: 'client',
      can_set_price: nil,
      allowed_parameters: [],
      next: :validation,
      next_condition: Proc.new {|c| true},
      prev: :price_validation_sp
    },
=end
    validation: {
      index: 16,
      can: {
        show: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        validate: {
          startup: ['commercial']
        },
        comments: {
          client: ['commercial'],
          startup: ['commercial']
        },
        toggle_production: {
          startup: ['commercial']
        }
      },
      conditions: {
        toggle_production: Proc.new {|c| true},
        validate: Proc.new {|c| false}
      },
      notifications: {
        client: ['admin', 'commercial'],
        startup: ['admin', 'commercial']
      },
      allowed_parameters: [],
      next: nil,
      prev: :commercial_validation_client
    }
  }
  CONTRACT_STATUSES_ENUM = CONTRACT_STATUSES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum status: CONTRACT_STATUSES_ENUM

  CONTRACT_DURATION_TYPES = {
    custom:  { index: 0 },
    monthly: { index: 1 },
    yearly:  { index: 2 }
  }
  CONTRACT_DURATION_TYPES_ENUM = CONTRACT_DURATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum contract_duration_type: CONTRACT_DURATION_TYPES_ENUM

  # Versioning
  has_paper_trail

  belongs_to :proxy
  belongs_to :user
  belongs_to :company
  belongs_to :client, class_name: Service.name
  belongs_to :startup, class_name: Service.name

  has_one :price
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :price

  before_validation :set_expected_end_date_and_expected_contract_duration

  validates :name, presence: true
  validates :startup_id, presence:true
  validates :client_id, presence:true
  validates :proxy_id, presence:true, uniqueness: {scope: [:client_id, :startup_id]}
  validates :expected_contract_duration, presence: true, numericality: {greater_than: 0, less_than_or_equal: 12}
  validates :expected_start_date, presence: true, date: true
  validates :expected_end_date, presence: true, date: {after: Proc.new {|record| record.expected_start_date}}

  scope :associated_companies, ->(company) { where(company: company) }
  scope :associated_clients, ->(client) { where(client: client) }
  scope :associated_startups, ->(startup) { where(startup: startup) }
  scope :associated_service, ->(service) { where("(startup_id IN (:service_ids) AND status != #{CONTRACT_STATUSES[:deletion][:index]} AND status != #{CONTRACT_STATUSES[:creation][:index]}) OR client_id IN (:service_ids)", service_ids: service.subtree_ids) }
  scope :associated_user, ->(user) { where("(startup_id IN (:service_ids) AND status != #{CONTRACT_STATUSES[:deletion][:index]} AND status != #{CONTRACT_STATUSES[:creation][:index]}) OR client_id IN (:service_ids)", service_ids: user.services.map {|s| s.subtree_ids}.flatten.uniq) }

  scope :owned, ->(user) { where(user: user) }

  def set_dup_price(price_id)
    unless price_id.empty?
      price_temp = Price.find(price_id)
      price = price_temp.dup_attached(self.price)
      price_params = PriceParameter.where(price_id: price_id)
      dup_price_param(price_params, price)
      self.price = price
    end
  end

  def dup_price_param(price_params, price)
    price_params.each do |price_param|
      price_param.dup_attached(price)
    end
  end

  def status_config
    Contract::CONTRACT_STATUSES[self.status.to_sym]
  end

  def is_developer?(user, scope)
    return true if user.is_developer_of?(self.send(scope))
    return self.is_admin?(user, scope)
  end

  def is_accountant?(user, scope)
    return true if user.is_accountant_of?(self.send(scope))
    return self.is_admin?(user, scope)
  end

  def is_commercial?(user, scope)
    return true if user.is_commercial_of?(self.send(scope))
    return self.is_admin?(user, scope)
  end

  def is_admin?(user, scope)
    return true if user.has_role?(:superadmin)
    return true if user.is_admin_of?(self.send(scope))
    false
  end

  def can?(user, action)
    return false if status_config[:can].nil? || status_config[:can][action].nil?
    unless status_config[:conditions].nil? || status_config[:conditions][action].nil?
      return false unless status_config[:conditions][action].call(self)
    end
    status_config[:can][action].each_pair do |scope, roles|
      roles.each do |role|
        return true if self.send("is_#{role}?", user, scope)
      end
    end
    false
  end

  def to_s
    name
  end

  def set_expected_end_date_and_expected_contract_duration
    case self.contract_duration_type.to_sym
      when :monthly
        if self.expected_start_date
          self.expected_end_date = (self.expected_start_date + 1.month - 1.day)
          self.expected_contract_duration = (self.expected_end_date - self.expected_start_date).to_i + 1
        end
      when :yearly
        if self.expected_start_date
          self.expected_end_date = (self.expected_start_date + 1.year - 1.day)
          self.expected_contract_duration = (self.expected_end_date - self.expected_start_date).to_i + 1
        end
      else
        self.expected_contract_duration = (self.expected_end_date - self.expected_start_date).to_i + 1 if self.expected_start_date && self.expected_end_date
    end
  end
end
