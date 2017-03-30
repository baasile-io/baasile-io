module BackOffice
  class CategoriesController < BackOfficeController

    before_action :load_category, except: [:index, :new, :create]

    def index
      @collection = Category.all.order(name: :asc)
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)
      @category.user = current_user
      if @category.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.category'))
        redirect_to back_office_categories_path
      else
        render :new
      end
    end

    def update
      if @category.update(category_params)
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.category'))
        redirect_to back_office_categories_path
      else
        render :edit
      end
    end

    def destroy
      if @category.destroy
        flash[:success] = I18n.t('actions.success.destroyed', resource: t('activerecord.models.category'))
      end
      redirect_to back_office_categories_path
    end

    def edit
      @page_title = @category.name
    end

    private

    def load_category
      @category = Category.find(params[:id])
    end

    def category_params
      allowed_parameters = [:name, :description]
      params.require(:category).permit(allowed_parameters)
    end

  end
end
