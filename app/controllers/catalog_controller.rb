class CatalogController < ApplicationController

  before_action :load_logotype_service

  layout 'public'

  def index
    @collectionProxy = Proxy.all
#    @collection = Service.activated_startups
	@collectionCatalog = Category.all
  end

  def sortcat
	@collectionProxy = Proxy.all.where(:category_id => params[:id])
  end

  def show
  end

  def load_logotype_service
    @logotype_service = LogotypeService.new
  end
end
