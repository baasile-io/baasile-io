module BackOffice
  class BankDetailsController < BackOfficeController

    before_action :load_bank_detail, only: [:show, :edit, :update, :toggle_is_active]

    def index
      @collection = BankDetail.includes(:service).order(updated_at: :desc)
    end

    def edit
    end

    def show
      redirect_to_edit
    end

    def update
      @bank_detail.assign_attributes(bank_detail_params)
      if @bank_detail.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bank_detail'))
        redirect_to back_office_bank_details_path
      else
        render :edit
      end
    end

    def toggle_is_active
      @bank_detail.is_active = !@bank_detail.is_active
      if @bank_detail.save
        flash[:success] = I18n.t('actions.success.updated', resource: t('activerecord.models.bank_detail'))
      else
        flash[:error] = @bank_detail.errors.full_messages.join(', ')
      end
      redirect_to edit_back_office_bank_detail_path(@bank_detail)
    end

    private

    def redirect_to_show
      redirect_to back_office_bank_detail_path(@bank_detail)
    end

    def redirect_to_edit
      redirect_to edit_back_office_bank_detail_path(@bank_detail)
    end

    def load_bank_detail
      @bank_detail = BankDetail.find(params[:id])
    end

    def bank_detail_params
      allowed_parameters = [:name, :bank_name, :account_owner, :bic, :iban, :is_active]
      return params.require(:bank_detail).permit(allowed_parameters)
    end

  end
end
