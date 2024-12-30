class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy ]

  # GET /payments or /payments.json
  def index
    authorize current_user, :index?, policy_class: PaymentPolicy
    if current_user.role.name == "cliente"
      @payments = Payment.includes(invoice: :container).where(invoices: { user_id: current_user.id })
    else
      @payments = Payment.includes(:invoice).all
    end
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
  end

  # GET /payments/1/edit
  def edit
    authorize current_user, :update?, policy_class: PaymentPolicy
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
  end

  # POST /payments or /payments.json
  def create
    authorize current_user, :create?, policy_class: PaymentPolicy
    @payment = Payment.new(payment_params)
    @invoice = @payment.invoice

    respond_to do |format|
      if @payment.save
        format.html { redirect_to invoices_path, notice: "Pago registrado correctamente." }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    authorize current_user, :update?, policy_class: PaymentPolicy
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: "Payment was successfully updated." }
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
      format.html { redirect_to invoices_path, status: :see_other, notice: "El pago se eliminó correctamente." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.require(:payment).permit(:invoice_id, :amount, :payment_date, :payment_means)
    end
end
