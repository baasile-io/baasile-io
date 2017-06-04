class PagesController < ApplicationController
  skip_before_action :set_locale, only: [:robots]

  before_action :authenticate_user!, except: [:root, :service_book, :startup, :not_found, :robots]
  before_action :load_logotype_service, only: [:service_book, :startup]

  layout 'public'

  respond_to :html, :js

  def service_book
    @collection = Service.activated_startups.published
  end

  def startup
    @startup = Service.find_by_id(params[:id])
    if @startup.nil? || !@startup.public
      render :not_found, status: :not_found
    end
  end

  def startup_logotype
    service = Service.select(:id, :updated_at).find_by_client_id(params[:client_id])
    if service.nil?
      return render text: '', status: 404
    end

    response.headers['Content-Type'] = 'image/png'
    response.headers['Content-Disposition'] = 'inline'

    cache [service.updated_at, params[:client_id], params[:format]] do
      @logotype_service = LogotypeService.new

      render text: @logotype_service.image(params[:client_id], params[:format].try(:to_sym))
    end
  end

  def root
  end

  def not_found
    render status: :not_found
    Airbrake.notify('Not found', {
      original_url: request.original_url
    })
  end

  def internal_server_error
    render status: 500
    Airbrake.notify('Internal server error', {})
  end
  
  def robots
    robots = File.read(Rails.root + "config/robots.#{Rails.env}.txt")
    render text: robots,
           layout: false,
           content_type: 'text/plain'
  end

  def current_module
    if action_name == 'root'
      'homepage'
    else
      'service_book'
    end
  end

  def load_logotype_service
    @logotype_service = LogotypeService.new
  end
end
