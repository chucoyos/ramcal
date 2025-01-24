class PayablesController < ApplicationController
  before_action :set_payable, only: %i[ show edit update destroy ]

  # GET /payables or /payables.json
  def index
    @payables = Payable.all.includes(:supplier, :user)
  end

  # GET /payables/1 or /payables/1.json
  def show
  end

  # GET /payables/new
  def new
    @payable = Payable.new
  end

  # GET /payables/1/edit
  def edit
  end

  # POST /payables or /payables.json
  def create
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
