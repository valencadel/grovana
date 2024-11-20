class SuppliersController < ApplicationController
  before_action :authenticate_any!
  before_action :set_supplier, only: [:show, :edit, :update]

  def index
    @company = if current_user
                current_user.companies.first
              else
                current_employee.company
              end

    @suppliers = @company.suppliers.order(company_name: :asc)
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
      redirect_to suppliers_path, notice: 'Proveedor creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @supplier.update(supplier_params)
      redirect_to suppliers_path, notice: 'Proveedor actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_supplier
    @supplier = if current_user
                 current_user.companies.first.suppliers.find(params[:id])
               else
                 current_employee.company.suppliers.find(params[:id])
               end
  rescue ActiveRecord::RecordNotFound
    redirect_to suppliers_path, alert: 'Proveedor no encontrado'
  end

  def supplier_params
    params.require(:supplier).permit(:company_name, :contact_name, :email, :phone, :address, :tax_id)
  end
end
