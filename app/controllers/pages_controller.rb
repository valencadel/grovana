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
      active_range = @date_range  # Usar el rango filtrado
    else
      @date_range = @year_range
      active_range = @year_range  # Usar el rango del año completo
    end

    # Métricas básicas (responden al filtro)
    @total_customers = Customer.where(company_id: current_company.id)
                               .where(created_at: active_range).count

    @total_sales = Sale.joins(:customer)
                      .where(customers: { company_id: current_company.id })
                      .where(sale_date: active_range).count

    @total_purchases = Purchase.joins(:supplier)
                               .where(suppliers: { company_id: current_company.id })
                               .where(order_date: active_range).count

    # Montos totales (responden al filtro)
    @total_sales_amount = Sale.joins(:customer, :sale_details)
                               .where(customers: { company_id: current_company.id })
                               .where(sale_date: active_range)
                               .sum('sale_details.unit_price * sale_details.quantity')

    @total_purchases_amount = Purchase.joins(:supplier, :purchase_details)
                                      .where(suppliers: { company_id: current_company.id })
                                      .where(order_date: active_range)
                                      .sum('purchase_details.unit_price * purchase_details.quantity')

    # Calcular diferencias porcentuales solo si hay filtro de fechas
    if params[:start_date].present? && params[:end_date].present?
      # Customers
      filtered_customers = Customer.where(company_id: current_company.id)
                                 .where(created_at: @date_range).count
      filtered_customers_last_month = Customer.where(company_id: current_company.id)
                                            .where(created_at: previous_range).count
      @customers_change = calculate_percentage_change(filtered_customers, filtered_customers_last_month)

      # Sales
      filtered_sales = Sale.joins(:customer)
                          .where(customers: { company_id: current_company.id })
                          .where(sale_date: @date_range).count
      filtered_sales_last_month = Sale.joins(:customer)
                                     .where(customers: { company_id: current_company.id })
                                     .where(sale_date: previous_range).count
      @sales_change = calculate_percentage_change(filtered_sales, filtered_sales_last_month)

      # Sales Amount
      filtered_sales_amount = Sale.joins(:customer, :sale_details)
                                 .where(customers: { company_id: current_company.id })
                                 .where(sale_date: @date_range)
                                 .sum('sale_details.unit_price * sale_details.quantity')
      filtered_sales_amount_last_month = Sale.joins(:customer, :sale_details)
                                            .where(customers: { company_id: current_company.id })
                                            .where(sale_date: previous_range)
                                            .sum('sale_details.unit_price * sale_details.quantity')
      @sales_amount_change = calculate_percentage_change(filtered_sales_amount, filtered_sales_amount_last_month)

      # Purchases
      filtered_purchases = Purchase.joins(:supplier)
                                 .where(suppliers: { company_id: current_company.id })
                                 .where(order_date: @date_range).count
      filtered_purchases_last_month = Purchase.joins(:supplier)
                                            .where(suppliers: { company_id: current_company.id })
                                            .where(order_date: previous_range).count
      @purchases_change = calculate_percentage_change(filtered_purchases, filtered_purchases_last_month)

      # Purchases Amount
      filtered_purchases_amount = Purchase.joins(:supplier, :purchase_details)
                                        .where(suppliers: { company_id: current_company.id })
                                        .where(order_date: @date_range)
                                        .sum('purchase_details.unit_price * purchase_details.quantity')
      filtered_purchases_amount_last_month = Purchase.joins(:supplier, :purchase_details)
                                                  .where(suppliers: { company_id: current_company.id })
                                                  .where(order_date: previous_range)
                                                  .sum('purchase_details.unit_price * purchase_details.quantity')
      @purchases_amount_change = calculate_percentage_change(filtered_purchases_amount, filtered_purchases_amount_last_month)

      # Debugging
      Rails.logger.debug "Filtered Purchases: #{filtered_purchases}, Last Month: #{filtered_purchases_last_month}, Change: #{@purchases_change}%"
      Rails.logger.debug "Filtered Purchases Amount: #{filtered_purchases_amount}, Last Month: #{filtered_purchases_amount_last_month}, Change: #{@purchases_amount_change}%"
    else
      # Inicializar todos los cambios porcentuales a 0 cuando no hay filtro
      @customers_change = 0
      @sales_change = 0
      @purchases_change = 0
      @sales_amount_change = 0
      @purchases_amount_change = 0
    end

    # Gráficos (responden al filtro)
    @sales_by_month = Sale.joins(:customer, :sale_details)
                          .where(customers: { company_id: current_company.id })
                          .where(sale_date: active_range)
                          .group("DATE_TRUNC('month', sales.sale_date)")
                          .sum('sale_details.unit_price * sale_details.quantity')
                          .transform_keys { |k| k.strftime("%B %Y") }

    @purchases_by_month = Purchase.joins(:supplier, :purchase_details)
                                   .where(suppliers: { company_id: current_company.id })
                                   .where(order_date: active_range)
                                   .group("DATE_TRUNC('month', purchases.order_date)")
                                   .sum('purchase_details.unit_price * purchase_details.quantity')
                                   .transform_keys { |k| k.strftime("%B %Y") }

    # Ventas por método de pago (responde al filtro)
    @sales_by_payment = Sale.joins(:customer)
                             .where(customers: { company_id: current_company.id })
                             .where(sale_date: active_range)
                             .group(:payment_method)
                             .count
                             .transform_keys do |key|
                               case key
                               when 'Efectivo' then 'Cash'
                               when 'tarjeta_credito' then 'Credit Card'
                               when 'tarjeta_debito' then 'Debit Card'
                               when 'transferencia' then 'Transfer'
                               else key.to_s.titleize
                               end
                             end

    # Compras por proveedor (responde al filtro)
    @purchases_by_supplier = Purchase.joins(:supplier, :purchase_details)
                                     .where(suppliers: { company_id: current_company.id })
                                     .where(order_date: active_range)
                                     .group('suppliers.company_name')
                                     .sum('purchase_details.unit_price * purchase_details.quantity')

    # Debugging
    Rails.logger.debug "Rango activo: #{active_range}"
    Rails.logger.debug "Total ventas en rango: #{@total_sales}"
    Rails.logger.debug "Total compras en rango: #{@total_purchases}"
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
end
