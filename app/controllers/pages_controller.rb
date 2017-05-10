class PagesController < ApplicationController
  skip_before_action :set_locale, only: [:robots]

  before_action :authenticate_user!, except: [:root, :service_book, :startup, :not_found, :robots]
  before_action :load_logotype_service, only: [:service_book, :startup]

  layout 'public'

  def service_book
    @collection = Service.activated_startups.published
  end

  def startup
    @startup = Service.find_by_id(params[:id])
    if @startup.nil? || !@startup.public
      render :not_found, status: :not_found
    end
  end

  def root
  end

  def not_found
    render status: :not_found
    Airbrake.notify('Not found', {})
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
    'service_book'
  end

  def load_logotype_service
    @logotype_service = LogotypeService.new
  end
end
