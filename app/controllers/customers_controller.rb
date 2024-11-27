class CustomersController < ApplicationController
  before_action :authenticate_any!
  before_action :set_customer, only: [:show, :edit, :update]

  def index
    @customers = Customer.where(company_id: current_company.id)
                        .order(:first_name)
    @total_customers = @customers.size
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def show
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    @customer.company =  current_company
    if @customer.save
      respond_to do |format|
        format.html { redirect_to @customer, notice: "Cliente creado exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Cliente creado exitosamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      respond_to do |format|
        format.html { redirect_to @customer, notice: "Cliente actualizado exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Cliente actualizado exitosamente." }
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

  def set_customer
    @customer = Customer.where(company_id: current_company.id)
                       .find_by(id: params[:id])

    unless @customer
      redirect_to customers_url, alert: 'Cliente no encontrado.'
    end
  end

  def customer_params
    params.require(:customer).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :address,
      :tax_id
    )
  end
  def authenticate_any!
    unless current_user || current_employee
      redirect_to root_path, alert: "Debe iniciar sesión para acceder a esta sección."
    end
  end
end
