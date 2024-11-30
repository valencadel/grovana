class PagesController < ApplicationController
  skip_before_action :authenticate_any!, only: :home
  before_action :authenticate_any!, only: :dashboard

  def home
  end

  def dashboard
    # Date configuration
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_year
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_year
    year_range = Date.current.beginning_of_year..Date.current.end_of_year

    @date_range = start_date..end_date
    last_month_range = (start_date - 1.month)..(end_date - 1.month)

    # Sales by month
    @sales_by_month = Sale.joins(:customer, :sale_details)
                          .where(customers: { company_id: current_company.id })
                          .where(sale_date: @date_range)
                          .group("DATE_TRUNC('month', sales.sale_date)")
                          .sum('sale_details.unit_price * sale_details.quantity')

    @sales_by_month = @sales_by_month.transform_keys { |k| k.strftime("%B %Y") }

    # Purchases by month
    @purchases_by_month = Purchase.joins(:supplier, :purchase_details)
                                 .where(suppliers: { company_id: current_company.id })
                                 .where(order_date: @date_range)
                                 .group("DATE_TRUNC('month', purchases.order_date)")
                                 .sum('purchase_details.unit_price * purchase_details.quantity')

    @purchases_by_month = @purchases_by_month.transform_keys { |k| k.strftime("%B %Y") }

    # Purchases by supplier
    @purchases_by_supplier = Purchase.joins(:supplier, :purchase_details)
                                     .where(suppliers: { company_id: current_company.id })
                                     .where(order_date: @date_range)
                                     .group('suppliers.company_name')
                                     .sum('purchase_details.unit_price * purchase_details.quantity')

    # Sales by payment method
    @sales_by_payment = Sale.joins(:customer)
                             .where(customers: { company_id: current_company.id })
                             .where(sale_date: @date_range)
                             .group(:payment_method)
                             .count

    # Format payment methods in English
    @sales_by_payment = @sales_by_payment.transform_keys do |key|
      case key
      when 'cash' then 'Cash'
      when 'credit_card' then 'Credit Card'
      when 'debit_card' then 'Debit Card'
      when 'transfer' then 'Transfer'
      else key.to_s.titleize
      end
    end

    # Basic metrics
    @total_customers = Customer.where(company_id: current_company.id)
                             .where(created_at: @date_range).count
    @total_customers_last_month = Customer.where(company_id: current_company.id)
                                        .where(created_at: last_month_range).count

    purchase_base_query = Purchase.joins(:supplier)
                                .where(suppliers: { company_id: current_company.id })

    @total_purchases = purchase_base_query.where(order_date: @date_range).count
    @total_purchases_last_month = purchase_base_query.where(order_date: last_month_range).count

    purchase_details_query = Purchase.joins(:supplier, :purchase_details)
                                   .where(suppliers: { company_id: current_company.id })

    @total_purchases_amount = purchase_details_query
                              .where(order_date: @date_range)
                              .sum('purchase_details.unit_price * purchase_details.quantity')

    @total_purchases_amount_last_month = purchase_details_query
                                        .where(order_date: last_month_range)
                                        .sum('purchase_details.unit_price * purchase_details.quantity')

    sale_base_query = Sale.joins(:customer)
                           .where(customers: { company_id: current_company.id })

    @total_sales = sale_base_query.where(sale_date: @date_range).count
    @total_sales_last_month = sale_base_query.where(sale_date: last_month_range).count

    sale_details_query = Sale.joins(:customer, :sale_details)
                            .where(customers: { company_id: current_company.id })

    @total_sales_amount = sale_details_query
                          .where(sale_date: @date_range)
                          .sum('sale_details.unit_price * sale_details.quantity')

    @total_sales_amount_last_month = sale_details_query
                                    .where(sale_date: last_month_range)
                                    .sum('sale_details.unit_price * sale_details.quantity')

    # Calculate percentage changes
    @customers_change = calculate_percentage_change(@total_customers, @total_customers_last_month)
    @purchases_change = calculate_percentage_change(@total_purchases, @total_purchases_last_month)
    @purchases_amount_change = calculate_percentage_change(@total_purchases_amount, @total_purchases_amount_last_month)
    @sales_change = calculate_percentage_change(@total_sales, @total_sales_last_month)
    @sales_amount_change = calculate_percentage_change(@total_sales_amount, @total_sales_amount_last_month)
  end

  private

  def calculate_percentage_change(current_value, previous_value)
    return 0 if previous_value.to_f.zero?
    ((current_value - previous_value).to_f / previous_value * 100).round(1)
  end

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
                        elsif current_employee
                          current_employee.company
                        end
  end
end
