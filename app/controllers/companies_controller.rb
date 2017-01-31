class CompaniesController < ApplicationController

  before_action :load_company_and_authorize, only: [:show, :edit, :update, :destroy, :activate, :deactivate]


  def index
    @collection = Company.all
  end

  def show
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new
    @company.user = current_user
    @company.assign_attributes(company_params)
    logger.debug "######## 1 ###########"
    logger.debug company_params.inspect
    logger.debug "######## 1 ###########"
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
    @company.assign_attributes(company_params)
    logger.debug "######## 2 ###########"
    logger.debug company_params.inspect
    logger.debug "######## 2 ###########"
    if @company.save
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


  private

  def company_params
    logger.debug "######## 3 ###########"
    logger.debug params.inspect
    logger.debug "######## 3 ###########"
    allowed_parameters = [:name, contactable_attributes:
        [:name, :siret, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone ]]
    allowed_parameters << :subdomain if current_user.has_role?(:superadmin)
    params.require(:company).permit(allowed_parameters)
  end


  def load_company_and_authorize
    @company = Company.find_by_id(params[:id])
    return redirect_to companies_path if @company.nil?
=begin
    unless @company.authorized?(current_user)
      return head(:forbidden)
    end
=end
  end

  def current_company
    return nil unless params[:id]
    @company
  end
end