class SalesController < ApplicationController
  before_action :authenticate_any!
  before_action :set_sale, only: [ :show, :edit, :update ]
  before_action :set_company_resources, only: [ :new, :create, :edit, :update ]

  def index
    @sales = Sale.joins(:customer)
                 .where(customers: { company_id: current_company.id })
                 .includes(:customer)

    @sales = @sales.order(sale_date: :desc)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def show
  end

  def new
    @sale = Sale.new
    @sale.sale_date = Date.today
  end

  def edit
  end

  def create
    @sale = Sale.new(sale_params)
    @sale.customer = Customer.find(params[:sale][:customer_id])

    if @sale.save
      respond_to do |format|
        format.html { redirect_to @sale, notice: "Venta creada exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Venta creada exitosamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @sale.update(sale_params)
      respond_to do |format|
        format.html { redirect_to @sale, notice: "Venta actualizada exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Venta actualizada exitosamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
    elsif current_employee
                          current_employee.company
    end
  end

  def set_company_resources
    @products = Product.where(company_id: current_company.id).active
    @customers = Customer.where(company_id: current_company.id)
  end

  def set_sale
    @sale = Sale.joins(:customer)
                .where(customers: { company_id: current_company.id })
                .includes(sale_details: :product)
                .find_by(id: params[:id])

    unless @sale
      redirect_to sales_url, alert: "Venta no encontrada."
    end
  end

  def sale_params
    params.require(:sale).permit(
      :sale_date,
      :payment_method,
      :customer_id,
      :total_price,
      sale_details_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
    )
  end

  def authenticate_any!
    unless current_user || current_employee
      redirect_to root_path, alert: "Debe iniciar sesión para acceder a esta sección."
    end
  end
end
