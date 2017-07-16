module BackOffice
  class AppconfigsController < BackOfficeController
    before_action :load_appconfig, only: [:edit, :destroy, :update]

    def index
      @appconfigs = Appconfig::APPCONFIGS
    end

    def edit
    end

    def update
      @appconfig.assign_attributes(appconfig_params)
      return destroy if @appconfig.value.blank? || convert_appconfig_value(Appconfig::APPCONFIGS[@appconfig.name.to_sym][:setting_type], @appconfig.value) == Appconfig::APPCONFIGS[@appconfig.name.to_sym][:value]
      if @appconfig.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.appconfig'))
        redirect_to back_office_appconfigs_path
      else
        render :edit
      end
    end

    def destroy
      if @appconfig.persisted?
        if @appconfig.destroy
          flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.appconfig'))
        end
      end
      redirect_to back_office_appconfigs_path
    end

    private

    def load_appconfig
      @appconfig_key = params[:id].to_sym
      @default_appconfig = Appconfig::APPCONFIGS[@appconfig_key]
      @appconfig = Appconfig.find_by_name(@appconfig_key) || Appconfig.new(name: @appconfig_key)
    end

    def appconfig_params
      params.require(:appconfig).permit(:name, :value)
    end
  end
end