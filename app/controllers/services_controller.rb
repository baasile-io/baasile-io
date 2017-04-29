class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_service, only: [:activation_request, :show, :edit, :update, :destroy, :toggle_public, :users, :services, :logo, :logo_image]
  before_action :superadmin, only: [:set_right, :unset_right, :admin_board, :destroy, :public_set, :public_unset]
  before_action :load_companies, only: [:edit, :update, :new, :new_client, :create]
  before_action :load_users, only: [:edit, :update, :new, :new_client, :create]

  # Authorization
  before_action :authorize_action

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:show]

  # allow get measure info to show
  include ShowMeasurementConcern

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service) if current_service
  end

  def index
    @collection = current_user.services
    if @collection.size == 0
      redirect_to new_service_path
    end
  end

  def show
    children = current_service.children
    @clients = children.select {|c| c.service_type == 'client'}
    @startups = children.select {|c| c.service_type == 'startup'}
  end

  def new
    unless params[:service_type]
      return render :select_service_type
    end
    @service = Service.new
    @service.parent_id = params[:parent_id].to_i if params[:parent_id]
    @service.service_type = params[:service_type] if params[:service_type]
    @service.build_contact_detail
    @service.user = current_user
  end

  def create
    @service = Service.new
    @service.user = current_user
    @service.assign_attributes(service_params)
    if @service.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.service'))
      redirect_to service_path(@service)
    else
      render :new
    end
  end

  def edit
    @service.build_contact_detail if @service.contact_detail.nil?
  end

  def update
    @service.assign_attributes(service_params)
    if @service.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
      redirect_to service_path(@service)
    else
      render :edit
    end
  end

  def destroy
    if @service.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      redirect_to services_path
    else
      render :show
    end
  end

  def logo
    @logotype_service = LogotypeService.new

    if params[:delete] == 'true'

      # deleting the image
      status, error = @logotype_service.delete(@service.client_id)
      unless status
        flash[:error] = error
      else
        flash[:success] = I18n.t('services.logo.deleted')
      end
      redirect_to logo_service_path(@service)

    elsif params[:upload] == 'true'

      # uploading the image
      status, error = @logotype_service.upload(@service.client_id, params[:file])
      unless status
        flash[:error] = error
      else
        flash[:success] = I18n.t('services.logo.uploaded')
      end
      redirect_to logo_service_path(@service)

    else
      render :logo
    end
  end

  def logo_image
    @logotype_service = LogotypeService.new

    response.headers['Content-Type'] = 'image/png'
    response.headers['Content-Disposition'] = 'inline'

    if params.has_key?(:width) then width = params[:width].to_i else width = nil end

    render :text => @logotype_service.image(@service.client_id, width)
  end

  def activation_request
    if @service.confirmed_at.nil?
      ticket = Ticket.new
      ticket_service = Tickets::TicketService.new(ticket)
      if ticket_service.send_activation_request(current_user, @service)
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.ticket'))
      else
        flash[:error] = I18n.t('errors.an_error_occured', resource: t('activerecord.models.ticket'))
      end
    end
    redirect_to service_path(@service)
  end

  private

  def service_params
    allowed_parameters = [:name, :description, :subdomain, :public, :description_long, :website, :parent_id, :user_id, :main_commercial_id, :main_accountant_id, :main_developer_id, contact_detail_attributes: [:name, :siret, :chamber_of_commerce, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone]]
    allowed_parameters << :service_type if action_name == 'create'
    params.require(:service).permit(allowed_parameters)
  end

  def load_companies
    @companies = current_user.services.companies.reject {|s| s.id == current_service.try(:id)}
  end

  def load_users
    @users = current_user.subtree
    @users += current_service.users if current_service
    @users.uniq!
  end

  def load_service
    @service = Service.find(params[:id])
  end

  def current_service
    return nil unless params[:id]
    @service
  end

  def is_admin_of(service)
    return @service.has_role? :all, service
  end

  helper_method :is_admin_of
  def superadmin
    return head(:forbidden) unless current_user.has_role?(:superadmin)
  end

  def current_module
    'dashboard'
  end

  def current_authorized_resource
    current_service
  end

end
