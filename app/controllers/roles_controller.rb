class RolesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_role, only: %i[ show edit update destroy ]

  # GET /roles or /roles.json
  def index
    authorize current_user, :index?, policy_class: RolePolicy
    @roles = Role.all
  end

  # GET /roles/1 or /roles/1.json
  def show
    authorize current_user, :show?, policy_class: RolePolicy
  end

  # GET /roles/new
  def new
    authorize current_user, :create?, policy_class: RolePolicy
    @role = Role.new
    @permissions = Permission.all
  end

  # GET /roles/1/edit
  def edit
    authorize current_user, :update?, policy_class: RolePolicy
    @permissions = Permission.all
  end

  # POST /roles or /roles.json
  def create
    authorize current_user, :create?, policy_class: RolePolicy
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to @role, notice: "El rol ha sido creado." }
        format.json { render :show, status: :created, location: @role }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /roles/1 or /roles/1.json
  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to @role, notice: "El rol ha sido actualizado." }
        format.json { render :show, status: :ok, location: @role }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1 or /roles/1.json
  def destroy
    if @role.users.any?
      flash[:alert] = "No se puede eliminar el rol con usuarios asignados."
      redirect_to roles_path
    else
      @role.destroy!
      respond_to do |format|
        format.html { redirect_to roles_path, status: :see_other, notice: "El rol fue eliminado." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_role
      @role = Role.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def role_params
      params.require(:role).permit(:name, permission_ids: [])
    end
end
