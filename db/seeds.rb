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
  # Laptops y Notebooks
  {
    name: "Laptop HP Pavilion",
    sku: "LAP123",
    description: "Laptop HP Pavilion, 16GB RAM, 512GB SSD",
    category: "Laptops",
    stock: 10,
    min_stock: 2,
    brand: "HP",
    status: true,
    price: 1500.00,
    company_id: created_companies[0].id
  },
  {
    name: "Laptop Lenovo ThinkPad E14",
    sku: "LAP124",
    description: "Laptop Lenovo ThinkPad E14, Ryzen 7, 16GB RAM, 512GB SSD",
    category: "Laptops",
    stock: 8,
    min_stock: 2,
    brand: "Lenovo",
    status: true,
    price: 1200.00,
    company_id: created_companies[0].id
  },
  {
    name: "Laptop Dell XPS 13",
    sku: "LAP125",
    description: "Laptop Dell XPS 13, Intel i7, 16GB RAM, 1TB SSD",
    category: "Laptops",
    stock: 6,
    min_stock: 2,
    brand: "Dell",
    status: true,
    price: 1800.00,
    company_id: created_companies[0].id
  },

  # Monitores
  {
    name: "Monitor Samsung 27'",
    sku: "MON456",
    description: "Monitor LED 27 pulgadas 4K",
    category: "Monitores",
    stock: 15,
    min_stock: 3,
    brand: "Samsung",
    status: true,
    price: 450.00,
    company_id: created_companies[0].id
  },
  {
    name: "Monitor LG 32' UltraGear",
    sku: "MON457",
    description: "Monitor Gaming 32' 165Hz QHD",
    category: "Monitores",
    stock: 12,
    min_stock: 3,
    brand: "LG",
    status: true,
    price: 650.00,
    company_id: created_companies[0].id
  },

  # Periféricos Gaming
  {
    name: "Teclado Mecánico Redragon",
    sku: "KEY789",
    description: "Teclado mecánico RGB switches Blue",
    category: "Periféricos Gaming",
    stock: 30,
    min_stock: 5,
    brand: "Redragon",
    status: true,
    price: 80.00,
    company_id: created_companies[0].id
  },
  {
    name: "Mouse Logitech G Pro",
    sku: "MOU101",
    description: "Mouse gaming inalámbrico",
    category: "Periféricos Gaming",
    stock: 25,
    min_stock: 5,
    brand: "Logitech",
    status: true,
    price: 120.00,
    company_id: created_companies[0].id
  },
  {
    name: "Auriculares HyperX",
    sku: "AUR202",
    description: "Auriculares gaming con micrófono",
    category: "Periféricos Gaming",
    stock: 20,
    min_stock: 4,
    brand: "HyperX",
    status: true,
    price: 150.00,
    company_id: created_companies[0].id
  },

  # Componentes PC
  {
    name: "SSD Samsung 1TB",
    sku: "SSD505",
    description: "Disco sólido 1TB NVMe",
    category: "Componentes PC",
    stock: 40,
    min_stock: 5,
    brand: "Samsung",
    status: true,
    price: 180.00,
    company_id: created_companies[0].id
  },
  {
    name: "Memoria RAM Corsair 32GB",
    sku: "RAM101",
    description: "Kit Memoria RAM 2x16GB DDR4 3200MHz",
    category: "Componentes PC",
    stock: 25,
    min_stock: 5,
    brand: "Corsair",
    status: true,
    price: 220.00,
    company_id: created_companies[0].id
  },
  {
    name: "Procesador Ryzen 7 5800X",
    sku: "CPU101",
    description: "AMD Ryzen 7 5800X 8-Core 4.7GHz",
    category: "Componentes PC",
    stock: 15,
    min_stock: 3,
    brand: "AMD",
    status: true,
    price: 450.00,
    company_id: created_companies[0].id
  },

  # Smartphones
  {
    name: "iPhone 14 Pro 256GB",
    sku: "MOV101",
    description: "iPhone 14 Pro 256GB, Negro Espacial",
    category: "Smartphones",
    stock: 10,
    min_stock: 2,
    brand: "Apple",
    status: true,
    price: 1900.00,
    company_id: created_companies[0].id
  },
  {
    name: "Samsung Galaxy S23 Ultra",
    sku: "MOV102",
    description: "Samsung Galaxy S23 Ultra 256GB 5G",
    category: "Smartphones",
    stock: 8,
    min_stock: 2,
    brand: "Samsung",
    status: true,
    price: 1700.00,
    company_id: created_companies[0].id
  },

  # Networking
  {
    name: "Router ASUS ROG Rapture",
    sku: "NET101",
    description: "Router Gaming WiFi 6 Dual Band",
    category: "Networking",
    stock: 15,
    min_stock: 3,
    brand: "ASUS",
    status: true,
    price: 380.00,
    company_id: created_companies[0].id
  },
  {
    name: "Switch TP-Link 24 puertos",
    sku: "NET102",
    description: "Switch Gigabit 24 puertos administrable",
    category: "Networking",
    stock: 10,
    min_stock: 2,
    brand: "TP-Link",
    status: true,
    price: 250.00,
    company_id: created_companies[0].id
  },

  # Accesorios
  {
    name: "Dock Station Universal",
    sku: "ACC101",
    description: "Dock Station USB-C 12 en 1",
    category: "Accesorios",
    stock: 20,
    min_stock: 4,
    brand: "Anker",
    status: true,
    price: 120.00,
    company_id: created_companies[0].id
  },
  {
    name: "Cable HDMI 2.1 4K",
    sku: "CAB101",
    description: "Cable HDMI 2.1 8K 2m certificado",
    category: "Accesorios",
    stock: 50,
    min_stock: 10,
    brand: "Belkin",
    status: true,
    price: 45.00,
    company_id: created_companies[0].id
  },
  {
    name: "Webcam Logitech C920",
    sku: "WEB303",
    description: "Webcam HD 1080p",
    category: "Accesorios",
    stock: 12,
    min_stock: 3,
    brand: "Logitech",
    status: true,
    price: 90.00,
    company_id: created_companies[0].id
  },
  {
    name: "Parlantes Edifier",
    sku: "PAR404",
    description: "Sistema de parlantes 2.1",
    category: "Accesorios",
    stock: 8,
    min_stock: 2,
    brand: "Edifier",
    status: true,
    price: 200.00,
    company_id: created_companies[0].id
  }
]

