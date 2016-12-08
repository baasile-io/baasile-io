class PagesController < ApplicationController
  before_action :authenticate_user!

  def root
    render plain: 'Hello World!'
  end
end
