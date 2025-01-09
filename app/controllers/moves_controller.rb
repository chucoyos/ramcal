class MovesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_move, only: %i[ show edit update destroy ]

  # GET /moves or /moves.json
  def index
    authorize current_user, :index?, policy_class: MovePolicy
    if current_user.role.name == "cliente"
      # @moves = Move.joins(:container).where(containers: { user_id: current_user.id }).order(created_at: :desc).page(params[:page]).per(10)
      @moves = Move.includes(container: :user).where(containers: { user_id: current_user.id }).order(created_at: :desc).page(params[:page]).per(10)
    else
      # @moves = Move.order(created_at: :desc).page(params[:page]).per(10)
      @moves = Move.includes(container: :user).order(created_at: :desc).page(params[:page]).per(10)
    end
    if params[:number].present?
      @moves = @moves.joins(:container).where("containers.number ILIKE ?", "%#{params[:number]}%").page(params[:page]).per(10)
    end
    if params[:move_type].present? && params[:move_created_at].present?
      @moves = @moves.joins(:container).where(move_type: params[:move_type]).where("moves.created_at::date = ?", params[:move_created_at].to_date).page(params[:page]).per(10)
    end
    if params[:user_id].present?
      @moves = @moves.joins(:container).where(containers: { user_id: params[:user_id] }).page(params[:page]).per(10)
    end
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
      params.require(:move).permit(:created_by, :created_at, :container_id, :move_type, :location_id, :status, :mode, :seal, :notes, images: [])
    end
end
