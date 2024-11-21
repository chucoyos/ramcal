class PricingsController < ApplicationController
  before_action :set_pricing, only: %i[ show edit update destroy ]

  # GET /pricings or /pricings.json
  def index
    @pricings = Pricing.all
  end

  # GET /pricings/1 or /pricings/1.json
  def show
  end

  # GET /pricings/new
  def new
    @pricing = Pricing.new
    @services = Service.where(container_id: nil)
  end

  # GET /pricings/1/edit
  def edit
    @services = Service.where(container_id: nil)
  end

  # POST /pricings or /pricings.json
  def create
    @pricing = Pricing.new(pricing_params)

    respond_to do |format|
      if @pricing.save
        format.html { redirect_to @pricing, notice: "Pricing was successfully created." }
        format.json { render :show, status: :created, location: @pricing }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pricing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pricings/1 or /pricings/1.json
  def update
    respond_to do |format|
      if @pricing.update(pricing_params)
        format.html { redirect_to @pricing, notice: "Pricing was successfully updated." }
        format.json { render :show, status: :ok, location: @pricing }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pricing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pricings/1 or /pricings/1.json
  def destroy
    @pricing.destroy!

    respond_to do |format|
      format.html { redirect_to pricings_path, status: :see_other, notice: "Pricing was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pricing
      @pricing = Pricing.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def pricing_params
      params.require(:pricing).permit(:user_id, :service_id, :price, :grace_period_days, :start_delay)
    end
end
