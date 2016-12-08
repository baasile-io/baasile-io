class PagesController < ApplicationController
  before_action :authenticate_user!

  def root
    render plain: I18n.t('hello')
  end
end
