# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Limpiando base de datos
puts "Limpiando base de datos..."
Sale.destroy_all
SaleDetail.destroy_all
Purchase.destroy_all
PurchaseDetail.destroy_all
Customer.destroy_all
Product.destroy_all
Supplier.destroy_all
Employee.destroy_all
Company.destroy_all
User.destroy_all

# Creando usuarios
puts "Creando usuarios..."
users = [
  { email: "roberto@example.com", password: "123456", first_name: "Roberto", last_name: "Prada" },
  { email: "valentin@example.com", password: "123456", first_name: "Valentin", last_name: "Cadel" },
  { email: "omar@example.com", password: "123456", first_name: "Omar", last_name: "Gonzales" }
]

created_users = users.map do |user_params|
  User.create!(user_params)
end

# Creando empresas
puts "Creando empresas..."
companies = [
  { name: "TechCorp", description: "Especialistas en Gaming y Hardware", user_id: created_users[0].id },
  { name: "DesignCo", description: "Soluciones de Diseño y Creatividad", user_id: created_users[1].id },
  { name: "InnovateX", description: "Tecnología Empresarial", user_id: created_users[2].id }
]

created_companies = companies.map do |company_params|
  Company.create!(company_params)
end

# Creando productos para TechCorp (Gaming/Hardware)
puts "Creando productos para TechCorp..."
products = [
  # Categoría 1: Laptops Gaming
  {
    name: "ASUS ROG Strix G16", sku: "LAP001", category: "Laptops Gaming",
    description: "i9 14900H, RTX 4070, 32GB RAM", stock: 10, min_stock: 2,
    brand: "ASUS", status: true, price: 3_500_000, company_id: created_companies[0].id
  },
  {
    name: "MSI Raider GE78 HX", sku: "LAP002", category: "Laptops Gaming",
    description: "i9 13980HX, RTX 4090, 64GB RAM", stock: 8, min_stock: 2,
    brand: "MSI", status: true, price: 4_800_000, company_id: created_companies[0].id
  },
  {
    name: "Lenovo Legion Pro 7i", sku: "LAP003", category: "Laptops Gaming",
    description: "i9 13900HX, RTX 4080, 32GB RAM", stock: 12, min_stock: 3,
    brand: "Lenovo", status: true, price: 3_900_000, company_id: created_companies[0].id
  },
  {
    name: "Acer Predator Helios 16", sku: "LAP004", category: "Laptops Gaming",
    description: "i7 13700HX, RTX 4070, 32GB RAM", stock: 15, min_stock: 3,
    brand: "Acer", status: true, price: 2_900_000, company_id: created_companies[0].id
  },

  # Categoría 2: Monitores Gaming
  {
    name: "ASUS ROG Swift PG32UQX", sku: "MON001", category: "Monitores Gaming",
    description: "32' 4K 144Hz Mini LED", stock: 8, min_stock: 2,
    brand: "ASUS", status: true, price: 1_200_000, company_id: created_companies[0].id
  },
  {
    name: "Samsung Odyssey G8", sku: "MON002", category: "Monitores Gaming",
    description: "34' QD-OLED Ultrawide 175Hz", stock: 10, min_stock: 2,
    brand: "Samsung", status: true, price: 980_000, company_id: created_companies[0].id
  },
  {
    name: "LG UltraGear 27GR95QE", sku: "MON003", category: "Monitores Gaming",
    description: "27' OLED 240Hz", stock: 12, min_stock: 3,
    brand: "LG", status: true, price: 850_000, company_id: created_companies[0].id
  },
  {
    name: "Alienware AW3423DWF", sku: "MON004", category: "Monitores Gaming",
    description: "34' QD-OLED 165Hz", stock: 6, min_stock: 2,
    brand: "Dell", status: true, price: 1_100_000, company_id: created_companies[0].id
  },

  # Categoría 3: Componentes PC
  {
    name: "AMD Ryzen 9 7950X3D", sku: "CPU001", category: "Componentes PC",
    description: "16 núcleos, 32 hilos, AM5", stock: 15, min_stock: 3,
    brand: "AMD", status: true, price: 980_000, company_id: created_companies[0].id
  },
  {
    name: "NVIDIA RTX 4090", sku: "GPU001", category: "Componentes PC",
    description: "24GB GDDR6X", stock: 8, min_stock: 2,
    brand: "NVIDIA", status: true, price: 2_800_000, company_id: created_companies[0].id
  },
  {
    name: "G.Skill Trident Z5", sku: "RAM001", category: "Componentes PC",
    description: "32GB (2x16) DDR5 6400MHz", stock: 20, min_stock: 5,
    brand: "G.Skill", status: true, price: 250_000, company_id: created_companies[0].id
  },
  {
    name: "Samsung 990 Pro", sku: "SSD001", category: "Componentes PC",
    description: "2TB NVMe PCIe 4.0", stock: 25, min_stock: 5,
    brand: "Samsung", status: true, price: 320_000, company_id: created_companies[0].id
  },

  # Categoría 4: Periféricos Gaming
  {
    name: "Razer Huntsman V2", sku: "KEY001", category: "Periféricos Gaming",
    description: "Teclado óptico RGB", stock: 30, min_stock: 5,
    brand: "Razer", status: true, price: 180_000, company_id: created_companies[0].id
  },
  {
    name: "Logitech G Pro X Superlight", sku: "MOU001", category: "Periféricos Gaming",
    description: "Mouse inalámbrico ultraligero", stock: 25, min_stock: 5,
    brand: "Logitech", status: true, price: 150_000, company_id: created_companies[0].id
  },
  {
    name: "Astro A50", sku: "HEAD001", category: "Periféricos Gaming",
    description: "Auriculares inalámbricos con base", stock: 15, min_stock: 3,
    brand: "Astro", status: true, price: 280_000, company_id: created_companies[0].id
  },
  {
    name: "Artisan Ninja FX Zero XL", sku: "PAD001", category: "Periféricos Gaming",
    description: "Mousepad profesional XL", stock: 40, min_stock: 8,
    brand: "Artisan", status: true, price: 85_000, company_id: created_companies[0].id
  },

  # Categoría 5: Streaming
  {
    name: "Sony ZV-E10", sku: "CAM001", category: "Streaming",
    description: "Cámara mirrorless para streaming", stock: 10, min_stock: 2,
    brand: "Sony", status: true, price: 750_000, company_id: created_companies[0].id
  },
  {
    name: "Shure SM7B", sku: "MIC001", category: "Streaming",
    description: "Micrófono profesional XLR", stock: 12, min_stock: 3,
    brand: "Shure", status: true, price: 420_000, company_id: created_companies[0].id
  },
  {
    name: "Elgato 4K60 Pro", sku: "CAP001", category: "Streaming",
    description: "Capturadora PCIe 4K", stock: 15, min_stock: 3,
    brand: "Elgato", status: true, price: 280_000, company_id: created_companies[0].id
  },
  {
    name: "Stream Deck XL", sku: "STR001", category: "Streaming",
    description: "Controlador para streaming 32 teclas", stock: 8, min_stock: 2,
    brand: "Elgato", status: true, price: 190_000, company_id: created_companies[0].id
  }
]

