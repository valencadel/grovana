class SalesController < ApplicationController
  before_action :authenticate_any!
  before_action :set_sale, only: [:show, :edit, :update, :destroy]
  before_action :set_company_resources, only: [:new, :create, :edit, :update]

  def index
    company_id = current_user&.companies&.first&.id || current_employee&.company_id
    @sales = Sale.joins(:customer)
                 .where(customers: { company_id: company_id })
                 .includes(:customer) # Para evitar N+1 queries
  end

  def show
  end

  def new
    @sale = Sale.new
    @sale.sale_details.build
  end

  def create
    @sale = Sale.new(sale_params)
    if @sale.save
      redirect_to @sale, notice: 'Venta creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @sale.update(sale_params)
      redirect_to @sale, notice: 'Venta actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sale.destroy
    redirect_to sales_url, notice: 'Venta eliminada exitosamente.'
  end

  private

  def set_sale
    company_id = current_user&.companies&.first&.id || current_employee&.company_id
    @sale = Sale.joins(:customer)
                .where(customers: { company_id: company_id })
                .find(params[:id])
  end

  def set_company_resources
    company_id = current_user&.companies&.first&.id || current_employee&.company_id
    @products = Product.where(company_id: company_id)
    @customers = Customer.where(company_id: company_id)
  end

  def sale_params
    params.require(:sale).permit(
      :sale_date,
      :payment_method,
      :customer_id,
      :total_price,
      sale_details_attributes: [:id, :product_id, :quantity, :unit_price, :_destroy]
    )
  end

  def authenticate_any!
    unless current_user || current_employee
      redirect_to root_path, alert: 'Debe iniciar sesión para acceder a esta sección.'
    end
  end
end
