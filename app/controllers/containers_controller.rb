class ContainersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_container, only: %i[ show edit update destroy create_invoice_container_services ]

  def create_invoice_container_services
    authorize current_user, :create_invoice_container_services?, policy_class: ContainerPolicy
    services = @container.services.where(invoiced: false)

    if services.any?
      invoice = Invoice.new(
        user: @container.user,
        container: @container,
        total: services.sum(&:charge),
        status: "Pendiente",
        issue_date: Date.today,
        due_date: Date.today + 30.days
      )

      if invoice.save
        services.each { |service| service.update(invoice: invoice, invoiced: true) }
        flash[:notice] = "Factura creada exitosamente."
        redirect_to invoice_path(invoice)
      else
        flash[:alert] = "No se pudo crear la factura: #{invoice.errors.full_messages.join(', ')}"
      end
    else
      flash[:alert] = "No se encontraron servicios pendientes para facturar."
      redirect_to @container
    end
  end
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
    @services = @container.services.includes(:invoice)
    @eirs = @container.eirs.order(created_at: :desc)
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
        format.html { redirect_to @container, notice: "Contenedor creado exitosamente." }
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
        format.html { redirect_to @container, notice: "Contenedor actualizado exitosamente." }
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
    if @container.invoices.exists? || Service.where(container_id: @container.id, invoiced: true).exists?
      redirect_to @container, alert: "Debe eliminar la factura antes de eliminar el contenedor."
      return
    end
    if @container.destroy
      respond_to do |format|
        format.html { redirect_to containers_path, status: :see_other, notice: "Contenedor eliminado exitosamente." }
        format.json { head :no_content }
      end
    else
      redirect_to containers_path, alert: @container.errors.full_messages.join(", ")
    end
  end

  private

  def base_container_scope
    if current_user.role.name == "cliente"
      # Container.where(user_id: current_user.id)
      # current_user.containers.includes(:user, :eirs, moves: :location)
      Container.includes(:user, :eirs, moves: :location).where(user_id: current_user.id)
    else
      # Container.all.includes(:moves)
      # Container.includes(:moves, :eirs, :user)
      Container.includes(:user, :eirs, moves: :location)
    end
  end

  def apply_filters!
    filter_by_date if params[:from].present? && params[:to].present?
    filter_by(:container_type, "container_type")
    filter_by(:number, "number")
    filter_by(:cargo_owner, "cargo_owner")
    filter_by_move_type if params[:move_type].present?
    filter_by_user if params[:user_id].present?
    filter_by_in_yard if params[:in_yard] == "1"
  end

  def filter_by_in_yard
    @containers = @containers
    .joins(:moves)
    .where(moves: { move_type: "Entrada" })
    .where.not(id: Container.joins(:moves).where(moves: { move_type: "Salida" }))
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

    # Define styles
    left_align_style = workbook.styles.add_style(alignment: { horizontal: :left })
    header_style_centered_blue = workbook.styles.add_style(b: true, alignment: { horizontal: :center }, bg_color: "dbeafe", fg_color: "172554")
    header_style_centered_green = workbook.styles.add_style(b: true, alignment: { horizontal: :center }, bg_color: "bee3db", fg_color: "2f855a")
    header_style_centered_yellow = workbook.styles.add_style(b: true, alignment: { horizontal: :center }, bg_color: "fde68a", fg_color: "b7791f")

    workbook.add_worksheet(name: "Containers") do |sheet|
      # Add header row with styles
      sheet.add_row [ "Cliente", "Número", "Tipo", "Tamaño", "Carga", "Dueño de la Carga", "Entrada", "EIR", "Operador", "Placas", "Salida", "EIR", "Operador", "Placas", "Reacomodo", "Lavado", "Traspaleo", "Ubicación" ],
                    style: [ header_style_centered_blue ] * 6 + [ header_style_centered_green ] * 4 + [ header_style_centered_yellow ] * 4 + [ header_style_centered_blue ] * 4

      # Add data rows
      containers.each do |container|
        entrada_move = container.moves.find_by(move_type: "Entrada")
        salida_move = container.moves.find_by(move_type: "Salida")
        reacomodo_move = container.moves.find_by(move_type: "Reacomodo")
        lavado_move = container.moves.find_by(move_type: "Lavado")
        traspaleo_move = container.moves.find_by(move_type: "Traspaleo")

        # Add data row with left-aligned integer columns
        row = [
          container.user.full_name,
          container.number,
          container.container_type,
          container.size,
          container.moves.last&.status,
          container.cargo_owner,
          entrada_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y %H:%M"),
          container.eirs&.first&.id,
          container.eirs&.first&.operator,
          container.eirs&.first&.plate,
          salida_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y %H:%M"),
          container.eirs&.last&.id,
          container.eirs&.last&.operator,
          container.eirs&.last&.plate,
          reacomodo_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y %H:%M"),
          lavado_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y %H:%M"),
          traspaleo_move&.created_at&.in_time_zone("America/Mexico_City")&.strftime("%d/%m/%Y %H:%M"),
          current_user.role.name != "cliente" ? container.moves.last&.location&.location : nil
        ]

        # Apply left alignment to integer columns (like container number, EIR IDs)
        sheet.add_row row, style: [
          nil, left_align_style, nil, left_align_style, nil, nil, # Align container number, size to the left
          nil, left_align_style, nil, nil,                       # Align EIR ID (Entrada) to the left
          nil, left_align_style, nil, nil,                       # Align EIR ID (Salida) to the left
          nil, nil, nil, nil                                    # Remaining columns as is
        ]
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
