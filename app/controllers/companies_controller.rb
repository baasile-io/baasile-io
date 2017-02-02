class CompaniesController < ApplicationController

  before_action :load_company_and_full_authorize, only: [:admin_list, :destroy, :set_admin, :unset_admin, :add_admin ]

  before_action :load_company_and_authorize, only: [:services_company, :show, :edit, :update, :activate, :deactivate]

  def index
    if current_user.is_campany_admin || current_user.is_superadmin
      @collection = Company.authorized(current_user)
    else
      return head(:forbidden)
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
    logger.info company_params.inspect
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

  def services_company
    @services = Service.associated(@company)
  end

  def current_module
    'companies'
  end

  def admin_list
    @collection = User.all.reject { |user| !user.has_role?(:admin, @company) }

  end

  def set_admin
    user = User.find_by_id(params[:user_id])
    if (!@company.nil? && !user.nil?)
      user.add_role(:admin, @company)
    end
    redirect_to admin_list_company_path(@company.id)
  end

  def unset_admin
    user = User.find_by_id(params[:user_id])
    if (!@company.nil? && !user.nil?)
      user.remove_role(:admin, @company)
    end
    redirect_to admin_list_company_path(@company.id)
  end

  def add_admin
    @company = Company.find_by_id(params[:id])
    @collection = User.all.reject { |user| user.has_role?(:admin, @company) }
  end


  private

  def company_params
    allowed_parameters = [:name, contact_detail_attributes: [:name, :siret, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone]]
    allowed_parameters << :subdomain if current_user.has_role?(:superadmin)
    params.require(:company).permit(allowed_parameters)
  end

  def load_company_and_full_authorize
    @company = Company.find_by_id(params[:id])
    return redirect_to companies_path if @company.nil?
    return full_authorized?
  end

  def load_company_and_authorize
    @company = Company.find_by_id(params[:id])
    return redirect_to companies_path if @company.nil?
    return authorized?
  end

  def full_authorized?
    unless current_user.is_superadmin
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
