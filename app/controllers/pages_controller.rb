class PagesController < ApplicationController
  skip_before_action :set_locale, only: [:robots]

  before_action :authenticate_user!, except: [:root, :startup, :catalog, :category, :catalog_search, :catalog_product, :not_found, :robots]
  before_action :load_logotype_service, only: [:startup, :catalog, :category, :catalog_search, :catalog_product]
  before_action :load_categories, only: [:catalog, :category, :catalog_search, :catalog_product]

  layout 'public'

  respond_to :html, :js

  def catalog
    @collection = Proxy.from_activated_and_published_startups.published.order(created_at: :desc).limit(8)
  end

  def category
    @collection = Proxy.from_activated_and_published_startups.published

    if params[:cat] == '0'
      return without_category
    end

    @category = Category.find(params[:cat])
    @collection = @collection.by_category(@category)

    @category_title = @category.name
    @category_description = @category.description

    @collection = paginate @collection, per_page: 8
  end

  def without_category
    @collection = @collection.without_category

    @category_title = t('misc.without_category')

    @collection = paginate @collection, per_page: 8
  end

  def catalog_search
    unless params[:q].present?
      return redirect_to catalog_path
    end

    @collection = Proxy.from_activated_and_published_startups.published

    @collection = search @collection
    @collection = paginate @collection
  end

  def catalog_product
    @proxy = Proxy.joins(:service).from_activated_and_published_startups.published.find(params[:proxy_id])

    @related_proxies = @proxy.service.proxies.from_activated_and_published_startups.published.where.not(id: params[:proxy_id])
  end

  def startup
    @startup = Service.activated_startups.published.find_by_id(params[:id])
    if @startup.nil?
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
    case action_name
    when 'root'
      'homepage'
    else
      'catalog'
    end
  end

  def load_logotype_service
    @logotype_service = LogotypeService.new
  end

  def load_categories
    @categories = Category.all
  end
end
