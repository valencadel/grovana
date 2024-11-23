class ProductsController < ApplicationController
  before_action :authenticate_any!
  before_action :set_product, only: [ :show, :edit, :update, :price ]

  def index
    company_id = current_user&.companies&.first&.id || current_employee&.company_id
    @products = Product.where(company_id: company_id)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def show
    authorize @product
  end

  def new
    @product = Product.new
    authorize @product
  end

  def create
    @product = Product.new(product_params)
    @product.company = current_user.companies.first
    authorize @product

    if @product.save
      redirect_to @product, notice: "Producto creado exitosamente."
    else
      flash.now[:alert] = "Error al crear el producto."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product

    if @product.update(product_params)
      redirect_to @product, notice: "Producto actualizado exitosamente."
    else
      flash.now[:alert] = "Error al actualizar el producto."
      render :edit, status: :unprocessable_entity
    end
  end

  def price
    authorize @product
    render json: {
      price: @product.price,
      stock: @product.stock
    }
  end

  private

  def set_product
    company_id = current_user&.companies&.first&.id || current_employee&.company_id
    @product = Product.where(company_id: company_id).find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :description,
      :category,
      :stock,
      :min_stock,
      :brand,
      :status,
      :price
    )
  end
end
