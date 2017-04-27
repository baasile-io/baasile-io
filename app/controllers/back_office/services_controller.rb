module BackOffice
  class ServicesController < BackOfficeController
    before_action :load_service, except: [:index, :new, :create]
    before_action :load_companies, only: [:edit, :update, :new, :create]
    before_action :load_all_users, only: [:new, :create]
    before_action :load_associated_admins, only: [:edit, :update]

    add_breadcrumb I18n.t('back_office.services.index.title'), :back_office_services_path
    before_action :add_breadcrumb_current_action, except: [:index]

    def index
      @collection = Service.includes(:users).all.order(updated_at: :desc)
    end

    def new
      @service = Service.new
      @service.user = current_user
      @service.build_contact_detail
    end

    def show
      redirect_to edit_back_office_service_path(@service)
    end

    def create
      @service = Service.new(service_params)
      if params[:activate].present?
        @service.confirmed_at = DateTime.now if @service.confirmed_at.nil?
        Tickets::TicketService.new(nil).closed_tickets_by_activation(@service)
      else
        @service.confirmed_at = nil
      end
      if @service.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
        redirect_to back_office_services_path
      else
        render :new
      end
    end

    def update
      @page_title = @service.name
      @service.assign_attributes(service_params)
      if params[:activate].present?
        @service.confirmed_at = DateTime.now if @service.confirmed_at.nil?
        Tickets::TicketService.new(nil).closed_tickets_by_activation(@service)
      else
        @service.confirmed_at = nil
      end
      if @service.save
        @service.reset_identifiers if params[:reset_identifiers]
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
        redirect_to back_office_services_path
      else
        render :edit
      end
    end

    def destroy
      if @service.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      end
      redirect_to back_office_services_path
    end

    def edit
      @service.build_contact_detail if @service.contact_detail.nil?
      @page_title = @service.name
    end

    private

    def load_service
      @service = Service.find(params[:id])
    end

    def load_companies
      @companies = Service.companies.reject {|s| s.id == @service.try(:id)}
    end

    def load_all_users
      @users = User.all
    end

    def load_associated_admins
      @users = @service.users.reject {|u| !u.has_role?(:admin, @service) }
    end

    def service_params
      allowed_parameters = [:user_id, :name, :service_type, :description, :description_long, :website, :parent_id, :subdomain, :public, contact_detail_attributes: [:name, :siret, :chamber_of_commerce, :address_line1, :address_line2, :address_line3, :zip, :city, :country, :phone]]
      params.require(:service).permit(allowed_parameters)
    end

  end
end