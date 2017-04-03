class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root, :service_book, :startup]

  layout 'public'

  def service_book
    @collection = Service.published
  end

  def startup
    @startup = Service.find(params[:id])
    if @startup.nil? || !@startup.public
      return head(:forbidden)
    end
  end

  def root
  end

  def current_module
    'service_book'
  end
end
