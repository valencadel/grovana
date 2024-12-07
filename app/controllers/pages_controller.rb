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

    @markers = Customer.where(company_id: current_company.id)
                      .geocoded
                      .map do |customer|
      {
        lat: customer.latitude,
        lng: customer.longitude,
        info_window_html: render_to_string(
          partial: "customers/map_info_window",
          locals: { customer: customer }
        ),
        marker_html: render_to_string(
          partial: "customers/map_marker"
        )
      }
    end
  end

  def doc_gemini
    @upload = Upload.find(params[:id])
    # @upload = Upload.new
    begin
      @content = @upload.gemini(gemini_prompt)
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

      products_to_process.each do |item|
        if item[:action] == :update
          new_stock = item[:product].stock + item[:data]["quantity"].to_i
          if item[:product].update(stock: new_stock)
            products_updated += 1
            Rails.logger.info "Producto actualizado: #{item[:product].name}, Nuevo stock: #{new_stock}"
          else
            raise StandardError.new("Error actualizando producto: #{item[:product].errors.full_messages.join(', ')}")
          end
        else
          new_product = Product.new(
            sku: sanitize_sku(item[:data]["SKU"]),
            name: item[:data]["name"].presence || "Producto sin nombre",
            description: item[:data]["description"].presence || "Sin descripción",
            category: item[:data]["category"].presence || "Sin categoría",
            brand: item[:data]["brand"].presence || "Sin marca",
            price: item[:data]["price"].to_f,
            stock: item[:data]["quantity"].to_i || 0,
            min_stock: calculate_min_stock(item[:data]["quantity"].to_i),
            status: true,
            company_id: current_company.id
          )

          if new_product.save
            products_created += 1
            item[:product] = new_product
            Rails.logger.info "Producto creado: #{new_product.name}"
          else
            raise StandardError.new("Error creando producto: #{new_product.errors.full_messages.join(', ')}")
          end
        end
      end

      supplier = Supplier.find_or_create_by!(
        company_name: @content["sellerName"],
        company_id: current_company.id
      ) do |s|
        s.contact_name = "Pendiente"
        s.email = "pendiente@ejemplo.com"
        s.phone = "1181539563"
        s.address = "Pendiente 1234"
        s.tax_id = "1234567890"
      end

      purchase = Purchase.new(
        order_date: Date.parse(@content["purchaseDate"]),
        expected_delivery_date: Date.parse(@content["deliveryDate"]),
        supplier_id: supplier.id,
        company_id: current_company.id,
        total_price: @content["totalPaid"].to_f
      )

      products_to_process.each do |item|
        purchase.purchase_details.build(
          product_id: item[:product].id,
          quantity: item[:data]["quantity"].to_i,
          unit_price: item[:data]["price"].to_f
        )
      end

      if purchase.save
        redirect_to purchase_path(purchase),
                    notice: "Proceso completado: #{products_created} productos creados, #{products_updated} productos actualizados"
      else
        raise StandardError.new("Error al crear la compra: #{purchase.errors.full_messages.join(', ')}")
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
          { text: gemini_prompt_sales },
          { inline_data: {
            mime_type: 'image/jpeg',
            data: Base64.strict_encode64(File.read('boleta_1.jpg'))
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
      customer_created = false

      @content["products"].each do |product_data|
        sanitized_sku = sanitize_sku(product_data["SKU"])
        product = Product.find_by(sku: sanitized_sku, company_id: current_company.id)
        
        products_to_process << {
          product: product,
          data: product_data,
          action: product ? :update : :create
        }
      end

      customer = Customer.where(company_id: current_company.id)
                        .where("LOWER(email) = ? OR LOWER(CONCAT(first_name, ' ', last_name)) = ?",
                              @content["customer"]["email"].to_s.downcase,
                              @content["company"].to_s.downcase)
                        .first

      if customer.nil?
        customer = Customer.create!(
          company_id: current_company.id,
          first_name: @content["customer"]["firstName"],
          last_name: @content["customer"]["lastName"],
          email: @content["customer"]["email"],
          phone: @content["customer"]["phone"],
          address: @content["customer"]["address"],
          tax_id: @content["customer"]["taxId"] || "Pendiente"
        )
        customer_created = true
      end

      sale = Sale.new(
        sale_date: Date.parse(@content["purchaseDate"]),
        customer_id: customer.id,
        payment_method: @content["paymentMethod"],
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
        notice_message = customer_created ? 
          "Venta creada exitosamente para nuevo cliente: #{customer.first_name} #{customer.last_name}" : 
          "Venta creada exitosamente para cliente existente: #{customer.first_name} #{customer.last_name}"
        redirect_to sale_path(sale), notice: notice_message
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

  def gemini_prompt_sales
    @gemini_prompt_sales ||= "Features to Extract:

        1. Product: all the variables of the product. Text
          1.1. name: the name of the product. Text
          1.2. SKU: the alphanumeric identificator of each product. shouldnt be longer than 10 to 15 characters and cant have dots, dashes or special characters. numerical value
          1.3. description: the description of the product. Text
          1.4. category: the category of the product. Text
          1.5. brand: the brand of the product. Text
          1.6. price: the price for each unit of the products listed. Numerical value
          1.7. quantity: quantity of each product listed. Numerical value
          1.8. productTotal: the amount paid for each product, given the unit price and the quantity of the products bought. Numeric Value
        2. Customer: all the variables of the customer
          2.1. First Name: name of the person that bought the products. Text
          2.2. Last Name: last name of the person that bought the products. Text
          2.3. Email: email of the person that bought the products. Text
          2.4. Phone: phone of the person that bought the products. Text
          2.5. Address: address of the person that bought the products. Text
        3. Payment Method: method of payment of the invoice. Text. If the payment method is Cash return cash, if the payment method is Credit Card return credit_card, if the payment method is Transfer return transfer
        4. totalProducts: the summary of all the products sold. Numerical value.
        5. Total amount sold: Total price of the invoice, the summary of all the items listed. Numerical value.
        6. Date of purchase: date of the purchase. Date value.

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
        customer: {
          firstName: [value]
          lastName: [value]
          email: [value]
          phone: [value]
          address: [value]
        }
        paymentMethod: [value]
        totalProducts: [value]
        totalPaid: [value]
        purchaseDate: [value]
        deliveryDate: [value]
        company: [value]

       inside products, i should have the SKU, the unit price, the quantity, and the total amount

        For example:

        SKU: MACBK0001
        products: computadora MacBook Pro M3-Pro 16GB RAM 512SSD
        unitPrice: 10.000,00
        quantity: 10
        productTotal: 100.000,00
        totalProducts: 35
        totalPaid: 1.500.000,00
        customer: 
          First Name: John
          Last Name: Doe
          Email: john.doe@example.com
          Phone: 1234567890
          Address: 1234 Main St, Anytown, USA
        paymentMethod: cash
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
    sanitized = sku.to_s.gsub(/[^\w\d]/, "")
    sanitized[0...15]
  end
end
