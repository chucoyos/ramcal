class PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_permission, only: %i[ show edit update destroy ]

  # GET /permissions or /permissions.json
  def index
    authorize current_user, :index?, policy_class: PermissionPolicy
    @permissions = Permission.all
  end

  # GET /permissions/1 or /permissions/1.json
  def show
    authorize current_user, :show?, policy_class: PermissionPolicy
  end

  # GET /permissions/new
  def new
    authorize current_user, :create?, policy_class: PermissionPolicy
    @permission = Permission.new
  end

  # GET /permissions/1/edit
  def edit
    authorize current_user, :update?, policy_class: PermissionPolicy
  end

  # POST /permissions or /permissions.json
  def create
    authorize current_user, :create?, policy_class: PermissionPolicy
    @permission = Permission.new(permission_params)

    respond_to do |format|
      if @permission.save
        format.html { redirect_to @permission, notice: "El permiso ha sido creado." }
        format.json { render :show, status: :created, location: @permission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permissions/1 or /permissions/1.json
  def update
    authorize current_user, :update?, policy_class: PermissionPolicy
    respond_to do |format|
      if @permission.update(permission_params)
        format.html { redirect_to @permission, notice: "Se actualizó el permiso." }
        format.json { render :show, status: :ok, location: @permission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permissions/1 or /permissions/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: PermissionPolicy
    if @permission.roles.any?
      flash[:alert] = "No se puede eliminar permisos con roles asignados."
      redirect_to permissions_path
    else
      @permission.destroy!

      respond_to do |format|
        format.html { redirect_to permissions_path, status: :see_other, notice: "El permiso ha sido eliminado." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permission
      @permission = Permission.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def permission_params
      params.require(:permission).permit(:name)
    end
end
