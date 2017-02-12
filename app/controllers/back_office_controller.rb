class BackOfficeController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  add_breadcrumb I18n.t('misc.back_office'), :back_office_path

  layout 'back_office'

  def index
  end

  def authorize_superadmin!
    return head(:forbidden) unless current_user.is_superadmin?
  end

  def current_module
    'back_office'
  end

  def add_breadcrumb_current_action
    add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
  end
end