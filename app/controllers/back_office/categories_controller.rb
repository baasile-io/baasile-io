module BackOffice
  class CategoriesController < BackOfficeController

    before_action :load_category, except: [:index, :new, :create]

    def index
      @collection = Category.all
    end

    def new
      @category = Category.new
      I18n.available_locales.each do |locale|
        @category.send("build_dictionary_#{locale}")
      end
    end

    def create
      @category = Category.new(category_params)
      @category.user = current_user
      if @category.save
        flash[:success] = I18n.t('actions.success.created', resource: t('activerecord.models.category'))
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
      I18n.available_locales.each do |locale|
        @category.send("build_dictionary_#{locale}") if @category.send("dictionary_#{locale}").nil?
      end
    end

    private

    def load_category
      @category = Category.find(params[:id])
    end

    def category_params
      allowed_parameters = [:name, :description]
      I18n.available_locales.each do |locale|
        dictionary_params = {}
        dictionary_params["dictionary_#{locale}_attributes".to_sym] = [:locale, :title, :body]
        allowed_parameters << dictionary_params
      end
      params.require(:category).permit(allowed_parameters)
    end

  end
end
