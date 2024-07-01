import os
import pymysql
from faker import Faker
import boto3
import json
import random
from mysql_commands import sql_commands, product_names

# Getting useful variables
aws_region = os.getenv('AWS_REGION_USED')
mysql_user = os.getenv('MYSQL_USER')
mysql_host = os.getenv('MYSQL_HOST')
mysql_db = os.getenv('MYSQL_DB')
aws_project_prefix = os.getenv('AWS_PROJECT_PREFIX')
 
# Function to get RDS MySQL password from secrets manager  
def get_rds_password(region_name=aws_region, project_tags=None):

    session = boto3.session.Session()
    secret_client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    
    # Using tags to get secrets
    formatted_tags = []
    for k, v in project_tags.items():
        formatted_tags.append({'Key': 'tag-key', 'Values': [k]})
        formatted_tags.append({'Key': 'tag-value', 'Values': [v]})
    
    secret_name = secret_client.list_secrets(
        Filters=formatted_tags
    )['SecretList'][0]['Name']
    
    try:
        get_secret_value_response = secret_client.get_secret_value(
            SecretId=secret_name
        )
        secret_password = json.loads(get_secret_value_response['SecretString'])['password']
        return secret_password
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

# Function to connect to Mysql database
def connect_to_database(sql_lib, user, passaword, host, db):
    try:
        conn = sql_lib.connect(
            host=host,
            user=user,
            password=passaword,
            database=db,
            connect_timeout=5
        )
    except Exception as e:
        print(f"Error: {str(e)}")
    
    return conn

# Function to drop existing tables
def drop_tables(cur):
    try:
        # Temporarily disable foreign key checks
        cur.execute("SET FOREIGN_KEY_CHECKS = 0")

        # Getting all tables
        cur.execute("SHOW TABLES")
        tables = cur.fetchall()

        # Delete all tables
        if tables:
            for table in tables:
                table_name = table[0]
                cur.execute(f"DROP TABLE IF EXISTS {table_name}")

        # Enable foreign key checks again
        cur.execute("SET FOREIGN_KEY_CHECKS = 1")
    except Exception as e:
        print(f"Error while dropping tables: {e}")


# Function to populate MySQL database
def populate_rds(event, context):
    
    mysql_tags = {"Project": aws_project_prefix, "Database": "mysql"}
    mysql_password = get_rds_password(aws_region, mysql_tags)
    mysql_conn = connect_to_database(pymysql, mysql_user, mysql_password, mysql_host, mysql_db)
    
    # Deleting all existing tables
    with mysql_conn.cursor() as cur:
        drop_tables(cur)
    mysql_conn.commit()
    
    # Creatinng all tables
    with mysql_conn.cursor() as cur:
        for k, v in sql_commands.items():
            print(f"Creating the table {k}")
            cur.execute(v)
    mysql_conn.commit()
    
    # Creating data with faker
    fake = Faker('pt_BR')
    with mysql_conn.cursor() as cur:
        # Insert data into clients table
        nclients = event.get('nclients', 100)
        for _ in range(nclients):
            firstname = fake.first_name()
            lastname = fake.last_name()
            birth_date = fake.date_of_birth()
            email = fake.unique.email()
            phone = fake.phone_number()
            
            cur.execute("INSERT INTO clients (firstname, lastname, birth_date, email, phone) VALUES (%s, %s, %s, %s, %s)",
                        (firstname, lastname, birth_date, email, phone))

        mysql_conn.commit()
        
        # Insert data into client_addresses table
        cur.execute("SELECT client_id FROM clients")
        client_ids = [row[0] for row in cur.fetchall()]

        for client_id in client_ids:
            state = fake.state_abbr()
            city = fake.city()
            street = fake.street_address()
            zip_code = fake.postcode()
            
            cur.execute("INSERT INTO client_addresses (client_id, state, city, street, zip_code) VALUES (%s, %s, %s, %s, %s)",
                        (client_id, state, city, street, zip_code))

        mysql_conn.commit()
        
        # Insert data into sales_people table
        n_people_sales = event.get('n_people_sales', 20)
        for _ in range(n_people_sales):
            firstname = fake.first_name()
            lastname = fake.last_name()
            email = fake.unique.email()
            phone_number = fake.phone_number()
            
            cur.execute("INSERT INTO sales_people (firstname, lastname, email, phone_number) VALUES (%s, %s, %s, %s)",
                        (firstname, lastname, email, phone_number))
        mysql_conn.commit()
    
        # Insert data into products table
        for _ in product_names:
            description = fake.text()
            price = round(random.uniform(1, 10), 1)
            
            cur.execute("INSERT INTO products (product_name, description, price) VALUES (%s, %s, %s)",
                        (_, description, price))

        mysql_conn.commit()
        
        # Insert data into sales table
        cur.execute("SELECT client_id FROM clients")
        client_ids = [row[0] for row in cur.fetchall()]

        cur.execute("SELECT salesperson_id FROM sales_people")
        salesperson_ids = [row[0] for row in cur.fetchall()]

        n_sales = event.get("n_sales", 1000)
        for _ in range(n_sales):
            client_id = fake.random_element(elements=client_ids)
            salesperson_id = fake.random_element(elements=salesperson_ids)
            sale_date = fake.date_this_year()
            
            cur.execute("INSERT INTO sales (client_id, salesperson_id, sale_date, total_amount) VALUES (%s, %s, %s, %s)",
                        (client_id, salesperson_id, sale_date, 0))

        mysql_conn.commit()

        # Insert data into sales_items table
        cur.execute("SELECT sale_id FROM sales")
        sale_ids = [row[0] for row in cur.fetchall()]

        cur.execute("SELECT product_id, price FROM products")
        products = {row[0]: row[1] for row in cur.fetchall()}

        sale_totals = {}
        for sale_id in sale_ids:
            total_amount_cum = 0
            for _ in range(fake.random_int(min=1, max=3)):
                product_id = fake.random_element(elements=list(products.keys()))
                quantity = fake.random_int(min=1, max=10)
                original_price  = float(products[product_id])
                discount_perc = fake.random_int(min=0, max=15) / 100
                discount = round(original_price*discount_perc, 2)
                unit_price = round(original_price * (1 - discount_perc), 2)
                total_amount = round(unit_price * quantity, 2)
                total_amount_cum += total_amount
                cur.execute("INSERT INTO sales_items (sale_id, product_id, quantity, unit_price, total_amount, discount) VALUES (%s, %s, %s, %s, %s, %s)",
                            (sale_id, product_id, quantity, unit_price, total_amount, discount))
                
            sale_totals[sale_id] = total_amount_cum
            
        mysql_conn.commit()

        # Updating sales total price 
        for sale_id, total in sale_totals.items():
            cur.execute("UPDATE sales SET total_amount = %s WHERE sale_id = %s", (total, sale_id))

        mysql_conn.commit()