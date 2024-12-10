class SuppliersController < ApplicationController
  before_action :authenticate_any!
  before_action :set_supplier, only: [ :show, :edit, :update ]

  def index
    @company = if current_user
                current_user.companies.first
    else
                current_employee.company
    end

    @suppliers = @company.suppliers.order(company_name: :asc)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def show
  end

  def new
    @supplier = Supplier.new
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.company = current_user.companies.first

    if @supplier.save
      respond_to do |format|
        format.html { redirect_to @supplier, notice: "Proveedor creado exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Proveedor creado exitosamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      respond_to do |format|
        format.html { redirect_to @supplier, notice: "Proveedor actualizado exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Proveedor actualizado exitosamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def search
    @suppliers = current_company.suppliers
                              .where("name ILIKE ?", "%#{params[:query]}%")
                              .limit(5)
                              .select(:id, :name, :email)

    render json: @suppliers
  end

  private

  def set_supplier
    @supplier = if current_user
                 current_user.companies.first.suppliers.find(params[:id])
    else
                 current_employee.company.suppliers.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to suppliers_path, alert: "Proveedor no encontrado"
  end

  def supplier_params
    params.require(:supplier).permit(:company_name, :contact_name, :email, :phone, :address, :tax_id)
  end
end
