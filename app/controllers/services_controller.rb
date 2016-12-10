class ServicesController < ApplicationController
  def index
    @collection = Service.all
  end

  def show
    @resource = Service.find_by_id(params[:id])
  end

  def new
    @resource = Service.new
  end

  def create
    @resource = Service.new
    @resource.update_attributes(service_params)
    @resource.user = current_user

    if @resource.save
      flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.service'))
      redirect_to service_path(@resource)
    else
      flash[:error] = @resource.errors.messages
    end
  end

  def edit
    @resource = Service.find_by_id(params[:id])
  end

  def update
    @resource = Service.find_by_id(params[:id])

    if @resource.update_attributes(service_params)
      flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.service'))
      redirect_to service_path(@resource)
    else
      flash[:error] = @resource.errors.messages
      render :edit
    end
  end

  def destroy
    @resource = Service.find_by_id(params[:id])

    if @resource.destroy
      flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.service'))
      redirect_to services_path
    else
      flash[:error] = @resource.errors.messages
      render :show
    end
  end

  def service_params
    params.require(:service).permit(:name, :description)
  end
end
