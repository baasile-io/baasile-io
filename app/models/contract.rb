class Contract < ApplicationRecord

  CONTRACT_STATUSES = {
    deletion: {
      index: 0,
      can: {
        show: {
          client: ['admin']
        },
        audit: {
          client: ['admin']
        },
        validate: {
          client: ['admin']
        },
        general_condition:{
          client: ['admin']
        }
      },
      conditions: {
        validate: Proc.new {|c| true}
      },
      notifications: {},
      allowed_parameters: {},
      next: :creation,
      prev: nil
    },
    creation: {
      index: 1,
      can: {
        show: {
          client: ['commercial']
        },
        audit: {
          client: ['admin'],
          startup: ['admin']
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
        validate_general_condition: {
          client: ['commercial']
        },
        destroy: {
          client: ['commercial']
        },
        comments: {
          client: ['commercial']
        },
        general_condition: {
          client: ['commercial']
        }
      },
      conditions: {
        validate_general_condition: Proc.new {|c| ( c.general_condition_validated_client_user_id.nil? ) ? true : false},
        validate: [
            Proc.new {|c| ( !c.general_condition_validated_client_user_id.nil? ) ? true : [false, I18n.t('errors.messages.general_condition_not_validated')]}
        ]
      },
      notifications: {
        startup: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code, :expected_free_count, :expected_start_date, :expected_end_date, :is_evergreen, :proxy_id, :client_id]
      },
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
        audit: {
          client: ['admin'],
          startup: ['admin']
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
        },
        general_condition: {
          client: ['commercial'],
          startup: ['commercial']
        }
      },
      show_error: {
        validate: Proc.new {I18n.t('types.contract_statuses.commercial_validation_sp.error')}
      },
      conditions: {
        validate: Proc.new {|c| (!c.price.nil? && c.price.persisted?) ? true : [false, I18n.t('errors.messages.missing_contract_prices')]}
      },
      notifications: {
        client: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code],
        startup: [:startup_code, :expected_free_count, :expected_start_date, :expected_end_date, :is_evergreen]
      },
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
        audit: {
          client: ['admin'],
          startup: ['admin']
        },
        validate: {
          client: ['commercial']
        },
        reject_general_condition: {
          client: ['commercial']
        },
        validate_general_condition: {
          client: ['commercial']
        },
        reject: {
          client: ['commercial']
        },
        comments: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        general_condition: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        }
      },
      show_error: {
        validate: Proc.new {I18n.t('types.contract_statuses.commercial_validation_client.error')}
      },
      conditions: {
        validate_general_condition: Proc.new {|c| ( c.general_condition_validated_client_user_id.nil? ) ? true : false},
        validate: Proc.new {|c| ( !c.general_condition_validated_client_user_id.nil? ) ? true : [false, I18n.t('errors.messages.general_condition_not_validated')]}
      },
      notifications: {
        startup: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code],
        startup: [:startup_code]
      },
      next: :validation,
      prev: :commercial_validation_sp
    },
    validation: {
      index: 16,
      can: {
        show: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        audit: {
          client: ['admin'],
          startup: ['admin']
        },
        validate: {
          startup: ['commercial']
        },
        comments: {
          client: ['commercial'],
          startup: ['commercial']
        },
        reject: {
          startup: ['commercial']
        },
        general_condition: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        error_measurements: {
            client: ['admin', 'developer'],
            startup: ['admin', 'developer']
        },
        error_measurement: {
          client: ['admin', 'developer'],
          startup: ['admin', 'developer']
        },
        reset_free_count_limit: {
          client: ['admin', 'developer'],
          startup: ['admin', 'developer']
        }
      },
      show_error: {
        validate: Proc.new {I18n.t('types.contract_statuses.validation.error')}
      },
      conditions: {
        validate: Proc.new {|c| true}
      },
      notifications: {
        client: ['admin', 'commercial'],
        startup: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code],
        startup: [:startup_code]
      },
      next: :waiting_for_production,
      prev: :commercial_validation_client
    },
    waiting_for_production: {
      index: 18,
      can: {
        client_bank_details: {
          client: ['accountant']
        },
        client_bank_details_selection: {
          client: ['accountant']
        },
        select_client_bank_detail: {
          client: ['accountant']
        },
        startup_bank_details: {
          startup: ['accountant']
        },
        startup_bank_details_selection: {
          startup: ['accountant']
        },
        select_startup_bank_detail: {
          startup: ['accountant']
        },
        show: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        audit: {
          client: ['admin'],
          startup: ['admin']
        },
        validate: {
          startup: ['commercial']
        },
        comments: {
          client: ['commercial'],
          startup: ['commercial']
        },
        reject: {
          startup: ['commercial']
        },
        general_condition: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        }
      },
      show_error: {
        validate: Proc.new {I18n.t('types.contract_statuses.waiting_for_production.error')},
        startup_bank_details: Proc.new {I18n.t('errors.bank_details.need_accountant_role')},
        client_bank_details: Proc.new {I18n.t('errors.bank_details.need_accountant_role')}
      },
      conditions: {
        validate: [
          Proc.new {|c|
            (!c.client_bank_detail.nil?) ? true : [false, I18n.t('errors.messages.missing_contract_client_bank_detail')]
          },
          Proc.new {|c|
            (!c.startup_bank_detail.nil?) ? true : [false, I18n.t('errors.messages.missing_contract_startup_bank_detail')]
          }
        ]
      },
      notifications: {
        client: ['admin', 'commercial'],
        startup: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code],
        startup: [:startup_code]
      },
      next: :validation_production,
      prev: :validation
    },
    validation_production: {
      index: 20,
      can: {
        show: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        audit: {
          client: ['admin'],
          startup: ['admin']
        },
        comments: {
          client: ['commercial'],
          startup: ['commercial']
        },
        general_condition: {
          client: ['commercial', 'accountant'],
          startup: ['commercial', 'accountant']
        },
        error_measurements: {
          client: ['admin', 'developer'],
          startup: ['admin', 'developer']
        },
        error_measurement: {
          client: ['admin', 'developer'],
          startup: ['admin', 'developer']
        },
        print_current_month_consumption: {
          client: ['accountant'],
          startup: ['accountant'],
        }
      },
      show_error: {},
      conditions: {
        validate: Proc.new {|c| false}
      },
      notifications: {
        client: ['admin', 'commercial'],
        startup: ['admin', 'commercial']
      },
      allowed_parameters: {
        client: [:client_code],
        startup: [:startup_code]
      },
      next: nil,
      prev: :waiting_for_production
    }
  }
  CONTRACT_STATUSES_ENUM = CONTRACT_STATUSES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum status: CONTRACT_STATUSES_ENUM

  # Versioning
  has_paper_trail

  belongs_to :proxy
  belongs_to :user
  belongs_to :company
  belongs_to :client, class_name: Service.name
  belongs_to :startup, class_name: Service.name
  belongs_to :general_condition_validated_client_user, class_name: User.name
  belongs_to :general_condition, class_name: GeneralCondition.name
  belongs_to :client_bank_detail, class_name: BankDetail.name, foreign_key: 'client_bank_detail_id'
  belongs_to :startup_bank_detail, class_name: BankDetail.name, foreign_key: 'startup_bank_detail_id'

  has_one :price, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :measurements, dependent: :nullify
  has_many :measure_tokens, dependent: :nullify
  has_many :error_measurements, dependent: :nullify
  has_many :bills, dependent: :restrict_with_error

  #has_one :startup, through: :proxy, source: :service

  accepts_nested_attributes_for :price

  # TODO remove association, and make it via ":through"
  before_validation :set_startup_id

  before_validation :set_expected_contract_duration
  before_validation :set_contract_dates
  before_validation :set_contract_duration

  validates :startup_id, presence:true
  validates :client_id, presence:true
  validates :proxy_id, presence:true, uniqueness: {scope: [:client_id, :startup_id]}
  validates :expected_contract_duration, presence: true, numericality: {greater_than: 0, less_than_or_equal: 12}
  validates :expected_start_date, presence: true, date: true
  validates :expected_end_date, presence: true, date: {on_or_after: :expected_start_date}
  validates :expected_free_count, numericality: {greater_than: 0}, if: Proc.new {self.expected_free_count.present?}

  validate :validate_client_bank_detail
  validate :validate_startup_bank_detail

  scope :associated_companies, ->(company) { where(company: company) }
  scope :associated_clients, ->(client) { where(client: client) }
  scope :associated_startups, ->(startup) { where(startup: startup) }
  scope :associated_services, ->(service) { where("(contracts.startup_id IN (:service_ids) AND contracts.status != #{CONTRACT_STATUSES[:deletion][:index]} AND contracts.status != #{CONTRACT_STATUSES[:creation][:index]}) OR contracts.client_id IN (:service_ids)", service_ids: service.subtree_ids) }
  scope :associated_users, ->(user) { where("(contracts.startup_id IN (:service_ids) AND contracts.status != #{CONTRACT_STATUSES[:deletion][:index]} AND contracts.status != #{CONTRACT_STATUSES[:creation][:index]}) OR contracts.client_id IN (:service_ids)", service_ids: user.services.map {|s| s.subtree_ids}.flatten.uniq) }
  scope :active_between, ->(start_date, end_date) { where('(contracts.start_date BETWEEN :start_date AND :end_date) OR (contracts.end_date BETWEEN :start_date AND :end_date) OR (contracts.start_date < :start_date AND contracts.end_date > :end_date)', start_date: start_date, end_date: end_date) }
  scope :active_around, ->(date) { where(':date BETWEEN contracts.start_date AND contracts.end_date', date: date) }

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

  def exec_condition(action_condition)
    unless action_condition.kind_of?(Array)
      status, error = action_condition.call(self)
      return [false, [error]] unless status
    else
      g_status = true
      errors = []
      action_condition.each do |cond|
        status, error = cond.call(self)
        errors << error unless status
        g_status = false unless status
      end
      return [false, errors] unless g_status
    end
    return true
  end

  def can?(user, action)
    return false if status_config[:can].nil? || status_config[:can][action].nil?
    unless status_config[:conditions].nil? || status_config[:conditions][action].nil?
      status, errors = exec_condition(status_config[:conditions][action])
      return [false, errors] unless status
    end
    status_config[:can][action].each_pair do |scope, roles|
      roles.each do |role|
        return true if self.send("is_#{role}?", user, scope)
      end
    end
    if status_config[:show_error] && status_config[:show_error][action]
      return [false, [status_config[:show_error][action].call]]
    end
    false
  end

  def can_edit_attribute?(user, attribute)
    return false if status_config[:allowed_parameters].nil?
    status_config[:allowed_parameters].each_pair do |scope, allowed_parameters|
      return true if user.is_user_of?(self.send(scope)) && allowed_parameters.include?(attribute)
    end
    false
  end

  def to_s
    name
  end

  def set_startup_id
    self.startup_id = self.proxy.service.id if self.proxy
  end

  def set_expected_contract_duration
    self.expected_contract_duration = (self.expected_end_date - self.expected_start_date).to_i if self.expected_start_date && self.expected_end_date
  end

  def set_contract_duration
    self.contract_duration = (self.end_date - self.start_date).to_i if self.start_date && self.end_date
  end

  def set_contract_dates
    if self.status_changed? && self.status.to_sym == :validation_production
      self.start_date = self.compute_start_date
      self.end_date = self.compute_end_date
    end
  end

  def compute_start_date
    Date.today
  end

  def compute_end_date
    case self.price.pricing_duration_type.to_sym
      when :prepaid
        self.start_date + self.set_expected_contract_duration.days
      when :monthly
        self.start_date + 1.month
      when :yearly
        self.start_date + 1.year
    end
  end

  def name
    "#{self.client} / #{self.startup} / #{self.proxy}"
  end

  def validate_client_bank_detail
    unless self.client_bank_detail.nil?
      unless self.client_bank_detail.is_active
        self.errors.add(:base, I18n.t('errors.bank_details.not_active'))
      end
      if self.client_bank_detail.service.id != self.client.id
        self.errors.add(:base, I18n.t('errors.bank_details.unauthorized'))
      end
    end
  end

  def validate_startup_bank_detail
    unless self.startup_bank_detail.nil?
      unless self.startup_bank_detail.is_active
        self.errors.add(:base, I18n.t('errors.bank_details.not_active'))
      end
      if self.startup_bank_detail.service.id != self.startup.id
        self.errors.add(:base, I18n.t('errors.bank_details.unauthorized'))
      end
    end
  end
end
