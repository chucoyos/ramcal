class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /payments or /payments.json
  def index
    authorize current_user, :index?, policy_class: PaymentPolicy
    @payments = base_payment_scope
  apply_filters!
  apply_current_day_filter if no_filters_applied?

  @payments = @payments.order(created_at: :desc).page(params[:page]).per(10)
  end

  # GET /payments/1 or /payments/1.json
  def show
    authorize current_user, :show?, policy_class: PaymentPolicy
  end

  # GET /payments/new
  def new
    authorize current_user, :create?, policy_class: PaymentPolicy
    @payment = Payment.new(invoice_id: params[:invoice_id])
    @invoice = Invoice.find(params[:invoice_id])
    @amount_due = @invoice.total - @invoice.payments.sum(:amount)
  end

  # GET /payments/1/edit
  def edit
    authorize current_user, :update?, policy_class: PaymentPolicy
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    @amount_due = @invoice.total - @invoice.payments.sum(:amount)
  end

  # POST /payments or /payments.json
  def create
    authorize current_user, :create?, policy_class: PaymentPolicy
    @payment = Payment.new(payment_params)
    @invoice = @payment.invoice

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @invoice, notice: "El pago se creó correctamente." }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    @invoice = @payment.invoice
    authorize current_user, :update?, policy_class: PaymentPolicy
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment.invoice, notice: "Payment was successfully updated." }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: PaymentPolicy
    @payment.destroy!

    respond_to do |format|
      # format.html { redirect_to invoices_path, status: :see_other, notice: "El pago se eliminó correctamente." } redirect_to invoice
      format.html { redirect_to @payment.invoice, status: :see_other, notice: "El pago se eliminó correctamente." }
      format.json { head :no_content }
    end
  end

  private


  def base_payment_scope
    if current_user.role.name == "cliente"
      Payment.includes(:invoice).where(invoices: { user_id: current_user.id })
    else
      Payment.includes(:invoice).all
    end
  end

  def apply_filters!
    filter_by_date_range if params[:from].present? && params[:to].present?
  end

  def filter_by_date_range
    from_date = params[:from].to_date.beginning_of_day
    to_date = params[:to].to_date.end_of_day
    @payments = @payments.where(created_at: from_date..to_date)
  end

  def apply_current_day_filter
    @payments = @payments.where(created_at: Time.zone.now.all_day)
  end

  def no_filters_applied?
    params[:from].blank? && params[:to].blank?
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_payment
    @payment = Payment.find(params[:id])
  end
  # Only allow a list of trusted parameters through.
  def payment_params
    params.require(:payment).permit(:invoice_id, :amount, :payment_date, :payment_means)
  end
end
