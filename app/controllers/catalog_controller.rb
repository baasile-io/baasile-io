class CatalogController < ApplicationController

  before_action :load_logotype_service

  layout 'public'

  def index
    @collectionProxy = Proxy.all
    @collectionCatalog = Category.all
  end

  def list_by_category
    @collectionProxy = Proxy.all.where(:category_id => params[:id])
    @collectionCatalog = Category.all
  end

  def load_logotype_service
    @logotype_service = LogotypeService.new
  end
end
