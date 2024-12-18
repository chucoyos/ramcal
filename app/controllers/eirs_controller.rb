class EirsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_eir, only: %i[ show edit update destroy ]

  # GET /eirs or /eirs.json
  def index
    authorize current_user, :index?, policy_class: EirPolicy
    if current_user.role.name == "cliente"
      # @eirs = Eir.joins(container: :user).where("users.id = ?", current_user.id).order(created_at: :desc).page(params[:page]).per(5)
      @eirs = Eir.includes(container: :user).where("users.id = ?", current_user.id).order(created_at: :desc).page(params[:page]).per(5)
    else
      # @eirs = Eir.order(created_at: :desc).page(params[:page]).per(5)
      @eirs = Eir.includes(container: :user).order(created_at: :desc).page(params[:page]).per(5)
    end
  end

  # GET /eirs/1 or /eirs/1.json
  def show
    authorize current_user, :show?, policy_class: EirPolicy
    id = params[:id]
    pdf = @eir.generate_pdf
    send_data pdf.render, filename: "eir_#{@eir.container.number}_#{id}.pdf", type: "application/pdf", disposition: "attachment"
  end

  # GET /eirs/new
  def new
    authorize current_user, :create?, policy_class: EirPolicy
    @container = Container.find(params[:container_id])
    @eir = Eir.new(container_id: @container&.id)
  end

  # GET /eirs/1/edit
  def edit
    authorize current_user, :update?, policy_class: EirPolicy
  end

  # POST /eirs or /eirs.json
  def create
    authorize current_user, :create?, policy_class: EirPolicy
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
    authorize current_user, :update?, policy_class: EirPolicy
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
    authorize current_user, :destroy?, policy_class: EirPolicy
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
      params.require(:eir).permit(:container_id, :operator, :transport, :plate, :fleet_number, :heavy)
    end
end
