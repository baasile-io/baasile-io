module BackOffice
  class BankDetailsController < BackOfficeController

    before_action :load_bank_detail, only: [:show, :toggle_is_active]

    def index
      @collection = BankDetail.includes(:service).templates.order(updated_at: :desc)
    end

    def show
    end

    def toggle_is_active
      @bank_detail.is_active = !current_bank_detail.is_active
      if @bank_detail.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bank_detail'))
      else
        flash[:error] = @bank_detail.errors.full_messages.join(', ')
      end
      redirect_to_show
    end

    private

    def redirect_to_index
      return redirect_to back_office_bank_details_path
    end

    def redirect_to_show
      return redirect_to back_office_bank_detail_path(current_bank_detail)
    end

    def load_bank_detail
      @bank_detail = BankDetail.find(params[:id])
    end

    def current_bank_detail
      @bank_detail
    end

  end
end
