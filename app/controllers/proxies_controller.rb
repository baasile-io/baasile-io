class ProxiesController < DashboardController
  before_action :load_proxy, only: [:error_measurements, :show, :edit, :update, :destroy, :confirm_destroy]
  before_action :load_categories, only: [:new, :edit, :update, :create]

  before_action :add_breadcrumb_parent
  before_action :add_breadcrumb_current_action, except: [:index, :show]

  # allow get measure info to show
  include ShowMeasurementConcern

  def add_breadcrumb_parent
    add_breadcrumb I18n.t('services.index.title'), :services_path
    add_breadcrumb current_service.name, service_path(current_service)
    add_breadcrumb I18n.t('proxies.index.title'), :service_proxies_path
    add_breadcrumb current_proxy.name, service_proxy_path(current_service, current_proxy) if current_proxy
  end

  def index
    @collection = current_service.proxies
  end

  def audit
    @proxy = Proxy.includes(
      :prices,
      :routes,
      :proxy_parameter,
      :proxy_parameter_test,
      routes: [:query_parameters]
    ).find(params[:id])
  end

  def new
    @proxy = current_service.proxies.new
    @proxy.build_proxy_parameter
    @proxy.proxy_parameter.build_identifier
    @proxy.build_proxy_parameter_test
    @proxy.proxy_parameter_test.build_identifier
  end

  def create
    @proxy = Proxy.new(proxy_params)
    @proxy.user = current_user
    @proxy.service = current_service

    if @proxy.proxy_parameter.authorization_required?
      @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
    else
      @proxy.proxy_parameter.identifier = nil
    end
    if @proxy.proxy_parameter_test.authorization_required?
      @proxy.proxy_parameter_test.build_identifier if @proxy.proxy_parameter_test.identifier.nil?
    else
      @proxy.proxy_parameter_test.identifier = nil
    end

    if @proxy.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.proxy'))
      redirect_to_show
    else
      @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
      @proxy.proxy_parameter_test.build_identifier if @proxy.proxy_parameter_test.identifier.nil?
      render :new
    end
  end

  def edit
    @proxy.build_proxy_parameter unless @proxy.proxy_parameter
    @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
    @proxy.build_proxy_parameter_test unless @proxy.proxy_parameter_test
    @proxy.proxy_parameter_test.build_identifier if @proxy.proxy_parameter_test.identifier.nil?
  end

  def update
    @proxy.assign_attributes(proxy_params)

    if @proxy.proxy_parameter.authorization_required?
      @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
    else
      @proxy.proxy_parameter.identifier.destroy unless @proxy.proxy_parameter.identifier.nil?
    end
    if @proxy.proxy_parameter_test.authorization_required?
      @proxy.proxy_parameter_test.build_identifier if @proxy.proxy_parameter_test.identifier.nil?
    else
      @proxy.proxy_parameter_test.identifier.destroy unless @proxy.proxy_parameter_test.identifier.nil?
    end

    # update timestamp of Proxy
    if !@proxy.changed? &&
      (@proxy.proxy_parameter.changed? || @proxy.proxy_parameter_test.changed?) ||
      (!@proxy.proxy_parameter.identifier.nil? && @proxy.proxy_parameter.identifier.changed?) ||
      (!@proxy.proxy_parameter_test.identifier.nil? && @proxy.proxy_parameter_test.identifier.changed?)
      @proxy.updated_at = DateTime.now
    end

    if @proxy.save
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.proxy'))
      redirect_to_show
    else
      @proxy.proxy_parameter.build_identifier if @proxy.proxy_parameter.identifier.nil?
      @proxy.proxy_parameter_test.build_identifier if @proxy.proxy_parameter_test.identifier.nil?
      render :edit
    end
  end

  def show
  end

  def confirm_destroy
  end

  def destroy
    if @proxy.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.proxy'))
      redirect_to_index
    else
      flash[:error] = @proxy.errors.full_messages.join(', ')
      render :show
    end
  end

  private

  def redirect_to_new
    redirect_to new_service_proxy_path(current_service)
  end

  def redirect_to_index
    redirect_to service_proxies_path(current_service)
  end

  def redirect_to_show
    redirect_to service_proxy_path(current_service, @proxy)
  end

  def proxy_params
    params.require(:proxy).permit(:name, :subdomain, :category_id, :description, :public, :is_active,
                                  proxy_parameter_attributes: [:id, :follow_url, :follow_redirection, :authorization_mode, :protocol, :hostname, :port, :authorization_url, :realm, :grant_type, scopes: [], identifier_attributes: [:id, :client_id, :client_secret]],
                                  proxy_parameter_test_attributes: [:id, :follow_url, :follow_redirection, :authorization_mode, :protocol, :hostname, :port, :authorization_url, :realm, :grant_type, scopes: [], identifier_attributes: [:id, :client_id, :client_secret]])
  end

  def load_proxy
    @proxy = Proxy.includes(:proxy_parameter, :proxy_parameter_test, {:proxy_parameter => :identifier}, {:proxy_parameter_test => :identifier}).find(params[:id])
  end

  def load_categories
    @categories = Category.all
  end

  def current_proxy
    return nil unless params[:id]
    @proxy
  end
end
