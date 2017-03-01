class CompaniesController < ApplicationController
  before_action :load_company_and_authorize_superadmin, only: [:admin_list, :destroy, :set_admin, :unset_admin, :add_admin]
  before_action :load_company_and_authorize_admin, only: [:startups, :clients, :show, :edit, :update, :activate, :deactivate]
  before_action :authorize_admin!

  def index
    @collection = Company.authorized(current_user)
    if @collection.size == 0
      redirect_to new_company_path
    end
  end

  def show
  end

  def new
    @company = Company.new
    @company.build_contact_detail
  end

  def create
    @company = Company.new(company_params)
    @company.user = current_user

    if @company.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.company'))
      redirect_to company_path(@company)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.company'))
      redirect_to company_path(@company)
    else
      render :edit
    end
  end

  def destroy
    if @company.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.company'))
      redirect_to companies_path
    else
      render :show
    end
  end

  def startups
    @services = @company.services.where(service_type: :startup)
  end

  def clients
    @services = @company.services.where(service_type: :client)
  end


  def current_module
    'companies'
  end

  def admin_list
    @collection = User.all.reject { |user| !user.has_role?(:admin, @company) }
  end

  def set_admin
    user = User.find_by_id(params[:user_id])
    unless user.nil?
      user.add_role(:admin, @company)
    end
    redirect_to admin_list_company_path(@company.id)
  end

  def unset_admin
    user = User.find_by_id(params[:user_id])
    unless user.nil?
      user.remove_role(:admin, @company)
    end
    redirect_to admin_list_company_path(@company.id)
  end

  def add_admin
    @users = User.all.reject { |user| user.has_role?(:admin, @company) || user.has_role?(:superadmin) }
  end


  private

  def company_params
    allowed_parameters = [:name, contact_detail_attributes: [:name, :siret, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone]]
    allowed_parameters << :subdomain if current_user.has_role?(:superadmin)
    params.require(:company).permit(allowed_parameters)
  end

  def load_company_and_authorize_superadmin
    @company = Company.find_by_id(params[:id])
    return redirect_to companies_path if @company.nil?
    return full_authorized?
  end

  def load_company_and_authorize_admin
    @company = Company.find_by_id(params[:id])
    return redirect_to companies_path if @company.nil?
    return authorized?
  end

  def full_authorized?
    unless current_user.is_superadmin?
      return head(:forbidden)
    end
  end

  def authorized?
    unless @company.authorized?(current_user)
      return head(:forbidden)
    end
  end

  def current_company
    return nil unless params[:id]
    @company
  end
end
