module BackOffice
  class ContractsController < BackOfficeController
    before_action :load_contract, only: [:edit, :update, :destroy, :cancel, :audit]
    before_action :load_active_services, only: [:edit, :update]
    before_action :load_active_client, only: [:edit, :update]
    before_action :load_active_proxies, only: [:edit, :update]

    add_breadcrumb I18n.t('back_office.contracts.index.title'), :back_office_contracts_path
    before_action :add_breadcrumb_current_action, except: [:index]

    def index
      @collection = Contract.all
    end

    def audit

    end

    def edit
      @page_title = @contract.name
    end

    def update
      @page_title = @contract.name
      @contract.assign_attributes(contract_params(@contract.status))
      @contract.startup = @contract.proxy.service unless @contract.proxy.nil?
      if @contract.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        redirect_to_show
      else
        render :edit
      end
    end

    def destroy
      if @contract.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.contract'))
        redirect_to_index
      else
        render :show
      end
    end

    def cancel
      @contract.status = :deletion
      if @contract.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.contract'))
        return redirect_to_index
      end
      redirect_to_show
    end

    private

    def redirect_to_index
      return redirect_to back_office_contracts_path
    end

    def redirect_to_show
      return redirect_to back_office_contracts_path
    end

    def load_contract
      @contract = Contract.find(params[:id])
      @current_status = Contract::CONTRACT_STATUSES[@contract.status.to_sym]
    end

    def load_active_services
      @services = Service.activated_startups
    end

    def load_active_client
      @clients = Service.activated_clients
    end

    def load_active_proxies
      @proxies = []
      @services.each do |service|
        service.proxies.each do |proxy|
          @proxies << proxy if proxy.public || proxy.service.id == current_service.try(:id) || (current_contract && current_contract.proxy_id == proxy.id)
        end
      end
      if @proxies.count == 0
        redirect_to_index
      end
    end

    def contract_params(status)
      allowed_parameters = [:code, :name, :activate, :status, :expected_start_date, :expected_end_date, :contract_duration_type, :is_evergreen, :proxy_id, :client_id]
      params.require(:contract).permit(allowed_parameters)
    end

    def add_breadcrumb_current_action
      add_breadcrumb I18n.t("back_office.#{controller_name}.#{action_name}.title")
    end

    def current_contract
      return nil unless params[:id]
      @contract
    end

    def current_authorized_resource
      nil
    end

    def authorize_contract_action
      unless @contract.can?(current_user, action_name.to_sym)
        flash[:error] = I18n.t('misc.not_authorized')
        return (@contract.can?(current_user, :show) ? redirect_to_show : redirect_to_index)
      end
    end
  end
end