# Productos para DesignCo
products += [
  # Categoría 1: Equipos Apple
  {
    name: "MacBook Pro 16' M3 Max", sku: "MAC001", category: "Equipos Apple",
    description: "M3 Max 48GB RAM 2TB", stock: 8, min_stock: 2,
    brand: "Apple", status: true, price: 5_500_000, company_id: created_companies[1].id
  },
  {
    name: "iMac 24' M3", sku: "MAC002", category: "Equipos Apple",
    description: "M3 16GB RAM 1TB", stock: 10, min_stock: 2,
    brand: "Apple", status: true, price: 2_800_000, company_id: created_companies[1].id
  },
  {
    name: "Mac Studio M2 Ultra", sku: "MAC003", category: "Equipos Apple",
    description: "M2 Ultra 128GB RAM 4TB", stock: 5, min_stock: 1,
    brand: "Apple", status: true, price: 7_500_000, company_id: created_companies[1].id
  },
  {
    name: "Pro Display XDR", sku: "MAC004", category: "Equipos Apple",
    description: "32' 6K Retina", stock: 6, min_stock: 2,
    brand: "Apple", status: true, price: 4_800_000, company_id: created_companies[1].id
  },

  # Categoría 2: Tablets y Digitalizadoras
  {
    name: "Wacom Cintiq Pro 27", sku: "TAB001", category: "Tablets y Digitalizadoras",
    description: "27' 4K Touch", stock: 6, min_stock: 2,
    brand: "Wacom", status: true, price: 2_200_000, company_id: created_companies[1].id
  },
  {
    name: "iPad Pro 12.9' M2", sku: "TAB002", category: "Tablets y Digitalizadoras",
    description: "M2 1TB WiFi+Cellular", stock: 12, min_stock: 3,
    brand: "Apple", status: true, price: 1_800_000, company_id: created_companies[1].id
  },
  {
    name: "Wacom Intuos Pro Large", sku: "TAB003", category: "Tablets y Digitalizadoras",
    description: "Tableta profesional grande", stock: 15, min_stock: 3,
    brand: "Wacom", status: true, price: 450_000, company_id: created_companies[1].id
  },
  {
    name: "XP-Pen Artist 24 Pro", sku: "TAB004", category: "Tablets y Digitalizadoras",
    description: "24' 2K QHD", stock: 8, min_stock: 2,
    brand: "XP-Pen", status: true, price: 980_000, company_id: created_companies[1].id
  },

  # Categoría 3: Software y Licencias
  {
    name: "Adobe Creative Cloud", sku: "SOF001", category: "Software y Licencias",
    description: "Plan anual completo", stock: 50, min_stock: 10,
    brand: "Adobe", status: true, price: 180_000, company_id: created_companies[1].id
  },
  {
    name: "Sketch Pro", sku: "SOF002", category: "Software y Licencias",
    description: "Licencia perpetua", stock: 30, min_stock: 5,
    brand: "Sketch", status: true, price: 120_000, company_id: created_companies[1].id
  },
  {
    name: "Cinema 4D Studio", sku: "SOF003", category: "Software y Licencias",
    description: "Licencia anual", stock: 20, min_stock: 4,
    brand: "Maxon", status: true, price: 250_000, company_id: created_companies[1].id
  },
  {
    name: "Figma Professional", sku: "SOF004", category: "Software y Licencias",
    description: "Plan anual por usuario", stock: 40, min_stock: 8,
    brand: "Figma", status: true, price: 85_000, company_id: created_companies[1].id
  },

  # Categoría 4: Fotografía
  {
    name: "Sony A7R V", sku: "CAM001", category: "Fotografía",
    description: "Cámara mirrorless 61MP", stock: 8, min_stock: 2,
    brand: "Sony", status: true, price: 3_200_000, company_id: created_companies[1].id
  },
  {
    name: "Canon EOS R5", sku: "CAM002", category: "Fotografía",
    description: "Cámara mirrorless 45MP", stock: 10, min_stock: 2,
    brand: "Canon", status: true, price: 2_800_000, company_id: created_companies[1].id
  },
  {
    name: "Profoto B10X Plus", sku: "LIGHT001", category: "Fotografía",
    description: "Flash de estudio portátil", stock: 12, min_stock: 3,
    brand: "Profoto", status: true, price: 950_000, company_id: created_companies[1].id
  },
  {
    name: "DJI RS 3 Pro", sku: "STAB001", category: "Fotografía",
    description: "Estabilizador profesional", stock: 15, min_stock: 3,
    brand: "DJI", status: true, price: 480_000, company_id: created_companies[1].id
  },

  # Categoría 5: Impresión y Color
  {
    name: "Epson SureColor P900", sku: "PRINT001", category: "Impresión y Color",
    description: "Impresora fotográfica 17'", stock: 6, min_stock: 2,
    brand: "Epson", status: true, price: 1_200_000, company_id: created_companies[1].id
  },
  {
    name: "X-Rite i1Display Pro Plus", sku: "CAL001", category: "Impresión y Color",
    description: "Calibrador de pantalla", stock: 15, min_stock: 3,
    brand: "X-Rite", status: true, price: 180_000, company_id: created_companies[1].id
  },
  {
    name: "DataColor SpyderX Elite", sku: "CAL002", category: "Impresión y Color",
    description: "Kit calibración avanzado", stock: 12, min_stock: 3,
    brand: "DataColor", status: true, price: 150_000, company_id: created_companies[1].id
  },
  {
    name: "Canon imagePROGRAF PRO-1000", sku: "PRINT002", category: "Impresión y Color",
    description: "Impresora profesional A2", stock: 8, min_stock: 2,
    brand: "Canon", status: true, price: 980_000, company_id: created_companies[1].id
  }
]

