class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /invoices or /invoices.json
  def index
    authorize current_user, :index?, policy_class: InvoicePolicy
    if current_user.role.name == "cliente"
      @invoices = current_user.invoices.order(created_at: :desc).page(params[:page]).per(10)
      @payments = Payment.includes(invoice: { services: :container })
                   .where(invoice_id: current_user.invoices.select(:id))
                   .order(invoice_id: :asc, created_at: :desc)
                   .page(params[:page]).per(10)
    else
      @invoices = Invoice.includes(:user).order(user_id: :asc, created_at: :desc).page(params[:page]).per(10)
      @payments = Payment.includes(:invoice).order(invoice_id: :asc, created_at: :desc).page(params[:page]).per(10)
    end
    apply_current_day_filter unless params_present_for_filtering?
    apply_filters!
  end
  # GET /invoices/1 or /invoices/1.json
  def show
    authorize current_user, :show?, policy_class: InvoicePolicy
  end

  # GET /invoices/new
  def new
    authorize current_user, :create?, policy_class: InvoicePolicy
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
    authorize current_user, :update?, policy_class: InvoicePolicy
  end

  # POST /invoices or /invoices.json
  def create
    authorize current_user, :create?, policy_class: InvoicePolicy
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: "Invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    authorize current_user, :update?, policy_class: InvoicePolicy
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: "Invoice was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: InvoicePolicy

    if @invoice.payments.exists?
      flash[:alert] = "Debe eliminar los pagos antes de eliminar la factura"
      redirect_to @invoice and return
    end

    @invoice.clear_services
    if @invoice.destroy
      respond_to do |format|
        format.html { redirect_to invoices_path, status: :see_other, notice: "Se eliminó la factura correctamente." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to invoices_path, status: :unprocessable_entity, notice: "Np se pudo eliminar la factura" }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def apply_filters!
    filter_by_user if params[:user_id].present?
    filter_by_status if params[:status].present?
    filter_by_date_range if params[:from_date].present? && params[:to_date].present?
  end

  def apply_current_day_filter
    today = Date.current.all_day
    @invoices = @invoices.where(created_at: today)
  end

  def params_present_for_filtering?
    params[:from_date].present? || params[:to_date].present? || params[:user_id].present? || params[:status].present?
  end

  def filter_by_user
    @invoices = @invoices.where(user_id: params[:user_id])
  end

  def filter_by_status
    @invoices = @invoices.where(status: params[:status])
  end

  def filter_by_date_range
    from_date = params[:from_date].to_date.beginning_of_day
    to_date = params[:to_date].to_date.end_of_day
    @invoices = @invoices.where(created_at: from_date..to_date)
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(:user_id, :total, :status, :issue_date, :due_date)
    end
end
