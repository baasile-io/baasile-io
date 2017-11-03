module BackOffice
  class RequestTemplatesController < BackOfficeController

    before_action :load_request, except: [:index, :new, :create]
    before_action :load_categories, only: [:new, :edit, :update, :create]

    def index
      @collection = Tester::Requests::Template.all.order(updated_at: :desc)
    end

    def new
      @request = Tester::Requests::Template.new
      I18n.available_locales.each do |locale|
        @request.send("build_dictionary_#{locale}") if @request.send("dictionary_#{locale}").nil?
      end
    end

    def create
      @request = Tester::Requests::Template.new(requests_params)
      @request.user = current_user

      if @request.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.tester/request'))
        redirect_to_index
      else
        render :new
      end
    end

    def update
      @request_template_title = current_request.template_name

      current_request.user = current_user

      if params[:expire_results] == 'true'
        current_request.update_expiration_date
      end

      if current_request.update(requests_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.tester/request'))
        redirect_to_index
      else
        render :edit
      end
    end

    def destroy
      if current_request.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.tester/request'))
      end
      redirect_to back_office_request_templates_path
    end

    def edit
      I18n.available_locales.each do |locale|
        current_request.send("build_dictionary_#{locale}") if current_request.send("dictionary_#{locale}").nil?
      end
      @request_template_title = current_request.template_name
    end

    def show
      redirect_to_edit
    end

    def redirect_to_edit
      redirect_to edit_back_office_request_template_path(current_request)
    end

    def redirect_to_index
      redirect_to back_office_request_templates_path
    end

    def current_request
      @current_request
    end

    private

    def load_categories
      @categories = Category.all
    end

    def requests_params
      allowed_parameters = [
        :name,
        :method,
        :format,
        :request_body,
        :category_id,
        :expected_response_status,
        :expected_response_format,
        {tester_parameters_headers_attributes: [:id, :type, :name, :value, :_destroy]},
        {tester_parameters_queries_attributes: [:id, :type, :name, :value, :_destroy]},
        {tester_parameters_response_headers_attributes: [:id, :type, :name, :value, :comparison_operator, :expected_type, :_destroy]},
        {tester_parameters_response_body_elements_attributes: [:id, :type, :name, :value, :comparison_operator, :expected_type, :_destroy]}
      ]

      I18n.available_locales.each do |locale|
        dictionary_params = {}
        dictionary_params["dictionary_#{locale}_attributes".to_sym] = [:locale, :title, :body]
        allowed_parameters << dictionary_params
      end

      params.require(:tester_request).permit(allowed_parameters)
    end

    def load_request
      @current_request = Tester::Requests::Template.find(params[:id])
    end

  end
end
