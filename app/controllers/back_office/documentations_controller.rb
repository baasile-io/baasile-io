module BackOffice
  class DocumentationsController < BackOfficeController
    before_action :load_documentation, only: [:edit, :update, :destroy]
    before_action :load_documentation_tree, only: [:new, :create, :edit, :update]

    add_breadcrumb I18n.t('back_office.documentations.index.title'), :back_office_documentations_path
    before_action :add_breadcrumb_current_action, except: [:index]

    def index
      @collection = Documentation.platform.order(updated_at: :desc)
    end

    def new
      @documentation = Documentation.new(documentation_type: Documentation::DOCUMENTATION_TYPES[:root][:index])
      @documentation.locale = params[:documentation_locale]
    end

    def create
      @documentation = Documentation.new(documentation_type: Documentation::DOCUMENTATION_TYPES[:root][:index])
      @documentation.assign_attributes(documentation_params)
      if @documentation.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.documentation'))
        redirect_to back_office_documentations_path
      else
        render :new
      end
    end

    def update
      if @documentation.update(documentation_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.documentation'))
        redirect_to back_office_documentations_path
      else
        render :edit
      end
    end

    def destroy
      if @documentation.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.documentation'))
      end
      redirect_to back_office_documentations_path
    end

    def edit
    end

    def load_documentation
      @documentation = Documentation.find(params[:id])
    end

    def load_documentation_tree
      @documentation_tree = Documentation.platform
    end

    def documentation_params
      allowed_parameters = [:parent_id, :locale, :title, :body]
      params.require(:documentation).permit(allowed_parameters)
    end

  end
end