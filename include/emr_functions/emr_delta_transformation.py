silver_transformation_sql = {
    "clients": """
        SELECT 
            client_id,
            firstname,
            lastname,
            CONCAT(firstname, ' ', lastname) AS full_name,
            birth_date,
            FLOOR(DATEDIFF(CURRENT_DATE, birth_date) / 365.25) AS age,
            CASE 
                WHEN FLOOR(DATEDIFF(CURRENT_DATE, birth_date) / 365.25) < 15 THEN 'children'
                WHEN FLOOR(DATEDIFF(CURRENT_DATE, birth_date) / 365.25) < 25 THEN 'teenager'
                WHEN FLOOR(DATEDIFF(CURRENT_DATE, birth_date) / 365.25) < 65 THEN 'adult'
                ELSE 'senior'
            END AS age_group,
            email,
            phone
        FROM clients
    """,
    "sales_people": """
        SELECT
            salesperson_id,
            firstname,
            lastname,
            CONCAT(firstname, ' ', lastname) AS full_name,
            email,
            phone_number
        FROM sales_people
    """,
    "sales":"""
        SELECT
            sale_id,
            client_id,
            salesperson_id,
            sale_date,
            MONTH(sale_date) AS sale_month,
            DAY(sale_date) AS sale_day,
            total_amount
        FROM sales
    """,
    "sales_items":"""
        SELECT
            *
        FROM sales_items
    """,
    "products":"""
        SELECT
            *
        FROM products
    """
}

gold_transformation = {
    "sales_people_by_total":{
        "tables": ['sales', 'sales_people'],
        "sql": """
            WITH transf_1 AS (
                SELECT
                    s.sale_id,
                    s.salesperson_id,
                    sp.full_name,
                    s.sale_date,
                    s.total_amount
                FROM sales AS s
                LEFT JOIN sales_people AS sp 
                ON s.salesperson_id = sp.salesperson_id
            )
                SELECT 
                    salesperson_id,
                    full_name,
                    SUM(total_amount) AS total_sales
                FROM transf_1
                GROUP BY 1, 2
                ORDER BY 3 DESC
        """    
    },
    "sales_people_by_month":{
        "tables": ['sales', 'sales_people'],
        "sql":"""
            WITH transf_1 AS (
                SELECT
                    s.sale_id,
                    s.salesperson_id,
                    sp.full_name,
                    s.sale_month,
                    s.total_amount
                FROM sales AS s
                LEFT JOIN sales_people AS sp 
                ON s.salesperson_id = sp.salesperson_id
            )
                SELECT
                    salesperson_id, 
                    full_name,
                    sale_month,
                    SUM(total_amount) AS total_sales
                FROM transf_1
                GROUP BY 1, 2, 3
                ORDER BY 4 DESC
        """
    },
    "sales_people_by_product":{
        "tables": ['sales', 'sales_people', 'sales_items', 'products'],
        "sql":"""
            SELECT
                s.salesperson_id,
                sp.full_name,
                p.product_name,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN sales_people AS sp ON s.salesperson_id = sp.salesperson_id
            LEFT JOIN sales_items AS si ON s.sale_id = si.sale_id
            LEFT JOIN products AS p ON si.product_id = p.product_id
            GROUP BY 1, 2, 3
            ORDER BY 4 DESC
        """
    },
    "sales_people_by_product_month":{
        "tables": ['sales', 'sales_people', 'sales_items', 'products'],
        "sql":"""
            SELECT
                s.salesperson_id,
                sp.full_name,
                p.product_name,
                s.sale_month,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN sales_people AS sp ON s.salesperson_id = sp.salesperson_id
            LEFT JOIN sales_items AS si ON s.sale_id = si.sale_id
            LEFT JOIN products AS p ON si.product_id = p.product_id
            GROUP BY 1, 2, 3, 4
            ORDER BY 5 DESC
        """
    },
    "top_selling_products":{
        "tables": ['sales', 'sales_people', 'sales_items', 'products'],
        "sql":"""
            SELECT
                si.product_id,
                p.product_name,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN sales_people AS sp ON s.salesperson_id = sp.salesperson_id
            LEFT JOIN sales_items AS si ON s.sale_id = si.sale_id
            LEFT JOIN products AS p ON si.product_id = p.product_id
            GROUP BY 1, 2
            ORDER BY 3 DESC
        """
    },
    "top_selling_products_by_month":{
        "tables": ['sales', 'sales_people', 'sales_items', 'products'],
        "sql":"""
            SELECT
                si.product_id,
                p.product_name,
                s.sale_month,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN sales_people AS sp ON s.salesperson_id = sp.salesperson_id
            LEFT JOIN sales_items AS si ON s.sale_id = si.sale_id
            LEFT JOIN products AS p ON si.product_id = p.product_id
            GROUP BY 1, 2, 3
            ORDER BY 4 DESC
        """
    },
    "top_spending_clients":{
        "tables": ['sales', 'clients'],
        "sql":"""
            SELECT
                s.client_id,
                c.full_name,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN clients AS c ON s.client_id = c.client_id
            GROUP BY 1, 2
            ORDER BY 3 DESC
        """
    },
    "top_spending_clients_by_age_group":{
        "tables": ['sales', 'clients'],
        "sql":"""
            SELECT
                c.age_group,
                SUM(s.total_amount) AS total_sales
            FROM sales AS s
            LEFT JOIN clients AS c ON s.client_id = c.client_id
            GROUP BY 1
            ORDER BY 2 DESC
        """
    }
}