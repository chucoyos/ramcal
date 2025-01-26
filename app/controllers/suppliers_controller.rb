class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[ show edit update destroy ]

  # GET /suppliers or /suppliers.json
  def index
    authorize current_user, :index?, policy_class: SupplierPolicy
    @suppliers = Supplier.all
  end

  # GET /suppliers/1 or /suppliers/1.json
  def show
    authorize current_user, :show?, policy_class: SupplierPolicy
  end

  # GET /suppliers/new
  def new
    authorize current_user, :create?, policy_class: SupplierPolicy
    @supplier = Supplier.new
  end

  # GET /suppliers/1/edit
  def edit
    authorize current_user, :update?, policy_class: SupplierPolicy
  end

  # POST /suppliers or /suppliers.json
  def create
    authorize current_user, :create?, policy_class: SupplierPolicy
    @supplier = Supplier.new(supplier_params)

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to @supplier, notice: "Supplier was successfully created." }
        format.json { render :show, status: :created, location: @supplier }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suppliers/1 or /suppliers/1.json
  def update
    authorize current_user, :update?, policy_class: SupplierPolicy
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to @supplier, notice: "Supplier was successfully updated." }
        format.json { render :show, status: :ok, location: @supplier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suppliers/1 or /suppliers/1.json
  def destroy
    authorize current_user, :destroy?, policy_class: SupplierPolicy
    @supplier.destroy!

    respond_to do |format|
      format.html { redirect_to suppliers_path, status: :see_other, notice: "Supplier was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def supplier_params
      params.require(:supplier).permit(:name, :contact, :phone, :email)
    end
end
