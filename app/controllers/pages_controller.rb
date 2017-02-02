class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root, :service_book]

  def service_book
    @collection = Service.published
  end

  def root
    unless current_user.nil?
      redirect_to services_path
    end
  end

  def current_module
    'service_book'
  end
end
