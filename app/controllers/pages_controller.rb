class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root, :service_book]

  layout 'public'

  def service_book
    @collection = Service.published
  end

  def root
  end

  def current_module
    'service_book'
  end
end
