class MovesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_move, only: %i[ show edit update destroy ]

  # GET /moves or /moves.json
  def index
    authorize current_user, :index?, policy_class: MovePolicy
    per_page = params[:per_page] || 10

    # Base moves query
    @moves = base_move_scope

    # Apply current-day filter if no filters are applied
    apply_current_day_filter! unless filters_applied?

    # Apply additional filters
    apply_filters!

    @moves = @moves.order(created_at: :desc).page(params[:page]).per(per_page)
  end

  # GET /moves/1 or /moves/1.json
  def show
    authorize current_user, :show?, policy_class: MovePolicy
    @container = Container.find(@move.container_id)
  end

  def search_locations
    query = params[:location]
    @available_locations = Location.available.order(location: :asc).where("location ILIKE ?", "%#{query}%").limit(10)

    respond_to do |format|
      format.turbo_stream
      format.html do
        render turbo_frame: "location_list", partial: "moves/location_list",
          locals: { available_locations: @available_locations }
      end
      format.any { head :not_acceptable }
    end
  end
  # GET /moves/new
  def new
    authorize current_user, :create?, policy_class: MovePolicy
    @container = Container.find(params[:container_id])
    @move = Move.new(container_id: @container&.id)
    @previous_move = @container.moves.last
    @current_location = @container.moves.last&.location
    @available_locations = if @current_location
      Location.available.or(Location.where(id: @current_location.id))
      .order(location: :asc)
    else
      Location.available.order(location: :asc)
    end
    if params[:location_id].present?
      @available_locations = Location.where(available: true).or(Location.where(id: params[:location_id]))
    else
      @available_locations = []
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # GET /moves/1/edit
  def edit
    authorize current_user, :update?, policy_class: MovePolicy
    @container = Container.find(@move.container_id)
    @location = Location.find(@move.location_id) if @move.location_id.present?
    @move = Move.find(params[:id])
    @available_locations = Location.where(available: true).or(Location.where(id: @location.id))
    @current_location = @move.location
  end

  # POST /moves or /moves.json
  def create
    authorize current_user, :create?, policy_class: MovePolicy
    @move = Move.new(move_params)
    @container = Container.find(@move.container_id)
    @move.location = Location.find(params[:location_id]) if params[:location_id].present?
    @move.created_by = current_user

    if @move.move_type == "Entrada" && Location.available.exists?(params[:location_id])
       @move.location = Location.find(params[:location_id])
    end

    respond_to do |format|
      if @move.save
        Rails.logger.info "Move saved successfully, sending notification..."
        begin
          send_notification(@move)
        rescue StandardError => e
          puts "Falló la notificacón: #{e.message}"
        end
        format.html { redirect_to @move.container, notice: "Se agregó el movimiento." }
        format.json { render :show, status: :created, location: @move }
      else
        @available_locations = Location.available
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /moves/1 or /moves/1.json
  def update
    authorize current_user, :update?, policy_class: MovePolicy
    @container = Container.find(@move.container_id)
    @location = Location.find(@move.location_id) if @move.location_id.present?
    respond_to do |format|
      if @move.update(move_params)
        format.html { redirect_to @move, notice: "Se actualizó el movimiento." }
        format.json { render :show, status: :ok, location: @move }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /moves/1 or /moves/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: MovePolicy
    @move.destroy!

    respond_to do |format|
      format.html { redirect_to moves_path, status: :see_other, notice: "El movimiento ha sido eliminado." }
      format.json { head :no_content }
    end
  end

  private

  def base_move_scope
    if current_user.role.name == "cliente"
      Move.includes(container: :user).where(containers: { user_id: current_user.id })
    else
      Move.includes(container: :user)
    end
  end

  def apply_current_day_filter!
    @moves = @moves.where(created_at: Date.today.all_day)
  end

  def filters_applied?
    params[:number].present? || params[:move_type].present? ||
    params[:move_created_at].present? || params[:user_id].present?
  end

  def apply_filters!
    filter_by_number if params[:number].present?
    filter_by_move_type if params[:move_type].present?
    filter_by_date_range if params[:from_date].present? && params[:to_date].present?
    filter_by_user if params[:user_id].present?
  end

  def filter_by_move_type
    @moves = @moves.where(move_type: params[:move_type])
  end

  def filter_by_date_range
    from_date = params[:from_date].to_date.beginning_of_day
    to_date = params[:to_date].to_date.end_of_day
    @moves = @moves.where("COALESCE(move_date, created_at) BETWEEN ? AND ?", from_date, to_date)
  end

  def filter_by_user
    @moves = @moves.joins(:container).where(containers: { user_id: params[:user_id] })
  end

  def filter_by_number
    @moves = @moves.joins(:container).where("containers.number ILIKE ?", "%#{params[:number]}%")
  end



  def send_notification(move)
    notification = Notification.new(
      message: "#{move.move_type}-#{move.container.number}",
      completed: false,
      move: move # Associate the notification with the move
    )

    if notification.save
      Rails.logger.info "Notification saved successfully."
    else
      Rails.logger.error "Notification save failed: #{notification.errors.full_messages.join(', ')}"
    end
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_move
      @move = Move.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def move_params
      params.require(:move).permit(:move_date, :created_by, :created_at, :container_id, :move_type, :location_id, :status, :mode, :seal, :notes, images: [])
    end
end
