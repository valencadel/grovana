class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [ :show, :edit, :update ]

  def index
    @customers = Customer.all
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
    if @customer.save
      redirect_to @customer, notice: "Cliente creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Cliente actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :phone, :address, :tax_id)
  end
end
