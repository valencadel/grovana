# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Limpiando base de datos
puts "Limpiando base de datos..."
Company.destroy_all
User.destroy_all
Employee.destroy_all
Product.destroy_all
Customer.destroy_all

# Creando usuarios
puts "Creando usuarios..."
users = [
  { email: "roberto@example.com", password: "123456", first_name: "roberto", last_name: "prada" },
  { email: "valentin@example.com", password: "123456", first_name: "valentin", last_name: "cadel" },
  { email: "omar@example.com", password: "123456", first_name: "omar", last_name: "gonzales" }
]

created_users = users.map do |user_params|
  User.create!(user_params)
end

# Creando empresas
puts "Creando empresas..."
companies = [
  { name: "TechCorp", description: "Technology Company", user_id: created_users[0].id },
  { name: "DesignCo", description: "Design Company", user_id: created_users[1].id },
  { name: "InnovateX", description: "Innovative Solutions", user_id: created_users[2].id }  # Empresa adicional
]

created_companies = companies.map do |company_params|
  Company.create!(company_params)
end

# Creando empleados
puts "Creando empleados..."
employees = [
  { first_name: "Carlos", last_name: "Pérez", password: "123456", status: "active", company_id: created_companies[0].id, email: "carlos@example.com", role: "Manager" },
  { first_name: "Ana", last_name: "López", password: "123456", status: "active", company_id: created_companies[1].id, email: "ana@example.com", role: "Developer" },
  { first_name: "Luis", last_name: "Martínez", password: "123456", status: "active", company_id: created_companies[2].id, email: "luis@example.com", role: "Designer" }  # Empleado adicional
]

employees.each do |employee_params|
  Employee.create!(employee_params)
end

# Creando productos
puts "Creando productos..."
products = [
  { name: "Laptop", sku: "LAP123", description: "High-performance laptop", category: "Electronics", stock: 10, min_stock: 2, brand: "BrandX", status: true, company_id: created_companies[0].id },
  { name: "Mouse", sku: "MOU123", description: "Wireless mouse", category: "Electronics", stock: 25, min_stock: 5, brand: "BrandY", status: true, company_id: created_companies[1].id },
  { name: "Keyboard", sku: "KEY123", description: "Mechanical keyboard", category: "Electronics", stock: 30, min_stock: 5, brand: "BrandZ", status: true, company_id: created_companies[2].id }
]

products.each do |product_params|
  Product.create!(product_params)
end

# Creando clientes
puts "Creando clientes..."
customers = [
  { first_name: "Maria", last_name: "Sánchez", email: "maria@example.com", phone: "123456789", address: "Calle Falsa 123", tax_id: "ABCD1234" },
  { first_name: "Pedro", last_name: "González", email: "pedro@example.com", phone: "987654321", address: "Calle Real 456", tax_id: "EFGH5678" },
  { first_name: "Laura", last_name: "Ramírez", email: "laura@example.com", phone: "112233445", address: "Avenida Central 789", tax_id: "IJKL9101" }  # Cliente adicional
]

customers.each do |customer_params|
  Customer.create!(customer_params)
end

puts "Datos de seed completos."
