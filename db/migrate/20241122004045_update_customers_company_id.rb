class UpdateCustomersCompanyId < ActiveRecord::Migration[7.1]
  def up
    # Asignar una compañía a todos los customers existentes
    company = Company.first
    if company
      Customer.where(company_id: nil).update_all(company_id: company.id)
    end

    # Hacer la columna no nula
    change_column_null :customers, :company_id, false
  end

  def down
    change_column_null :customers, :company_id, true
  end
end
