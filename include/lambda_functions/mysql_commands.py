sql_commands = {
    "clients": """
        CREATE TABLE IF NOT EXISTS clients (
            client_id INT AUTO_INCREMENT PRIMARY KEY,
            firstname VARCHAR(30),
            lastname VARCHAR(30),
            birth_date DATE,
            email VARCHAR(100) UNIQUE,
            phone CHAR(14)
        );
    """,
    "client_addresses": """
        CREATE TABLE IF NOT EXISTS client_addresses (
            address_id INT AUTO_INCREMENT PRIMARY KEY,
            client_id INT,
            state CHAR(2),
            city VARCHAR(100),
            street VARCHAR(150),
            zip_code VARCHAR(20),
            FOREIGN KEY (client_id) REFERENCES clients(client_id)
        );
    """,
    "sales_people": """
        CREATE TABLE IF NOT EXISTS sales_people (
            salesperson_id INT AUTO_INCREMENT PRIMARY KEY,
            firstname VARCHAR(30),
            lastname VARCHAR(30),
            email VARCHAR(100) UNIQUE,
            phone_number VARCHAR(20)
        );
    """,
    "sales": """
        CREATE TABLE IF NOT EXISTS sales (
            sale_id INT AUTO_INCREMENT PRIMARY KEY,
            client_id INT,
            salesperson_id INT,
            sale_date DATE,
            total_amount DECIMAL(10, 2),
            FOREIGN KEY (client_id) REFERENCES clients(client_id),
            FOREIGN KEY (salesperson_id) REFERENCES sales_people(salesperson_id)
        );
    """,
    "sales_items": """
        CREATE TABLE IF NOT EXISTS sales_items (
            item_id INT AUTO_INCREMENT PRIMARY KEY,
            sale_id INT,
            product_id INT,
            quantity INT,
            unit_price DECIMAL(10, 2),
            total_amount DECIMAL(10, 2),
            discount DECIMAL(10, 2),
            FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
        );
    """,
    "products": """
        CREATE TABLE IF NOT EXISTS products (
            product_id INT AUTO_INCREMENT PRIMARY KEY,
            product_name VARCHAR(150),
            description TEXT,
            price DECIMAL(10, 2)
        );
    """
}

product_names = [
    "Camiseta", "Calça Jeans", "Tênis", "Jaqueta", "Moletom", "Suéter", "Bermuda", "Vestido", "Saia", "Blusa",
    "Camisa Polo", "Regata", "Boné", "Touca", "Luvas", "Cachecol", "Cinto", "Óculos de Sol", "Relógio", "Pulseira",
    "Colar", "Anel", "Brincos", "Mochila", "Bolsa", "Carteira", "Meias", "Cueca", "Biquíni", "Chinelo",
    "Botas", "Sandálias", "Pantufas", "Leggings", "Agasalho", "Macacão", "Macaquinho", "Jardineira", "Cardigã", "Blazer",
    "Terno", "Gravata", "Gravata Borboleta", "Abotoaduras", "Chapéu", "Poncho", "Pijama", "Camisola", "Roupão", "Roupas de Lazer"
]