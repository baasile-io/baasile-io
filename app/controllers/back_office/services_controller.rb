module BackOffice
  class ServicesController < BackOfficeController
    before_action :load_service, except: [:index, :new, :create]
    before_action :load_companies, only: [:edit, :update, :new, :create]
    before_action :load_all_users, only: [:new, :create]
    before_action :load_associated_users, only: [:edit, :update]

    def index
      @collection = Service.includes(:users, :proxies).all.order(updated_at: :desc)

      @collection = search   @collection
      @collection = paginate @collection
    end

    def new
      @service = Service.new
      @service.user = current_user
      @service.build_contact_detail
    end

    def show
      redirect_to_edit
    end

    def users
      @users = @service.users.order(first_name: :asc, last_name: :asc)
      @other_users = User.where.not(id: @users.pluck(:id)).order(first_name: :asc, last_name: :asc)
    end

    def associate_user
      user = User.find_by_id(params[:service][:user_id])
      if ::Users::UserAssociationsService.new(user).create_association(@service)
        user.send(:add_role, params[:service][:role], @service)
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.user_association'))
      end
      redirect_to_users
    end

    def disassociate_user
      user = User.find_by_id(params[:user_id])
      if UserAssociation.where(user: user, associable: @service).destroy_all

        # remove admin role
        @service.update(main_commercial_id: nil)  if @service.main_commercial_id == user.id
        @service.update(main_accountant_id: nil)  if @service.main_accountant_id == user.id
        @service.update(main_developer_id: nil)   if @service.main_developer_id == user.id

        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.user_association'))
      end
      redirect_to_users
    end

    def toggle_user_role
      user = User.find_by_id(params[:user_id])
      scope = params[:scope]
      if user.send(user.has_role?(scope, @service) ? :remove_role : :add_role, scope, @service)
        flash[:success] = I18n.t('actions.success.updated', resource: t('misc.role'))
      end
      redirect_to_users
    end

    def create
      @service = Service.new(service_params)
      if params[:activate].present?
        @service.confirmed_at = DateTime.now if @service.confirmed_at.nil?
        Tickets::TicketService.new(nil, current_user).closed_tickets_by_activation(@service)
      else
        @service.confirmed_at = nil
      end
      if @service.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
        redirect_to_index
      else
        render :new
      end
    end

    def destroy
      if @service.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      else
        flash[:error] = @service.errors.full_messages.join(', ')
      end
      redirect_to_index
    end

    def edit
      @service.build_contact_detail if @service.contact_detail.nil?
      @page_title = @service.name
    end

    def update
      @page_title = @service.name
      @service.assign_attributes(service_params)
      if params[:activate].present?
        @service.confirmed_at = DateTime.now if @service.confirmed_at.nil?
        Tickets::TicketService.new(nil, current_user).closed_tickets_by_activation(@service)
      else
        @service.confirmed_at = nil
      end
      if @service.save
        @service.reset_identifiers if params[:reset_identifiers]
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
        redirect_to_edit
      else
        render :edit
      end
    end

    private

    def redirect_to_index
      redirect_to back_office_services_path
    end

    def redirect_to_edit
      redirect_to edit_back_office_service_path(@service)
    end

    def redirect_to_users
      redirect_to users_back_office_service_path(@service)
    end

    def load_service
      @service = Service.find(params[:id])
    end

    def load_companies
      @companies = Service.companies.reject {|s| s.id == @service.try(:id)}
    end

    def load_all_users
      @users = User.all.order(first_name: :asc, last_name: :asc)
    end

    def load_associated_users
      @users = @service.users.order(first_name: :asc, last_name: :asc)
    end

    def service_params
      allowed_parameters = [
        :user_id,
        :main_commercial_id,
        :main_accountant_id,
        :main_developer_id,
        :name,
        :service_type,
        :description,
        :description_long,
        :website,
        :parent_id,
        :subdomain,
        :public,
        contact_detail_attributes: [
          :name,
          :siret,
          :chamber_of_commerce,
          :address_line1,
          :address_line2,
          :address_line3,
          :zip,
          :city,
          :country,
          :phone
        ]
      ]
      params.require(:service).permit(allowed_parameters)
    end

  end
end