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
      return destroy if convert_appconfig_value(Appconfig::APPCONFIGS[@appconfig.name.to_sym][:setting_type], @appconfig.value) == Appconfig::APPCONFIGS[@appconfig.name.to_sym][:value]
      if @appconfig.save
        redirect_to back_office_appconfigs_path
      else
        render :edit
      end
    end

    def destroy
      if @appconfig.persisted?
        @appconfig.destroy
      end
      redirect_to back_office_appconfigs_path
    end

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