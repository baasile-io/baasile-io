class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root, :service_book, :startup, :not_found]

  layout 'public'

  def service_book
    @collection = Service.published
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
  end

  def current_module
    'service_book'
  end
end
