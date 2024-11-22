class SalesController < ApplicationController
  before_action :set_sale, only: [:show, :edit, :update, :destroy]

  def index
    @sales = Sale.all
  end

  def show
  end

  def new
    @sale = Sale.new
    @sale.sale_details.build
    @products = Product.all
    @customers = Customer.all
  end

  def create
    @sale = Sale.new(sale_params)
    if @sale.save
      redirect_to @sale, notice: 'Venta creada exitosamente.'
    else
      @products = Product.all
      @customers = Customer.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.all
    @customers = Customer.all
  end

  def update
    if @sale.update(sale_params)
      redirect_to @sale, notice: 'Venta actualizada exitosamente.'
    else
      @products = Product.all
      @customers = Customer.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sale.destroy
    redirect_to sales_url, notice: 'Venta eliminada exitosamente.'
  end

  private

  def set_sale
    @sale = Sale.find(params[:id])
  end

  def sale_params
    params.require(:sale).permit(
      :sale_date,
      :payment_method,
      :customer_id,
      :total_price,
      sale_details_attributes: [
        :id,
        :product_id,
        :quantity,
        :unit_price,
        :_destroy
      ]
    )
  end
end
