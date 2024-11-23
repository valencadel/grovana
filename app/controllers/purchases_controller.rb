class PurchasesController < ApplicationController
  before_action :set_purchase, only: [:show, :edit, :update, :destroy]

  def index
    @purchases = Purchase.all
  end

  def show
  end

  def new
    @purchase = Purchase.new
    @products = Product.all
    @suppliers = Supplier.all
  end

  def create
    @purchase = Purchase.new(purchase_params)
    if @purchase.save
      redirect_to @purchase, notice: 'Compra creada exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.all
    @suppliers = Supplier.all
  end

  def update
    if @purchase.update(purchase_params)
      redirect_to @purchase, notice: 'Compra actualizada exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @purchase.destroy
    redirect_to purchases_url, notice: 'Compra eliminada exitosamente.'
  end

  private

  def set_purchase
    @purchase = Purchase.find(params[:id])
  end

  def purchase_params
    params.require(:purchase).permit(
      :order_date,
      :expected_delivery_date,
      :total_price,
      :supplier_id,
      purchase_details_attributes: [:id, :product_id, :quantity, :unit_price, :_destroy]
    )
  end
end
