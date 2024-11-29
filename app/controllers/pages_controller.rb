class PagesController < ApplicationController
  skip_before_action :authenticate_any!, only: :home
  before_action :authenticate_any!, only: :dashboard

  def home
  end

  def dashboard
    start_date = params[:start_date].presence || 1.year.ago
    end_date = params[:end_date].presence || Date.current
    @date_range = start_date..end_date

    # Métricas básicas
    @total_customers = Customer.where(company_id: current_company.id).count
    @total_purchases = Purchase.joins(:supplier)
                             .where(suppliers: { company_id: current_company.id })
                             .where(order_date: @date_range)
                             .count
    @total_sales = Sale.joins(:customer)
                      .where(customers: { company_id: current_company.id })
                      .where(sale_date: @date_range)
                      .count

    # Ventas por mes
    @sales_by_month = Sale.joins(:customer)
                         .where(customers: { company_id: current_company.id })
                         .where(sale_date: @date_range)
                         .group_by_month(:sale_date)
                         .sum(:total_price)
                         .transform_keys { |k| k.strftime("%b-%Y") }

    # Compras por mes
    @purchases_by_month = Purchase.joins(:supplier)
                                .where(suppliers: { company_id: current_company.id })
                                .where(order_date: @date_range)
                                .group_by_month(:order_date)
                                .sum(:total_price)
                                .transform_keys { |k| k.strftime("%b-%Y") }

    # Ventas por método de pago
    @sales_by_payment = Sale.joins(:customer)
                           .where(customers: { company_id: current_company.id })
                           .where(sale_date: @date_range)
                           .group(:payment_method)
                           .sum(:total_price)

    # Compras por proveedor
    @purchases_by_supplier = Purchase.joins(:supplier)
                                   .where(suppliers: { company_id: current_company.id })
                                   .where(order_date: @date_range)
                                   .group('suppliers.company_name')
                                   .sum(:total_price)

    # Top clientes
    @top_customers = Sale.joins(:customer)
                        .where(customers: { company_id: current_company.id })
                        .where(sale_date: @date_range)
                        .group('CONCAT(customers.first_name, \' \', customers.last_name)')
                        .sum(:total_price)
                        .sort_by { |_, amount| -amount }
                        .first(5)
                        .to_h

    # Top productos
    @top_products = SaleDetail.joins(sale: :customer, product: :company)
                             .where(companies: { id: current_company.id })
                             .where(sales: { sale_date: @date_range })
                             .group('products.name')
                             .sum(:quantity)
                             .sort_by { |_, quantity| -quantity }
                             .first(5)
                             .to_h

    @total_sales_amount = Sale.joins(:customer)
                             .where(customers: { company_id: current_company.id })
                             .sum(:total_price)
  end

  private

  def current_company
    @current_company ||= if current_user
                          current_user.companies.first
                        elsif current_employee
                          current_employee.company
                        end
  end
end
