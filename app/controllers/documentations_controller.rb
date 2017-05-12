class DocumentationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @collection = Documentation.roots
  end

  def show
    @documentation = Documentation.find_by_id(params[:id])
    if @documentation.nil?
      flash[:error] = I18n.t('errors.page_not_found')
      return redirect_to documentations_path
    end
    unless @documentation.public
      redirect_to documentations_path
    end
  end

  def errors
    @errors = I18n.t('errors.api', locale: :en)
  end

  def current_module
    'documentation'
  end
end
