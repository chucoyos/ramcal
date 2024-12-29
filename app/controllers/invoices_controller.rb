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
    @invoice.destroy!

    respond_to do |format|
      format.html { redirect_to invoices_path, status: :see_other, notice: "Invoice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def apply_filters!
      if params[:user_id].present?
        @invoices = @invoices.where(user_id: params[:user_id])
      end
      if params[:status].present?
        @invoices = @invoices.where(status: params[:status])
      end
      if params[:issue_date].present?
        @invoices = @invoices.where("DATE(issue_date) = ?", params[:issue_date])
      end
      if params[:due_date].present?
        @invoices = @invoices.where("DATE(due_date) = ?", params[:due_date])
      end
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
