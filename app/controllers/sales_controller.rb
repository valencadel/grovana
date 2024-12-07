class SalesController < ApplicationController
  before_action :authenticate_any!
  before_action :set_sale, only: [ :show, :edit, :update ]
  before_action :set_company_resources, only: [ :new, :create, :edit, :update ]

  def index
    @sales = Sale.joins(:customer)
                 .where(customers: { company_id: current_company.id })
                 .includes(:customer)

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

  def sale_upload
    client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: ENV["GEMINI_API_KEY"]
      },
      options: { model: "gemini-1.5-flash", server_sent_events: true }
    )
    
    result = client.stream_generate_content(
      { contents: [
        { role: 'user', parts: [
          { text: gemini_prompt },
          { inline_data: {
            mime_type: 'image/jpeg',
            data: Base64.strict_encode64(File.read('factura_4.jpg'))
          } }
        ] }
      ] }
    )

    response_text = result.flat_map do |entry|
      entry["candidates"].flat_map do |candidate|
        candidate["content"]["parts"].map { |part| part["text"] }
      end
    end.join

    cleaned_text = response_text.gsub(/```json\s*|\s*```/, '').strip

    begin
      @content = JSON.parse(cleaned_text)
      products_to_process = []
      products_created = 0
      products_updated = 0

      @content["products"].each do |product_data|
        sanitized_sku = sanitize_sku(product_data["SKU"])
        product = Product.find_by(sku: sanitized_sku, company_id: current_company.id)
        
        products_to_process << {
          product: product,
          data: product_data,
          action: product ? :update : :create
        }
      end

      customer = Customer.find_or_create_by!(
        company_id: current_company.id,
        email: "pendiente@ejemplo.com"
      ) do |c|
        c.first_name = @content["company"]
        c.last_name = "Pendiente"
        c.phone = "1181539563"
        c.address = "Pendiente 1234"
        c.tax_id = "1234567890"
      end

      sale = Sale.new(
        sale_date: Date.parse(@content["purchaseDate"]),
        customer_id: customer.id,
        payment_method: "cash",
        total_price: @content["totalPaid"].to_f
      )

      products_to_process.each do |item|
        sale.sale_details.build(
          product_id: item[:product].id,
          quantity: item[:data]["quantity"].to_i,
          unit_price: item[:data]["price"].to_f
        )
      end

      if sale.save
        redirect_to sale_path(sale), 
                    notice: "Proceso completado: #{products_created} productos creados, #{products_updated} productos actualizados"
      else
        raise StandardError.new("Error al crear la venta: #{sale.errors.full_messages.join(', ')}")
      end

    rescue JSON::ParserError => e
      Rails.logger.error "Error parseando JSON: #{e.message}"
      flash.now[:alert] = "Error al procesar la respuesta: formato inválido"
      render :doc_gemini, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Error procesando documento: #{e.message}"
      flash.now[:alert] = "Error al procesar el documento: #{e.message}"
      render :doc_gemini, status: :unprocessable_entity
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

  def gemini_prompt
    @gemini_prompt ||= "Features to Extract:
      # ... (mismo contenido que en pages_controller)
    "
  end

  def sanitize_sku(sku)
    return nil if sku.nil?
    sanitized = sku.to_s.gsub(/[^\w\d]/, '')
    sanitized[0...15]
  end
end
