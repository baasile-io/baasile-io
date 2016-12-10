class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:root]

  def root
    unless current_user.nil?
      redirect_to services_path
    end
  end
end
