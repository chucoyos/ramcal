class ServicesController < ApplicationController
  before_action :set_service, only: %i[ show edit update destroy ]

  # GET /services or /services.json
  def index
    @services = Service.where(container_id: nil)
  end

  # GET /services/1 or /services/1.json
  def show
    @container = Container.find(params[:container_id]) if params[:container_id]
  end

  # GET /services/new
  def new
    @service = Service.new
    @container = Container.find(params[:container_id]) if params[:container_id]
  end

  # GET /services/1/edit
  def edit
    @container = @service.container || Container.find_by(id: params[:container_id])
  end

  # POST /services or /services.json
  def create
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
