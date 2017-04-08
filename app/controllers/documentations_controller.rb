class DocumentationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @collection = Documentation.roots
  end

  def show
    @documentation = Documentation.find(params[:id])
    unless @documentation.public
      redirect_to documentations_path
    end
  end

  def current_module
    'documentation'
  end
end
