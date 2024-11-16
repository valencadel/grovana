class ProductsController < ApplicationController
  before_action :authenticate_user! # Asegura que el usuario esté autenticado
  before_action :set_product, only: [:show, :edit, :update]

  def index
    @products = current_user.companies.first.products
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
      redirect_to @product, notice: 'Producto creado exitosamente.'
    else
      flash.now[:alert] = 'Error al crear el producto.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @product
  end

  def update
    authorize @product

    if @product.update(product_params)
      redirect_to @product, notice: 'Producto actualizado exitosamente.'
    else
      flash.now[:alert] = 'Error al actualizar el producto.'
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = current_user.companies.first.products.find(params[:id])
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
      :status
    )
  end
end
