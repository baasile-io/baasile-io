include AppconfigsHelper

class Appconfig < ApplicationRecord
  APPCONFIGS = {
    api_access_token_duration: {
      setting_type: :integer,
      value: 20
    },
    api_refresh_token_duration: {
      setting_type: :integer,
      value: 120
    },
    api_max_requests_per_hour_contracts: {
      setting_type: :integer,
      value: 10
    }
  }

  DEFAULT_CONFIG = APPCONFIGS.each_with_object({}) do |appconfig, default_config|
    default_config[appconfig[0]] = appconfig[1][:value]
  end

  validates :name, inclusion: {in: APPCONFIGS.keys.map(&:to_s)}

  after_commit :update_current_config, on: :update
  after_commit :update_current_config, on: :create
  after_commit :reset_current_config, on: :destroy

  def self.get(appconfig_name)
    actual_config.fetch(appconfig_name, APPCONFIGS[appconfig_name][:value])
  end

  def self.actual_config
    Thread.current[:appconfigs] ||= reload_config
  end

  def self.reload_config
    Thread.current[:appconfigs_updated_at] = Appconfig.last_updated_at
    DEFAULT_CONFIG.dup.tap do |actual_config|
      self.all.each do |appconfig|
        appconfig_key = appconfig.name.to_sym
        actual_config[appconfig_key] = convert_appconfig_value APPCONFIGS[appconfig_key][:setting_type], appconfig.value
      end
    end
  end

  def update_current_config
    appconfig_key = self.name.to_sym
    Appconfig.actual_config[appconfig_key] = convert_appconfig_value APPCONFIGS[appconfig_key][:setting_type], self.value
  end

  def reset_current_config
    appconfig_key = self.name.to_sym
    Appconfig.actual_config[appconfig_key] = APPCONFIGS[appconfig_key][:value]
  end

  def self.last_updated_at
    self.order(updated_at: :desc).last.try(:updated_at) || DateTime.now
  end
end