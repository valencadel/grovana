require "gemini-ai"
require "base64"
class PagesController < ApplicationController
  skip_before_action :authenticate_any!, only: :home
  before_action :authenticate_any!, only: :dashboard

  def home
  end

  def dashboard
    # Configuración de fechas
    @year_range = Date.current.beginning_of_year..Date.current.end_of_year

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      @date_range = start_date..end_date
      previous_start_date = start_date - 1.month
      previous_end_date = end_date - 1.month
      previous_range = previous_start_date..previous_end_date
      active_range = @date_range
    else
      @date_range = @year_range
      active_range = @year_range
    end

    # Total Customers (lógica condicional)
    if params[:start_date].present? && params[:end_date].present?
      @total_customers = Customer.joins(:sales)
                               .where(company_id: current_company.id)
                               .where(sales: { sale_date: active_range })
                               .distinct
                               .count

      customers_last_month = Customer.joins(:sales)
                                   .where(company_id: current_company.id)
                                   .where(sales: { sale_date: previous_range })
                                   .distinct
                                   .count
        @customers_change = calculate_percentage_change(@total_customers, customers_last_month)
    else
      @total_customers = Customer.where(company_id: current_company.id)
                               .where(created_at: @year_range)
                               .count
      @customers_change = 0
    end

    # Métricas básicas (usando active_range)
    @total_sales = Sale.joins(:customer)
                      .where(customers: { company_id: current_company.id })
                      .where(sale_date: active_range).count

    @total_purchases = Purchase.joins(:supplier)
                               .where(suppliers: { company_id: current_company.id })
                               .where(order_date: active_range).count

    # Montos totales
    @total_sales_amount = Sale.joins(:customer, :sale_details)
                               .where(customers: { company_id: current_company.id })
                               .where(sale_date: active_range)
                               .sum("sale_details.unit_price * sale_details.quantity")

    @total_purchases_amount = Purchase.joins(:supplier, :purchase_details)
                                      .where(suppliers: { company_id: current_company.id })
                                      .where(order_date: active_range)
                                      .sum("purchase_details.unit_price * purchase_details.quantity")

    # Calcular diferencias porcentuales solo si hay filtro de fechas
    if params[:start_date].present? && params[:end_date].present?
      filtered_sales = Sale.joins(:customer)
                          .where(customers: { company_id: current_company.id })
                          .where(sale_date: @date_range).count
      filtered_sales_last_month = Sale.joins(:customer)
                                     .where(customers: { company_id: current_company.id })
                                     .where(sale_date: previous_range).count
      @sales_change = calculate_percentage_change(filtered_sales, filtered_sales_last_month)

      filtered_sales_amount = Sale.joins(:customer, :sale_details)
                                 .where(customers: { company_id: current_company.id })
                                 .where(sale_date: @date_range)
                                 .sum("sale_details.unit_price * sale_details.quantity")
      filtered_sales_amount_last_month = Sale.joins(:customer, :sale_details)
                                            .where(customers: { company_id: current_company.id })
                                            .where(sale_date: previous_range)
                                            .sum("sale_details.unit_price * sale_details.quantity")
      @sales_amount_change = calculate_percentage_change(filtered_sales_amount, filtered_sales_amount_last_month)

      filtered_purchases = Purchase.joins(:supplier)
                                 .where(suppliers: { company_id: current_company.id })
                                 .where(order_date: @date_range).count
      filtered_purchases_last_month = Purchase.joins(:supplier)
                                            .where(suppliers: { company_id: current_company.id })
                                            .where(order_date: previous_range).count
      @purchases_change = calculate_percentage_change(filtered_purchases, filtered_purchases_last_month)

      filtered_purchases_amount = Purchase.joins(:supplier, :purchase_details)
                                        .where(suppliers: { company_id: current_company.id })
                                        .where(order_date: @date_range)
                                        .sum("purchase_details.unit_price * purchase_details.quantity")
      filtered_purchases_amount_last_month = Purchase.joins(:supplier, :purchase_details)
                                                  .where(suppliers: { company_id: current_company.id })
                                                  .where(order_date: previous_range)
                                                  .sum("purchase_details.unit_price * purchase_details.quantity")
      @purchases_amount_change = calculate_percentage_change(filtered_purchases_amount, filtered_purchases_amount_last_month)
    else
      @sales_change = 0
      @purchases_change = 0
      @sales_amount_change = 0
      @purchases_amount_change = 0
    end

    # Gráficos
    @sales_by_month = Sale.joins(:customer, :sale_details)
                          .where(customers: { company_id: current_company.id })
                          .where(sale_date: active_range)
                          .group("DATE_TRUNC('month', sales.sale_date)")
                          .sum("sale_details.unit_price * sale_details.quantity")
                          .transform_keys { |k| k.strftime("%B %Y") }

    @purchases_by_month = Purchase.joins(:supplier, :purchase_details)
                                 .where(suppliers: { company_id: current_company.id })
                                 .where(order_date: active_range)
                                 .group("DATE_TRUNC('month', purchases.order_date)")
                                 .sum("purchase_details.unit_price * purchase_details.quantity")
                                 .transform_keys { |k| k.strftime("%B %Y") }

    # Ventas por método de pago
    @sales_by_payment = Sale.joins(:customer)
                           .where(customers: { company_id: current_company.id })
                           .where(sale_date: active_range)
                           .group(:payment_method)
                           .count
                           .transform_keys do |key|
                             case key
                             when "Efectivo" then "Cash"
                             when "tarjeta_credito" then "Credit Card"
                             when "tarjeta_debito" then "Debit Card"
                             when "transferencia" then "Transfer"
                             else key.to_s.titleize
                             end
                           end

    # Compras por proveedor
    @purchases_by_supplier = Purchase.joins(:supplier, :purchase_details)
                                     .where(suppliers: { company_id: current_company.id })
                                     .where(order_date: active_range)
                                     .group("suppliers.company_name")
                                     .sum("purchase_details.unit_price * purchase_details.quantity")

    # Debugging
    Rails.logger.debug "Filtro activo: #{params[:start_date].present?}"
    Rails.logger.debug "Período: #{active_range}"
    Rails.logger.debug "Total clientes: #{@total_customers}"
  end

  def doc_gemini
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
            data: Base64.strict_encode64(File.read('factura_1.jpg'))
          } }
        ] }
      ] }
    )

    # Extraer y limpiar la respuesta
    response_text = result.flat_map do |entry|
      entry["candidates"].flat_map do |candidate|
        candidate["content"]["parts"].map { |part| part["text"] }
      end
    end.join

    # Limpiar el texto de marcadores JSON y otros caracteres no deseados
    cleaned_text = response_text.gsub(/```json\s*|\s*```/, '').strip

    begin
      @content = JSON.parse(cleaned_text)

      # Crear productos a partir de la respuesta
      @content["products"].each do |product_data|
        product = Product.new(
          sku: sanitize_sku(product_data["SKU"]),
          name: product_data["name"].presence || "Producto sin nombre",
          description: product_data["description"].presence || "Sin descripción",
          category: product_data["category"].presence || "Sin categoría",
          brand: product_data["brand"].presence || "Sin marca",
          price: product_data["price"].to_f,
          stock: product_data["quantity"].to_i || 0,
          min_stock: calculate_min_stock(product_data["quantity"].to_i),
          status: true,
          company_id: current_company.id
        )

        if product.save
          Rails.logger.info "Producto creado exitosamente: #{product.name}"
        else
          Rails.logger.error "Error al crear producto: #{product.errors.full_messages.join(', ')}"
          flash.now[:alert] = "Error al crear producto: #{product.errors.full_messages.join(', ')}"
          return render :doc_gemini, status: :unprocessable_entity
        end
      end

      flash.now[:notice] = "Productos importados exitosamente"
      render :doc_gemini
    rescue JSON::ParserError => e
      Rails.logger.error "Error parseando JSON: #{e.message}"
      Rails.logger.error "Texto recibido: #{cleaned_text}"
      flash.now[:alert] = "Error al procesar la respuesta: formato inválido"
      render :doc_gemini, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error "Error procesando documento: #{e.message}"
      flash.now[:alert] = "Error al procesar el documento: #{e.message}"
      render :doc_gemini, status: :unprocessable_entity
    end
  end

  private

  def calculate_percentage_change(current_value, previous_value)
    return 0 if previous_value.nil? || current_value.nil? || previous_value.zero?

    change = ((current_value.to_f - previous_value.to_f) / previous_value.to_f) * 100
    change.round(1)
  rescue StandardError => e
    Rails.logger.error "Error calculando porcentaje: #{e.message}"
    Rails.logger.error "Valores: actual=#{current_value}, anterior=#{previous_value}"
    0
  end

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
    elsif current_employee
                          current_employee.company
    end
  end

  def gemini_prompt
    @gemini_prompt ||= "Features to Extract:

        1. Product: all the variables of the product. Text
          1.1. name: the name of the product. Text
          1.2. SKU: the alphanumeric identificator of each product. shudnt be longer than 10 to 15 characters and cant have dots, dashes or special characters. numerical value
          1.3. description: the description of the product. Text
          1.4. category: the category of the product. Text
          1.5. brand: the brand of the product. Text
          1.6. price: the price for each unit of the products listed. Numerical value
          1.7. quantity: quantity of each product listed. Numerical value
          1.8. productTotal: the amount paid for each product, given the unit price and the quantity of the products bought. Numeric Value
        2. Name of the seller: name of the company that created the invoice or that is the manufacturer of the products.
        3. totalProducts: the summary of all the products bought. Numerical value.
        4. Total amount paid: Total price of the invoice, the summary of all the items listed. Numerical value.
        5. Date of purchase: date of the purchase. Date value.
        6. Date of delivery: date of the expected delivery. Date value.
        7. Name of company buying: name of the company thats buying the products. Text.

        ---

        Output Format:

        Please output the extracted features as follows:

        products: [
                   SKU: [value]
                   name: [value]
                   description: [value]
                   category: [value]
                   brand: [value]
                   price: [value]
                   quantity: [value]
                   productTotal: [value]
                  ]
        sellerName: [value]
        totalProducts: [value]
        totalPaid: [value]
        purchaseDate: [value]
        deliveryDate: [value]
        company: [value]

       inside products, i should have the SKU, the unit price, the quantity, and the total amount

        For example:

        SKU: MACBK0001
        products: computadora MacBook Pro M3-Pro 16GB RAM 512SSD
        sellerName: Company S.R.L.
        unitPrice: 10.000,00
        quantity: 10
        productTotal: 100.000,00
        totalProducts: 35
        totalPaid: 1.500.000,00
        purchaseDate: 2024-11-07
        deliveryDate: 2025-02-17
        company: valentin cadel S.A.

        ---

        Important:

        - Do not include any explanations, reasoning, code, or additional text. Just include the result in the format specified above.
        - Do not include the media description again in the output.
        - Respond **ONLY** with the results for each feature on a new line, in a json format"
  end

  def calculate_min_stock(quantity)
    return 1 if quantity.nil? || quantity <= 0
    
    case quantity
    when 1..10
      1
    when 11..50
      5
    when 51..100
      10
    else
      (quantity * 0.1).round # 10% del stock inicial
    end
  end

  def sanitize_sku(sku)
    return nil if sku.nil?
    
    # Eliminar caracteres especiales y espacios
    sanitized = sku.to_s.gsub(/[^\w\d]/, '')
    
    # Limitar longitud a 15 caracteres
    sanitized[0...15]
  end
end
