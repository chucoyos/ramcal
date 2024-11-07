class ContainersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_container, only: %i[ show edit update destroy ]

  # GET /containers or /containers.json
  def index
    authorize current_user, :index?, policy_class: ContainerPolicy
    per_page = params[:per_page] || 10
    @containers = base_container_scope

    apply_filters!

    @containers = @containers.order(created_at: :desc).page(params[:page]).per(per_page)

    respond_to do |format|
      format.html # Render the regular HTML view
      format.xlsx do
        # Render Excel using Axlsx
        send_data generate_excel(@containers),
                  filename: "containers_#{Date.today}.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                  disposition: "attachment"
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

  def base_container_scope
    if current_user.role.name == "cliente"
      Container.where(user_id: current_user.id)
    else
      Container.all
    end
  end

  def apply_filters!
    filter_by_date if params[:from].present? && params[:to].present?
    filter_by(:container_type, "container_type")
    filter_by(:number, "number")
    filter_by(:cargo_owner, "cargo_owner")
    filter_by_move_type if params[:move_type].present?
    filter_by_user if params[:user_id].present?
  end

  def filter_by_date
    from_date = params[:from].to_date.beginning_of_day
    to_date = params[:to].to_date.end_of_day
    @containers = @containers.where(created_at: from_date..to_date)
  end

  def filter_by(param_name, column_name)
    value = params[param_name]
    @containers = @containers.where("#{column_name} ILIKE ?", "%#{value}%") if value.present?
  end

  def filter_by_move_type
    @containers = @containers.joins(:moves)
                             .where("moves.move_type ILIKE ?", "%#{params[:move_type]}%")
  end

  def filter_by_user
    @containers = @containers.where(user_id: params[:user_id])
  end

  def generate_excel(containers)
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: "Containers") do |sheet|
      # Add header row
      sheet.add_row [ "Cliente", "Número", "Tipo", "Carga", "Dueño de la Carga", "Entrada", "Salida", "Ubicación" ]

      # Add data rows
      containers.each do |container|
        entrada_move = container.moves.find_by(move_type: "Entrada")
        salida_move = container.moves.find_by(move_type: "Salida")
        # Choose style based on row index (even/odd)

        sheet.add_row [
          container.user.full_name,
          container.number,
          container.container_type,
          container.moves.last&.status,
          container.cargo_owner,
          entrada_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y"),
          salida_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y"),
          current_user.role.name != "cliente" ? container.moves.last&.location&.location : nil
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
