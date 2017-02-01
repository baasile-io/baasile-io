class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root, :annuaire_services]

  def annuaire_services
    @collection = Service.published
  end

  def root
    unless current_user.nil?
      redirect_to services_path
    end
  end
end
