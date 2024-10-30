class ContainersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_container, only: %i[ show edit update destroy ]

  # GET /containers or /containers.json
  def index
    authorize current_user, :index?, policy_class: ContainerPolicy
    if current_user.role.name == "cliente"
      @containers = Container.where(user_id: current_user.id).order(created_at: :desc).page(params[:page]).per(10)
    else
      @containers = Container.order(created_at: :desc).page(params[:page]).per(10)
    end
    if params[:number].present?
      @containers = @containers.where("number ILIKE ?", "%#{params[:number]}%").page(params[:page]).per(10)
    end
    if params[:cargo_owner].present?
      @containers = @containers.where("cargo_owner ILIKE ?", "%#{params[:cargo_owner]}%").page(params[:page]).per(10)
    end
    if params[:move_type].present? && params[:move_created_at].present?
      @containers = @containers.joins(:moves)
                               .where(moves: { move_type: params[:move_type] })
                               .where("moves.created_at::date = ?", params[:move_created_at].to_date).page(params[:page]).per(10)
    end
    if params[:user_id].present?
      @containers = @containers.where(user_id: params[:user_id]).page(params[:page]).per(10)
    end

    respond_to do |format|
      format.html # Render the regular HTML view
      format.xlsx do
        # Render Excel using Axlsx
        send_data generate_excel(@containers),
                  filename: "containers_#{Date.today}.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      end
    end
  end

  # GET /containers/1 or /containers/1.json
  def show
    authorize current_user, :show?, policy_class: ContainerPolicy
  end

  # GET /containers/new
  def new
    authorize current_user, :create?, policy_class: ContainerPolicy
    if current_user.role.name == "cliente"
      @container = Container.new(user_id: current_user.id)
    else
      @container = Container.new
    end
  end

  # GET /containers/1/edit
  def edit
    authorize current_user, :update?, policy_class: ContainerPolicy
  end

  # POST /containers or /containers.json
  def create
    authorize current_user, :create?, policy_class: ContainerPolicy
    if current_user.role.name == "cliente"
      @container = Container.new(container_params.merge(user_id: current_user.id))
    else
      @container = Container.new(container_params)
    end

    respond_to do |format|
      if @container.save
        format.html { redirect_to @container, notice: "Container was successfully created." }
        format.json { render :show, status: :created, location: @container }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /containers/1 or /containers/1.json
  def update
    authorize current_user, :update?, policy_class: ContainerPolicy
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to @container, notice: "Container was successfully updated." }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1 or /containers/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: ContainerPolicy
    @container.destroy!

    respond_to do |format|
      format.html { redirect_to containers_path, status: :see_other, notice: "Container was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def generate_excel(containers)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Containers") do |sheet|
      # Add header row
      sheet.add_row [ "Cliente", "Número", "Tipo", "Dueño de la carga", "Entrada", "Salida", "Ubicación" ]

      # Add data rows
      containers.each do |container|
        entrada_move = container.moves.find_by(move_type: "Entrada")
        salida_move = container.moves.find_by(move_type: "Salida")
        # Choose style based on row index (even/odd)

        sheet.add_row [
          container.user.full_name,
          container.number,
          container.container_type,
          container.cargo_owner,
          entrada_move&.created_at&.strftime("%d/%m/%Y"),
          salida_move&.created_at&.strftime("%d/%m/%Y"),
          container.moves.last&.location&.location
        ]
        sheet.add_style "A1:G1", b: true, alignment: { horizontal: :center }, bg_color: "dbeafe", fg_color: "172554"
      end
    end

    package.to_stream.read
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def container_params
      params.require(:container).permit(:user_id, :number, :size, :container_type, :cargo_owner)
    end
end
