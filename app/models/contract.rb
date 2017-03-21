class Contract < ApplicationRecord

  CONTRACT_STATUS = {creation: {index: 1, scope: 'commercial', can_edit: 'client', next: :commercial_validation_sp, prev: nil},
                     commercial_validation_sp: {index: 4, scope: 'commercial', can_edit: 'startup', next: :commercial_validation_client, prev: :creation},
                     commercial_validation_client: {index: 7, scope: 'commercial', can_edit: 'client', next: :price_validation_sp, prev: :commercial_validation_sp},
                     price_validation_sp: {index: 10, scope: 'accounting', can_edit: 'startup', next: :price_validation_client, prev: :commercial_validation_client},
                     price_validation_client: {index: 13, scope: 'accounting', can_edit: 'client', next: :Validation, prev: :price_validation_sp},
                     Validation: {index: 16, scope: 'comercial', can_edit: 'client', next: nil, prev: :price_validation_client}}
  CONTRACT_STATUS_ENUM = CONTRACT_STATUS.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum status: CONTRACT_STATUS_ENUM

  belongs_to :proxy
  belongs_to :user
  belongs_to :company
  belongs_to :client, class_name: "Service"
  belongs_to :startup, class_name: "Service"
  belongs_to :price

  validates :name, presence: true
  validates :startup_id, presence:true
  validates :client_id, presence:true
  validates :proxy_id, presence:true
  validates :startup_id, uniqueness: {scope: [:client_id, :proxy_id]}
  validates :client_id, uniqueness: {scope: [:startup_id, :proxy_id]}
  validates :proxy_id, uniqueness: {scope: [:client_id, :startup_id]}


  scope :associated_companies, ->(company) { where(company: company) }
  scope :associated_clients, ->(client) { where(client: client) }
  scope :associated_startups, ->(startup) { where(startup: startup) }
  scope :associated_startups_clients, ->(cur_service) { where('startup_id=? OR client_id=?',cur_service.id, cur_service.id) }

  scope :owned, ->(user) { where(user: user) }

  def set_dup_price(price_id)
    unless price_id.empty?
      price_temp = Price.find(price_id)
      price_params_old = PriceParameter.where(price: self.price)
      destroy_price_param(price_params_old)
      price = price_temp.dup_attached(self.price)
      price_params = PriceParameter.where(price_id: price_id)
      dup_price_param(price_params, price)
      self.price = price
    end
  end

  def destroy_price_param(price_params)
    price_params.each do |price_param|
      price_param.destroy
    end
  end

  def dup_price_param(price_params, price)
    price_params.each do |price_param|
      price_param.dup_attached(price)
    end
  end

  def authorized_to_act?(user)
    return (user.has_role?(:superadmin) || user.has_role?(:commercial, self.client) || user.has_role?(:commercial, self.startup) || user.has_role?(:commercial, self.company))
  end

  def authorized_to_create?(user)
    user.has_role?(:superadmin) || user.has_role?(:commercial)
  end

  def is_accounting?(user, scope = :client)
    user.has_role?(:superadmin) || user.has_role?(:accounting, self.send(scope))
  end

  def is_commercial?(user, scope = :client)
    user.has_role?(:superadmin) || user.has_role?(:commercial, self.send(scope))
  end
end
