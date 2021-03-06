class ApplicationController < ActionController::Base
  include PaginateConcern
  include SearchConcern
  include FlashMessagesHelper

  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalid_auth_token

  # reset captcha code after each request for security
  after_action :reset_last_captcha_code!

  # Versioning
  before_action :set_paper_trail_whodunnit

  before_action :set_locale

  after_filter :flash_to_headers

  helper_method :current_company
  helper_method :current_service
  helper_method :current_proxy
  helper_method :current_route
  helper_method :current_module
  helper_method :current_contract
  helper_method :current_price
  helper_method :current_host
  helper_method :current_bill
  helper_method :current_bank_detail
  helper_method :current_service_owner
  helper_method :current_request

  def invalid_auth_token
    render status: :bad_request
    Airbrake.notify('Bad request: ActionController::InvalidAuthenticityToken', {
      original_url: request.original_url
    })
  end

  def set_locale
    I18n.locale = params[:locale]
  end

  def default_url_options(options={})
    {locale: (params[:locale] || current_user.try(:language) || I18n.default_locale)}
  end

  def after_sign_in_path_for(resource)
    location = request.env['omniauth.origin'] || stored_location_for(resource)
    if location.nil? || location == root_path
      location = if resource.has_role?(:superadmin)
                   back_office_path(locale: resource.language)
                 else
                   services_path(locale: resource.language)
                 end
    end
    location
  end

  def authenticate_user!(opts={})
    super(opts)
    if !current_user.nil? && !current_user.is_active
      return head(:forbidden)
    end
  end

  def authorize_admin!
    unless current_user.is_admin_of?(current_company) || current_user.is_superadmin?
      return head(:forbidden)
    end
  end

  def current_company
    nil
  end

  def current_service
    nil
  end

  def current_proxy
    nil
  end

  def current_route
    nil
  end

  def current_module
    nil
  end

  def current_contract
    nil
  end

  def current_price
    nil
  end

  def current_bill
    nil
  end

  def current_request
    nil
  end

  def current_bank_detail
    nil
  end

  def current_service_owner
    nil
  end

  def current_host
    "#{request.protocol}#{request.host_with_port}"
  end

  # Authorization
  def authorize_action
    if current_authorized_resource
      unless current_user.has_role?(:superadmin) || current_authorized_resource.can?(current_user, controller_name, action_name)
        flash[:error] = I18n.t('misc.not_authorized')
        return redirect_back fallback_location: services_path
      end
    end
  end

  def authorize_contract_set_prices
    unless current_contract.nil?
      unless @contract.can?(current_user, :prices)
        flash[:error] = I18n.t('misc.not_authorized')
        return redirect_back fallback_location: (current_service.nil? ? contract_path(current_contract) : service_contract_path(current_service, current_contract))
      end
    end
  end

  #def authorize_contract_set_bank_details
  #  unless current_contract.nil?
  #    unless @contract.can?(current_user, :bank_details)
  #      flash[:error] = I18n.t('misc.not_authorized')
  #      return redirect_back fallback_location: (current_service.nil? ? contract_path(current_contract) : service_contract_path(current_service, current_contract))
  #    end
  #  end
  #end

end
