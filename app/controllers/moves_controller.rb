class MovesController < ApplicationController
  before_action :set_move, only: %i[ show edit update destroy ]

  # GET /moves or /moves.json
  def index
    if current_user.role.name == "cliente"
      @moves = Move.joins(:container).where(containers: { user_id: current_user.id }).order(created_at: :desc)
    else
      @moves = Move.order(created_at: :desc)
    end
  end

  # GET /moves/1 or /moves/1.json
  def show
    @container = Container.find(@move.container_id)
  end

  # GET /moves/new
  def new
    @container = Container.find(params[:container_id])
    @move = Move.new(container_id: @container&.id)
  end

  # GET /moves/1/edit
  def edit
    @container = Container.find(@move.container_id)
  end

  # POST /moves or /moves.json
  def create
    @move = Move.new(move_params)
    @container = Container.find(@move.container_id)

    respond_to do |format|
      if @move.save
        format.html { redirect_to @move, notice: "Move was successfully created." }
        format.json { render :show, status: :created, location: @move }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /moves/1 or /moves/1.json
  def update
    respond_to do |format|
      if @move.update(move_params)
        format.html { redirect_to @move, notice: "Move was successfully updated." }
        format.json { render :show, status: :ok, location: @move }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @move.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /moves/1 or /moves/1.json
  def destroy
    @move.destroy!

    respond_to do |format|
      format.html { redirect_to moves_path, status: :see_other, notice: "Move was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_move
      @move = Move.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def move_params
      params.require(:move).permit(:container_id, :move_type, :status, :mode, :seal, :notes, images: [])
    end
end
