class PurchasesController < ApplicationController
  before_action :authenticate_any!
  before_action :set_purchase, only: [ :show, :edit, :update, :destroy ]
  before_action :set_company_resources, only: [ :new, :create, :edit, :update ]

  def index
    @purchases = Purchase.joins(:supplier)
                        .where(suppliers: { company_id: current_company.id })
                        .includes(:supplier)

    @purchases = @purchases.order(order_date: :desc)
    respond_to do |format|
      format.html
      format.xlsx
    end
  end

  def show
  end

  def new
    @purchase = Purchase.new
    @purchase.order_date = Date.today
  end

  def create
    @purchase = Purchase.new(purchase_params)
    @purchase.supplier = Supplier.find(params[:purchase][:supplier_id])
    @purchase.company = current_user.companies.first

    if @purchase.save
      respond_to do |format|
        format.html { redirect_to @purchase, notice: "Compra creada exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Compra creada exitosamente." }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @purchase.update(purchase_params)
      respond_to do |format|
        format.html { redirect_to @purchase, notice: "Compra actualizada exitosamente." }
        format.turbo_stream { flash.now[:notice] = "Compra actualizada exitosamente." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @purchase.destroy!
    respond_to do |format|
      format.html { redirect_to purchases_url notice: "Compra eliminada exitosamente.", status: :see_other }
      # format.turbo_stream { redirect_to purchases_url, notice: "Compra eliminada exitosamente." }
      format.turbo_stream
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
    @products = Product.where(company_id: current_company.id)
                      .active
                      .select(:id, :name, :price, :category)

    # Debugging
    puts "\n=== Productos y sus precios ==="
    @products.each do |product|
      puts "#{product.name}: $#{product.price}"
    end
    puts "============================\n"

    @suppliers = Supplier.where(company_id: current_company.id)
  end

  def set_purchase
    @purchase = Purchase.joins(:supplier)
                       .where(suppliers: { company_id: current_company.id })
                       .includes(purchase_details: :product)
                       .find_by(id: params[:id])

    unless @purchase
      redirect_to purchases_url, alert: "Compra no encontrada."
    end
  end

  def purchase_params
    params.require(:purchase).permit(
      :order_date,
      :expected_delivery_date,
      :supplier_id,
      :total_price,
      purchase_details_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
    )
  end

  def authenticate_any!
    unless current_user || current_employee
      redirect_to root_path, alert: "Debe iniciar sesión para acceder a esta sección."
    end
  end
end
