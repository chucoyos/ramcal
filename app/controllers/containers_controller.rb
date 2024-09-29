class ContainersController < ApplicationController
  before_action :set_container, only: %i[ show edit update destroy ]

  # GET /containers or /containers.json
  def index
    authorize current_user, :index?, policy_class: ContainerPolicy
    @containers = Container.all
  end

  # GET /containers/1 or /containers/1.json
  def show
    authorize current_user, :show?, policy_class: ContainerPolicy
  end

  # GET /containers/new
  def new
    authorize current_user, :create?, policy_class: ContainerPolicy
    @container = Container.new
  end

  # GET /containers/1/edit
  def edit
    authorize current_user, :update?, policy_class: ContainerPolicy
  end

  # POST /containers or /containers.json
  def create
    authorize current_user, :create?, policy_class: ContainerPolicy
    @container = Container.new(container_params)

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
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def container_params
      params.require(:container).permit(:user_id, :number, :size, :container_type, :cargo_owner)
    end
end
