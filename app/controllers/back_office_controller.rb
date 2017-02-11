class BackOfficeController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_superadmin!

  layout 'back_office'

  def index
  end

  def authorize_superadmin!
    return head(:forbidden) unless current_user.is_superadmin?
  end
end