# Productos para InnovateX
products += [
  # Categoría 1: Servidores y Almacenamiento
  {
    name: "Dell PowerEdge R750", sku: "SRV001", category: "Servidores y Almacenamiento",
    description: "Servidor 2U Dual Xeon", stock: 5, min_stock: 1,
    brand: "Dell", status: true, price: 4_500_000, company_id: created_companies[2].id
  },
  {
    name: "HPE ProLiant DL380 Gen10", sku: "SRV002", category: "Servidores y Almacenamiento",
    description: "Servidor 2U Enterprise", stock: 4, min_stock: 1,
    brand: "HP", status: true, price: 3_800_000, company_id: created_companies[2].id
  },
  {
    name: "Synology RS1221+", sku: "NAS001", category: "Servidores y Almacenamiento",
    description: "NAS 8 bahías rack", stock: 8, min_stock: 2,
    brand: "Synology", status: true, price: 950_000, company_id: created_companies[2].id
  },
  {
    name: "QNAP TS-h973AX", sku: "NAS002", category: "Servidores y Almacenamiento",
    description: "NAS 9 bahías híbrido", stock: 6, min_stock: 2,
    brand: "QNAP", status: true, price: 1_200_000, company_id: created_companies[2].id
  },

  # Categoría 2: Networking
  {
    name: "Cisco Catalyst 9300", sku: "NET001", category: "Networking",
    description: "Switch 48 puertos PoE+", stock: 10, min_stock: 2,
    brand: "Cisco", status: true, price: 1_500_000, company_id: created_companies[2].id
  },
  {
    name: "Ubiquiti UniFi Dream Machine Pro", sku: "NET002", category: "Networking",
    description: "Router/Controller Enterprise", stock: 15, min_stock: 3,
    brand: "Ubiquiti", status: true, price: 450_000, company_id: created_companies[2].id
  },
  {
    name: "FortiGate 100F", sku: "NET003", category: "Networking",
    description: "Firewall NGFW", stock: 8, min_stock: 2,
    brand: "Fortinet", status: true, price: 980_000, company_id: created_companies[2].id
  },
  {
    name: "Meraki MR46", sku: "NET004", category: "Networking",
    description: "Access Point WiFi 6", stock: 20, min_stock: 4,
    brand: "Cisco", status: true, price: 280_000, company_id: created_companies[2].id
  },

  # Categoría 3: Workstations
  {
    name: "HP Z6 G4", sku: "WS001", category: "Workstations",
    description: "Workstation Dual Xeon", stock: 6, min_stock: 2,
    brand: "HP", status: true, price: 3_800_000, company_id: created_companies[2].id
  },
  {
    name: "Dell Precision 7865", sku: "WS002", category: "Workstations",
    description: "Workstation AMD Threadripper", stock: 8, min_stock: 2,
    brand: "Dell", status: true, price: 4_200_000, company_id: created_companies[2].id
  },
  {
    name: "Lenovo ThinkStation P620", sku: "WS003", category: "Workstations",
    description: "Workstation AMD Pro", stock: 7, min_stock: 2,
    brand: "Lenovo", status: true, price: 3_500_000, company_id: created_companies[2].id
  },
  {
    name: "HP Z2 Mini G9", sku: "WS004", category: "Workstations",
    description: "Workstation Compacta", stock: 12, min_stock: 3,
    brand: "HP", status: true, price: 2_200_000, company_id: created_companies[2].id
  },

  # Categoría 4: Software Empresarial
  {
    name: "Windows Server 2022", sku: "SRVS001", category: "Software Empresarial",
    description: "Licencia Datacenter", stock: 20, min_stock: 4,
    brand: "Microsoft", status: true, price: 850_000, company_id: created_companies[2].id
  },
  {
    name: "SQL Server 2022", sku: "SRVS002", category: "Software Empresarial",
    description: "Licencia Enterprise", stock: 15, min_stock: 3,
    brand: "Microsoft", status: true, price: 1_200_000, company_id: created_companies[2].id
  },
  {
    name: "VMware vSphere", sku: "SRVS003", category: "Software Empresarial",
    description: "Licencia Enterprise Plus", stock: 10, min_stock: 2,
    brand: "VMware", status: true, price: 950_000, company_id: created_companies[2].id
  },
  {
    name: "Red Hat Enterprise Linux", sku: "SRVS004", category: "Software Empresarial",
    description: "Suscripción Premium", stock: 25, min_stock: 5,
    brand: "Red Hat", status: true, price: 450_000, company_id: created_companies[2].id
  },

  # Categoría 5: UPS y Energía
  {
    name: "APC Smart-UPS SRT 10kVA", sku: "UPS001", category: "UPS y Energía",
    description: "UPS Online Doble Conversión", stock: 6, min_stock: 2,
    brand: "APC", status: true, price: 2_800_000, company_id: created_companies[2].id
  },
  {
    name: "Eaton 9PX 6kVA", sku: "UPS002", category: "UPS y Energía",
    description: "UPS Online Rack/Torre", stock: 8, min_stock: 2,
    brand: "Eaton", status: true, price: 1_900_000, company_id: created_companies[2].id
  },
  {
    name: "Vertiv Liebert GXT5", sku: "UPS003", category: "UPS y Energía",
    description: "UPS 3kVA Rack", stock: 10, min_stock: 2,
    brand: "Vertiv", status: true, price: 950_000, company_id: created_companies[2].id
  },
  {
    name: "APC Rack PDU", sku: "PDU001", category: "UPS y Energía",
    description: "PDU Gestionable 32A", stock: 15, min_stock: 3,
    brand: "APC", status: true, price: 180_000, company_id: created_companies[2].id
  }
]

