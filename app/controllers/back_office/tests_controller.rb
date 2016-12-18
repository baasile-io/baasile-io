module BackOffice
  class TestsController < BackOfficeController
    def index
      @collection = Functionality.authorized(current_user)
    end

    def new
    end

    def create
    end

    def edit
    end

    def update
    end

    def show
    end

    def destroy
    end
  end
end
