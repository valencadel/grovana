require "gemini-ai"
require "base64"
class PagesController < ApplicationController
  skip_before_action :authenticate_any!, only: :home
  before_action :authenticate_any!, only: :dashboard

  def home
  end

  def dashboard
    # Convertir strings a Date
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.current.end_of_month

    @date_range = start_date..end_date
    last_month_range = (start_date - 1.month)..(end_date - 1.month)

    # Métricas actuales
    @total_customers = Customer.where(company_id: current_company.id).count
    @total_customers_last_month = Customer.where(company_id: current_company.id)
                                        .where("created_at <= ?", 1.month.ago.end_of_month).count

    @total_purchases = Purchase.joins(:supplier)
                             .where(suppliers: { company_id: current_company.id })
                             .where(order_date: @date_range).count
    @total_purchases_last_month = Purchase.joins(:supplier)
                                        .where(suppliers: { company_id: current_company.id })
                                        .where(order_date: last_month_range).count

    @total_purchases_amount = Purchase.joins(:supplier)
                                    .where(suppliers: { company_id: current_company.id })
                                    .where(order_date: @date_range)
                                    .sum(:total_price)
    @total_purchases_amount_last_month = Purchase.joins(:supplier)
                                               .where(suppliers: { company_id: current_company.id })
                                               .where(order_date: last_month_range)
                                               .sum(:total_price)

    @total_sales = Sale.joins(:customer)
                      .where(customers: { company_id: current_company.id })
                      .where(sale_date: @date_range).count
    @total_sales_last_month = Sale.joins(:customer)
                                 .where(customers: { company_id: current_company.id })
                                 .where(sale_date: last_month_range).count

    @total_sales_amount = Sale.joins(:customer)
                             .where(customers: { company_id: current_company.id })
                             .where(sale_date: @date_range)
                             .sum(:total_price)
    @total_sales_amount_last_month = Sale.joins(:customer)
                                        .where(customers: { company_id: current_company.id })
                                        .where(sale_date: last_month_range)
                                        .sum(:total_price)

    # Calcular porcentajes de cambio
    @customers_change = calculate_percentage_change(@total_customers, @total_customers_last_month)
    @purchases_change = calculate_percentage_change(@total_purchases, @total_purchases_last_month)
    @purchases_amount_change = calculate_percentage_change(@total_purchases_amount, @total_purchases_amount_last_month)
    @sales_change = calculate_percentage_change(@total_sales, @total_sales_last_month)
    @sales_amount_change = calculate_percentage_change(@total_sales_amount, @total_sales_amount_last_month)

    # Datos para los gráficos
    @sales_by_month = Sale.joins(:customer)
                         .where(customers: { company_id: current_company.id })
                         .where(sale_date: @date_range)
                         .group_by_month(:sale_date)
                         .sum(:total_price)

    @purchases_by_month = Purchase.joins(:supplier)
                                .where(suppliers: { company_id: current_company.id })
                                .where(order_date: @date_range)
                                .group_by_month(:order_date)
                                .sum(:total_price)

    @sales_by_payment = Sale.joins(:customer)
                           .where(customers: { company_id: current_company.id })
                           .where(sale_date: @date_range)
                           .group(:payment_method)
                           .sum(:total_price)

    @purchases_by_supplier = Purchase.joins(:supplier)
                                   .where(suppliers: { company_id: current_company.id })
                                   .where(order_date: @date_range)
                                   .group("suppliers.company_name")
                                   .sum(:total_price)
  end

  def doc_gemini
    client = Gemini.new(
      credentials: {
        service: "generative-language-api",
        api_key: ENV["GEMINI_API_KEY"]
      },
      options: { model: "gemini-1.5-flash", server_sent_events: true }
    )
    result = client.stream_generate_content({
      contents: { role: "user", parts: { text: "Hi, can you tell me where is located Peru?" } }
    })
    # Extract the response text
    response_text = result.flat_map do |entry|
      entry["candidates"].flat_map do |candidate|
        candidate["content"]["parts"].map { |part| part["text"] }
      end
    end.join

    @content = response_text
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
