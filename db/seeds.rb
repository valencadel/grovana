# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Limpiando base de datos
puts "Limpiando base de datos..."
Sale.destroy_all
SaleDetail.destroy_all
Customer.destroy_all
Company.destroy_all
User.destroy_all
Employee.destroy_all
Product.destroy_all
Supplier.destroy_all

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
  { name: "InnovateX", description: "Innovative Solutions", user_id: created_users[2].id }
]

created_companies = companies.map do |company_params|
  Company.create!(company_params)
end

# Creando empleados
puts "Creando empleados..."
employees = [
  {
    first_name: "Carlos",
    last_name: "Pérez",
    password: "123456",
    status: "active",
    company_id: created_companies[0].id,
    email: "carlos@example.com",
    role: "Manager"
  },
  {
    first_name: "Ana",
    last_name: "López",
    password: "123456",
    status: "active",
    company_id: created_companies[1].id,
    email: "ana@example.com",
    role: "Employee"
  },
  {
    first_name: "Luis",
    last_name: "Martínez",
    password: "123456",
    status: "active",
    company_id: created_companies[2].id,
    email: "luis@example.com",
    role: "Employee"
  }
]

employees.each do |employee_params|
  Employee.create!(employee_params)
end

# Creando productos
puts "Creando productos..."
products = [
  {
    name: "Laptop",
    sku: "LAP123",
    description: "High-performance laptop",
    category: "Electronics",
    stock: 10,
    min_stock: 2,
    brand: "BrandX",
    status: true,
    price: 1500.00,
    company_id: created_companies[0].id
  },
  {
    name: "Mouse",
    sku: "MOU123",
    description: "Wireless mouse",
    category: "Electronics",
    stock: 25,
    min_stock: 5,
    brand: "BrandY",
    status: true,
    price: 50.00,
    company_id: created_companies[1].id
  },
  {
    name: "Keyboard",
    sku: "KEY123",
    description: "Mechanical keyboard",
    category: "Electronics",
    stock: 30,
    min_stock: 5,
    brand: "BrandZ",
    status: true,
    price: 100.00,
    company_id: created_companies[2].id
  }
]

created_products = products.map do |product_params|
  Product.create!(product_params)
end

# Creando clientes
puts "Creando clientes..."
customers = [
  {
    first_name: "Maria",
    last_name: "Sánchez",
    email: "maria@example.com",
    phone: "123456789",
    address: "Avenida Callao 2578, Recoleta",
    tax_id: "ABCD1234",
    company_id: created_companies[0].id
  },
  {
    first_name: "Pedro",
    last_name: "González",
    email: "pedro@example.com",
    phone: "987654321",
    address: "Av. del Libertador 4096, Palermo",
    tax_id: "EFGH5678",
    company_id: created_companies[1].id
  },
  {
    first_name: "Laura",
    last_name: "Ramírez",
    email: "laura@example.com",
    phone: "112233445",
    address: "Guatemala 4699, Palermo",
    tax_id: "IJKL9101",
    company_id: created_companies[2].id
  }
]

created_customers = customers.map do |customer_params|
  Customer.create!(customer_params)
end

# Creando suppliers
puts "Creando suppliers..."
suppliers = [
  {
    company_name: "TechSupplies Argentina",
    contact_name: "Juan Pérez",
    email: "juan@techsupplies.com",
    phone: "11-4567-8901",
    address: "Armenia 1680, Palermo",
    tax_id: "30-12345678-9",
    company_id: created_companies[0].id
  },
  {
    company_name: "Electrónica Mayorista",
    contact_name: "María García",
    email: "maria@electronica.com",
    phone: "11-2345-6789",
    address: "Av. Cabildo 2345, CABA",
    tax_id: "30-98765432-1",
    company_id: created_companies[0].id
  },
  {
    company_name: "Materiales de Diseño SA",
    contact_name: "Carlos Rodríguez",
    email: "carlos@materialesdisenio.com",
    phone: "11-3456-7890",
    address: "Lascano 2257, Villa del Parque",
    tax_id: "30-45678901-2",
    company_id: created_companies[1].id
  },
  {
    company_name: "Importadora TecnoPartes",
    contact_name: "Roberto González",
    email: "roberto@tecnopartes.com",
    phone: "11-6789-0123",
    address: "Av. Scalabrini Ortiz 3456, Palermo",
    tax_id: "30-34567890-2",
    company_id: created_companies[0].id
  },
  {
    company_name: "Soluciones Empresariales",
    contact_name: "Valeria Torres",
    email: "valeria@solucionesempr.com",
    phone: "11-1234-5678",
    address: "Tucumán 1171, San Nicolás",
    tax_id: "30-01234567-8",
    company_id: created_companies[2].id
  },
  {
    company_name: "Insumos Innovadores SRL",
    contact_name: "Laura Martínez",
    email: "laura@insumosinnovadores.com",
    phone: "11-5678-9012",
    address: "Junín 1760, Recoleta",
    tax_id: "30-78901234-3",
    company_id: created_companies[2].id
  }
]

suppliers.each do |supplier_params|
  Supplier.create!(supplier_params)
end

puts "Datos de seed completos."
