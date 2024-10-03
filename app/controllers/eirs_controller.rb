class EirsController < ApplicationController
  before_action :set_eir, only: %i[ show edit update destroy ]

  # GET /eirs or /eirs.json
  def index
    @eirs = Eir.all
  end

  # GET /eirs/1 or /eirs/1.json
  def show
    pdf = @eir.generate_pdf
    send_data pdf.render, filename: "eir_#{@eir.container.number}.pdf", type: "application/pdf", disposition: "attachment"
  end

  # GET /eirs/new
  def new
    @container = Container.find(params[:container_id])
    @eir = Eir.new(container_id: @container&.id)
  end

  # GET /eirs/1/edit
  def edit
  end

  # POST /eirs or /eirs.json
  def create
    @eir = Eir.new(eir_params)
    respond_to do |format|
      if @eir.save
        format.html { redirect_to eirs_path, notice: "Eir was successfully created." }
        # format.html { redirect_to @eir, notice: "Eir was successfully created." }
        format.json { render :show, status: :created, location: @eir }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @eir.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /eirs/1 or /eirs/1.json
  def update
    respond_to do |format|
      if @eir.update(eir_params)
        format.html { redirect_to @eir, notice: "Eir was successfully updated." }
        format.json { render :show, status: :ok, location: @eir }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @eir.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /eirs/1 or /eirs/1.json
  def destroy
    @eir.destroy!

    respond_to do |format|
      format.html { redirect_to eirs_path, status: :see_other, notice: "Eir was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_eir
      @eir = Eir.find(params[:id])
    end
    # Only allow a list of trusted parameters through.
    def eir_params
      params.require(:eir).permit(:container_id, :operator, :transport, :plate, :fleet_number)
    end
end
