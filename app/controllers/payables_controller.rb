class PayablesController < ApplicationController
  before_action :set_payable, only: %i[ show edit update destroy ]

  # GET /payables or /payables.json
  def index
    authorize current_user, :index?, policy_class: PayablePolicy

    # Default date range: Start & End of Current Month
    start_date = params[:start_date].presence || Date.today.beginning_of_month
    end_date = params[:end_date].presence || Date.today.end_of_month

    @payables = Payable.includes(:supplier, :user)
                       .where(payment_date: start_date..end_date)

    # Filters
    @payables = @payables.where(payment_type: params[:payment_type]) if params[:payment_type].present?
    @payables = @payables.where(payment_means: params[:payment_means]) if params[:payment_means].present?
    @payables = @payables.where(supplier_id: params[:supplier_name]) if params[:supplier_name].present?

    # Pagination (using Kaminari)
    @payables = @payables.page(params[:page]).per(10)
  end


  # GET /payables/1 or /payables/1.json
  def show
    authorize current_user, :show?, policy_class: PayablePolicy
  end

  # GET /payables/new
  def new
    authorize current_user, :create?, policy_class: PayablePolicy
    @payable = Payable.new
  end

  # GET /payables/1/edit
  def edit
    authorize current_user, :update?, policy_class: PayablePolicy
  end

  # POST /payables or /payables.json
  def create
    authorize current_user, :create?, policy_class: PayablePolicy
    @payable = Payable.new(payable_params)

    respond_to do |format|
      if @payable.save
        format.html { redirect_to @payable, notice: "Payable was successfully created." }
        format.json { render :show, status: :created, location: @payable }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payables/1 or /payables/1.json
  def update
    authorize current_user, :update?, policy_class: PayablePolicy
    respond_to do |format|
      if @payable.update(payable_params)
        format.html { redirect_to @payable, notice: "Payable was successfully updated." }
        format.json { render :show, status: :ok, location: @payable }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payables/1 or /payables/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: PayablePolicy
    @payable.destroy!

    respond_to do |format|
      format.html { redirect_to payables_path, status: :see_other, notice: "Payable was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payable
      @payable = Payable.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def payable_params
      params.require(:payable).permit(:payment_amount, :payment_date, :payment_type, :payment_means, :payment_concept, :supplier_id, :user_id)
    end
end
