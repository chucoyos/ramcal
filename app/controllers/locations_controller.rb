class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: %i[ show edit update destroy ]

  # GET /locations or /locations.json
  def index
    authorize current_user, :index?, policy_class: LocationPolicy
    @locations = Location.order(:location).page(params[:page]).per(10)
  end

  # GET /locations/1 or /locations/1.json
  def show
    authorize current_user, :show?, policy_class: LocationPolicy
  end

  # GET /locations/new
  def new
    authorize current_user, :create?, policy_class: LocationPolicy
    @location = Location.new
  end

  # GET /locations/1/edit
  def edit
    authorize current_user, :update?, policy_class: LocationPolicy
  end

  # POST /locations or /locations.json
  def create
    authorize current_user, :create?, policy_class: LocationPolicy
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        format.html { redirect_to locations_path, notice: "La ubicación ha sido creada." }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    authorize current_user, :update?, policy_class: LocationPolicy
    respond_to do |format|
      if @location.update(location_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@location, partial: "locations/location", locals: { location: @location }) }
        format.html { redirect_to locations_path, notice: "La ubicación ha sido actualizada." }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: LocationPolicy

    if @location.moves.any?
      respond_to do |format|
        format.html { redirect_to locations_path, alert: "No se puede eliminar la ubicación, está asociada a movimientos." }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@location, partial: "locations/location", locals: { location: @location }) }
        format.json { render json: { error: "No se puede eliminar la ubicación, está asociada a movimientos." }, status: :unprocessable_entity }
      end
    else
      @location.destroy!
      respond_to do |format|
        format.html { redirect_to locations_path, status: :see_other, notice: "La ubicación ha sido eliminada." }
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@location) }
        format.json { head :no_content }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def location_params
      params.require(:location).permit(:location, :available)
    end
end
