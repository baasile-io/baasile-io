module BackOffice
  class GeneralConditionsController < BackOfficeController
    before_action :load_general_condition, only: [:edit, :update, :destroy]
    before_action :is_used, only: [:edit, :update, :destroy]

    def index
      @collection = GeneralCondition.all
    end

    def new
      @general_condition = GeneralCondition.new
      I18n.available_locales.each do |locale|
        @general_condition.send("build_dictionary_#{locale}")
      end
    end

    def create
      @general_condition = GeneralCondition.new(general_condition_params)
      @general_condition.user = current_user
      if @general_condition.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.general_condition'))
        redirect_to back_office_general_conditions_path
      else
        render :new
      end
    end

    def update
      if @general_condition.update(general_condition_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.general_condition'))
        redirect_to back_office_general_conditions_path
      else
        render :edit
      end
    end

    def destroy
      if @general_condition.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.general_condition'))
      end
      redirect_to back_office_general_conditions_path
    end

    def edit
      @page_title = @general_condition.name
      I18n.available_locales.each do |locale|
        @general_condition.send("build_dictionary_#{locale}") if @general_condition.send("dictionary_#{locale}").nil?
      end
    end

    private

    def is_used
      if @general_condition.is_used?
        flash[:error] = I18n.t('misc.is_used')
        redirect_to back_office_general_conditions_path
      end
    end

    def general_condition_params
      allowed_parameters = [:gc_version, :effective_start_date]
      I18n.available_locales.each do |locale|
        dictionary_params = {}
        dictionary_params["dictionary_#{locale}_attributes".to_sym] = [:locale, :title, :body]
        allowed_parameters << dictionary_params
      end
      params.require(:general_condition).permit(allowed_parameters)
    end

    def load_general_condition
      @general_condition = GeneralCondition.find(params[:id])
    end

  end
end