created_products = products.map do |product_params|
  Product.create!(product_params)
end

# Creando clientes
puts "Creando clientes..."
customers = [
  # Clientes originales
  {
    first_name: "Maria",
    last_name: "Sánchez",
    email: "maria@example.com",
    phone: "11-4567-8901",
    address: "Av. Santa Fe 3253, Palermo",
    tax_id: "27-12345678-9",
    company_id: created_companies[0].id
  },
  {
    first_name: "Pedro",
    last_name: "González",
    email: "pedro@example.com",
    phone: "11-2345-6789",
    address: "Av. Corrientes 3247, Almagro",
    tax_id: "20-23456789-0",
    company_id: created_companies[0].id
  },
  {
    first_name: "Laura",
    last_name: "Ramírez",
    email: "laura@example.com",
    phone: "11-3456-7890",
    address: "Av. Cabildo 2040, Belgrano",
    tax_id: "27-34567890-1",
    company_id: created_companies[0].id
  },
  {
    first_name: "Carlos",
    last_name: "Fernández",
    email: "carlos@example.com",
    phone: "11-5678-9012",
    address: "Defensa 1120, San Telmo",
    tax_id: "20-45678901-2",
    company_id: created_companies[0].id
  },
  {
    first_name: "Ana",
    last_name: "Martínez",
    email: "ana@example.com",
    phone: "11-6789-0123",
    address: "Gurruchaga 1780, Villa Crespo",
    tax_id: "27-56789012-3",
    company_id: created_companies[0].id
  },
  {
    first_name: "Diego",
    last_name: "López",
    email: "diego@example.com",
    phone: "11-7890-1234",
    address: "Av. Las Heras 2255, Recoleta",
    tax_id: "20-67890123-4",
    company_id: created_companies[0].id
  },
  {
    first_name: "Julia",
    last_name: "García",
    email: "julia@example.com",
    phone: "11-8901-2345",
    address: "Av. Rivadavia 4950, Caballito",
    tax_id: "27-78901234-5",
    company_id: created_companies[0].id
  },
  {
    first_name: "Martín",
    last_name: "Rodriguez",
    email: "martin@example.com",
    phone: "11-9012-3456",
    address: "Av. Scalabrini Ortiz 2450, Palermo",
    tax_id: "20-89012345-6",
    company_id: created_companies[0].id
  },
  # Nuevos clientes para TechCorp (company 0)
  {
    first_name: "Federico",
    last_name: "Alvarez",
    email: "federico@example.com",
    phone: "11-5555-1234",
    address: "Av. Cabildo 3500, Núñez",
    tax_id: "20-34567890-8",
    company_id: created_companies[0].id
  },
  {
    first_name: "Valentina",
    last_name: "Torres",
    email: "valentina@example.com",
    phone: "11-6666-5678",
    address: "Av. Forest 1200, Colegiales",
    tax_id: "27-45678901-9",
    company_id: created_companies[0].id
  },
  # Nuevos clientes para DesignCo (company 1)
  {
    first_name: "Santiago",
    last_name: "Morales",
    email: "santiago@example.com",
    phone: "11-7777-9012",
    address: "Av. Nazca 2500, Flores",
    tax_id: "20-56789012-0",
    company_id: created_companies[1].id
  },
  {
    first_name: "Carolina",
    last_name: "Paz",
    email: "carolina@example.com",
    phone: "11-8888-3456",
    address: "Av. Directorio 1500, Parque Chacabuco",
    tax_id: "27-67890123-1",
    company_id: created_companies[1].id
  },
  # Nuevos clientes para InnovateX (company 2)
  {
    first_name: "Gonzalo",
    last_name: "Vargas",
    email: "gonzalo@example.com",
    phone: "11-9999-7890",
    address: "Av. San Juan 3100, Boedo",
    tax_id: "20-78901234-2",
    company_id: created_companies[2].id
  },
  {
    first_name: "Luciana",
    last_name: "Mendez",
    email: "luciana@example.com",
    phone: "11-1010-2345",
    address: "Av. La Plata 1500, Parque Patricios",
    tax_id: "27-89012345-3",
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