created_products = products.map do |product_params|
  Product.create!(product_params)
end

# Creando empleados para cada empresa
puts "Creando empleados..."
created_companies.each do |company|
  5.times do |i|
    Employee.create!(
      email: "empleado#{i+1}@#{company.name.downcase}.com",
      password: "123456",
      first_name: [ "Juan", "María", "Carlos", "Ana", "Luis" ][i],
      last_name: [ "Pérez", "González", "Rodríguez", "Martínez", "García" ][i],
      role: [ "Manager", "Employee" ].sample,
      status: "active",
      company_id: company.id
    )
  end
end

# Creando clientes para cada empresa
puts "Creando clientes..."
direcciones_caba = [
  "Av. Corrientes 1234, CABA",
  "Av. Santa Fe 2356, CABA",
  "Av. Cabildo 1789, CABA",
  "Av. Rivadavia 5678, CABA",
  "Av. Scalabrini Ortiz 3456, CABA",
  "Av. del Libertador 4567, CABA",
  "Av. Las Heras 2345, CABA",
  "Av. Córdoba 4321, CABA",
  "Av. Callao 1122, CABA",
  "Av. Pueyrredón 2233, CABA"
]

created_companies.each do |company|
  10.times do |i|
    first_name = [ "Roberto", "Ana", "Diego", "Julia", "Martín", "Federico", "Valentina", "Santiago", "Carolina", "Gonzalo" ][i]
    last_name = [ "López", "Martínez", "García", "Rodríguez", "Fernández", "Alvarez", "Torres", "Morales", "Paz", "Vargas" ][i]
    email = "#{first_name}#{last_name}".downcase.gsub(/[áéíóúñ]/, 'a' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u', 'ñ' => 'n') + "@example.com"
    
    Customer.create!(
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone: "11-#{rand(1000..9999)}-#{rand(1000..9999)}",
      address: direcciones_caba[i],
      tax_id: "20-#{rand(10000000..99999999)}-#{rand(0..9)}",
      company_id: company.id
    )
  end
end

# Creando proveedores para cada empresa
puts "Creando proveedores..."
created_companies.each do |company|
  5.times do |i|
    company_name = [ "TechSupplies", "Electronica Mayorista", "Importadora TecnoPartes", "Soluciones IT", "Distribuidora Digital" ][i]
    Supplier.create!(
      company_name: company_name,
      contact_name: [ "Juan Pérez", "María García", "Carlos Rodríguez", "Ana Martínez", "Luis González" ][i],
      email: "#{company_name.downcase.gsub(' ', '')}@example.com",
      phone: "11-#{rand(1000..9999)}-#{rand(1000..9999)}",
      address: "Av. #{rand(100..9999)}, CABA",
      tax_id: "30-#{rand(10000000..99999999)}-#{rand(0..9)}",
      company_id: company.id
    )
  end
end

# Creando purchase orders
puts "Creando purchase orders..."

# Distribución mensual de órdenes (total 60)
monthly_distribution = {
  1 => 4,  # Enero
  2 => 3,  # Febrero
  3 => 4,  # Marzo
  4 => 4,  # Abril
  5 => 4,  # Mayo
  6 => 5,  # Junio
  7 => 8,  # Julio
  8 => 4,  # Agosto
  9 => 4,  # Septiembre
  10 => 5, # Octubre
  11 => 7, # Noviembre
  12 => 3  # Diciembre (reducido porque solo son 10 días)
}

# Ajuste de inflación mensual (estimado 2024)
def apply_monthly_inflation(price, month)
  inflation_rate = 1 + (0.12 * (month - 1) / 12.0) # 12% anual estimado
  (price * inflation_rate).round
end

created_companies.each do |company|
  suppliers = Supplier.where(company_id: company.id)
  products = Product.where(company_id: company.id)

  monthly_distribution.each do |month, quantity|
    quantity.times do
      date = if month == 12
        Date.new(2024, 12, rand(1..10))  # En diciembre, solo del 1 al 10
      else
        Date.new(2024, month, rand(1..28))
      end
      supplier = suppliers.sample

      selected_products = []
      total_price = 0

      # Seleccionar entre 2 y 5 productos y calcular el total
      rand(2..5).times do
        product = products.sample
        quantity = rand(1..10)

        # Ajustar precio según el mes y aplicar descuento por mayorista
        base_price = product.price.to_i
        adjusted_price = apply_monthly_inflation(base_price, month)
        wholesale_price = (adjusted_price * 0.85).round # 15% descuento mayorista

        selected_products << {
          product: product,
          quantity: quantity,
          unit_price: wholesale_price # Precio mayorista
        }

        total_price += quantity * wholesale_price
      end

      # Crear la purchase con el total_price calculado
      purchase = Purchase.create!(
        order_date: date,
        expected_delivery_date: [date + rand(5..15).days, Date.new(2024, 12, 11)].min,
        supplier_id: supplier.id,
        company_id: company.id,
        total_price: total_price
      )

      # Crear los detalles de la compra
      selected_products.each do |item|
        PurchaseDetail.create!(
          purchase_id: purchase.id,
          product_id: item[:product].id,
          quantity: item[:quantity],
          unit_price: item[:unit_price]
        )
      end
    end
  end
end

# Actualizar stock después de las compras
puts "Actualizando stock después de las compras..."
Product.all.each do |product|
  # Calcular entradas totales de las compras
  total_purchased = PurchaseDetail.joins(:purchase)
                                .where(product_id: product.id)
                                .where('purchases.company_id = ?', product.company_id)
                                .sum(:quantity)

  # Actualizar el stock del producto
  product.update!(stock: total_purchased)
end

# Ahora las sales orders con el stock actualizado
puts "Creando sales orders..."

# Distribución para todo 2024
monthly_distribution = {
  1 => 6,   # Enero
  2 => 5,   # Febrero
  3 => 6,   # Marzo
  4 => 6,   # Abril
  5 => 6,   # Mayo
  6 => 8,   # Junio
  7 => 12,  # Julio
  8 => 6,   # Agosto
  9 => 6,   # Septiembre
  10 => 8,  # Octubre
  11 => 9,  # Noviembre
  12 => 4   # Diciembre (reducido porque solo son 10 días)
}

payment_methods = %w[cash credit_card transfer]

# Verificar y actualizar stock inicial
puts "Verificando stock inicial..."
Product.all.each do |product|
  purchased_quantity = PurchaseDetail.joins(:purchase)
                                   .where(product_id: product.id)
                                   .sum(:quantity)
  product.update!(stock: purchased_quantity)
end

total_purchases = Purchase.sum(:total_price)
puts "Total de compras: $#{total_purchases}"

created_companies.each do |company|
  customers = Customer.where(company_id: company.id)

  monthly_distribution.each do |month, quantity|
    quantity.times do
      proposed_date = if month == 12
        Date.new(2024, 12, rand(1..10))  # En diciembre, solo del 1 al 10
      else
        Date.new(2024, month, rand(1..28))
      end
      next if proposed_date > Date.today

      customer = customers.sample

      # Obtener productos con stock disponible
      available_products = Product.where(company_id: company.id)
                                .where('stock > 0')
                                .to_a

      next if available_products.empty?

      selected_products = []
      total_price = 0

      rand(2..4).times do
        product = available_products.sample
        next unless product && product.stock > 0

        # Asegurar que no excedemos el stock disponible
        max_quantity = [ product.stock, 3 ].min
        quantity = rand(1..max_quantity)

        base_price = product.price.to_i
        adjusted_price = apply_monthly_inflation(base_price, month)
        retail_price = (adjusted_price * 1.65).round

        selected_products << {
          product: product,
          quantity: quantity,
          unit_price: retail_price
        }

        total_price += quantity * retail_price

        # Actualizar stock disponible en memoria
        product.stock -= quantity
        available_products.reject! { |p| p.stock <= 0 }
      end

      next if selected_products.empty?

      # Crear la venta
      sale = Sale.create!(
        sale_date: proposed_date,
        payment_method: payment_methods.sample,
        customer_id: customer.id,
        total_price: total_price
      )

      # Crear los detalles y actualizar stock en la base de datos
      selected_products.each do |item|
        SaleDetail.create!(
          sale_id: sale.id,
          product_id: item[:product].id,
          quantity: item[:quantity],
          unit_price: item[:unit_price]
        )

        # Actualizar stock en la base de datos
        item[:product].save!
      end
    end
  end
end

total_sales = Sale.sum(:total_price)
puts "Total de ventas: $#{total_sales}"
puts "Margen bruto: $#{total_sales - total_purchases}"
puts "Margen porcentual: #{((total_sales.to_f / total_purchases.to_f - 1) * 100).round(2)}%"

puts "Sales orders creadas exitosamente!"

puts "Seed completado exitosamente!"
