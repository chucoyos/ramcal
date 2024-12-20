class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /services or /services.json
  def index
    authorize current_user, :index?, policy_class: ServicePolicy
    @services = Service.where(container_id: nil)
  end

  # GET /services/1 or /services/1.json
  def show
    authorize current_user, :show?, policy_class: ServicePolicy
    @container = Container.find(params[:container_id]) if params[:container_id]
  end

  # GET /services/new
  def new
    authorize current_user, :create?, policy_class: ServicePolicy
    @service = Service.new
    @container = Container.find(params[:container_id]) if params[:container_id]
  end

  # GET /services/1/edit
  def edit
    authorize current_user, :update?, policy_class: ServicePolicy
    @container = @service.container || Container.find_by(id: params[:container_id])
  end

  # POST /services or /services.json
  def create
    authorize current_user, :create?, policy_class: ServicePolicy
    @service = Service.new(service_params)

    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: "Servicio creado exitosamente." }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1 or /services/1.json
  def update
    authorize current_user, :update?, policy_class: ServicePolicy
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: "Service actualizado exitosamente." }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1 or /services/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: ServicePolicy
    @service.destroy!

    respond_to do |format|
      format.html do
        if @service.container
          redirect_to container_path(@service.container), status: :see_other, notice: "Se eliminó el servicio."
        else
          redirect_to services_path, status: :see_other, notice: "Se eliminó el servicio."
        end
      end
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = Service.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.require(:service).permit(:container_id, :name, :charge, :start_date, :end_date, :invoiced)
    end
end
