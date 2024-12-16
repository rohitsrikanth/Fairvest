import http.client
import json
import csv
import time
import random
from uuid import uuid4
import os
import pandas as pd
# Queries for fetching data
queries = [
    ("sweetpotato", "Fresh Vegetables"),
    ("raddish", "Fresh Vegetables"),
    ("potato", "Fresh Vegetables"),
    ("carrot", "Fresh Vegetables"),
    ("spinach", "Fresh Vegetables"),
    ("tomato", "Fresh Vegetables"),
    ("turnip", "Fresh Vegetables"),
    ("peas", "Fresh Vegetables"),
    ("soy beans", "Fresh Vegetables"),
    ("jalapeno", "Fresh Vegetables"),
    ("lettuce", "Fresh Vegetables"),
    ("onion", "Fresh Vegetables"),
    ("cauliflower", "Fresh Vegetables"),
    ("chilli pepper", "Fresh Vegetables"),
    ("corn", "Fresh Vegetables"),
    ("cucumber", "Fresh Vegetables"),
    ("eggplant", "Fresh Vegetables"),
    ("garlic", "Fresh Vegetables"),
    ("ginger", "Fresh Vegetables"),
    ("beetroot", "Fresh Vegetables"),
    ("bell pepper", "Fresh Vegetables"),
    ("cabbage", "Fresh Vegetables"),
    ("capsicum", "Fresh Vegetables"),
    ("apple", "Fruits and Berries"),
    ("banana", "Fruits and Berries"),
    ("orange", "Fruits and Berries"),
    ("mango", "Fruits and Berries"),
    ("pineapple", "Fruits and Berries"),
    ("grapes", "Fruits and Berries"),
    ("watermelon", "Fruits and Berries"),
    ("kiwi", "Fruits and Berries"),
    ("pomegranate", "Fruits and Berries"),
    ("pear", "Fruits and Berries"),
    ("lemon", "Fruits and Berries")
]

# Define a directory path for datasets
dataset_dir = r"C:\Users\91956\Downloads\Dataset"

# Function to fetch image URL
def fetch_image_url(query):
    try:
        # Build the directory path
        base_path = dataset_dir
        category_path = os.path.join(base_path, category, productname)
        
        # Check if the directory exists
        if os.path.exists(category_path) and os.path.isdir(category_path):
            # List all image files in the directory
            image_files = [f for f in os.listdir(category_path) if os.path.isfile(os.path.join(category_path, f))]
            
            # If there are any images, randomly select one
            if image_files:
                random_image = random.choice(image_files)
                return os.path.join(category_path, random_image)
            else:
                print(f"No images found for {productname} in {category_path}")
                return ""
        else:
            print(f"Directory does not exist for {productname} in {category_path}")
            return ""
    except Exception as e:
        print(f"Error fetching image for {productname}: {e}")
        return ""

# Function to fetch nutritional data
def fetch_nutritional_data(query):
    try:
        # Correct file path
        file_path = r"C:\Users\91956\Downloads\Product_Catalog.csv"

        # Check if the file exists
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"The file does not exist: {file_path}")

        # Load the CSV file into a DataFrame
        data = pd.read_csv(file_path)

        # Ensure 'Product Name' and 'Description' columns exist
        if "Product Name" not in data.columns or "Description" not in data.columns:
            raise KeyError("The required columns ('Product Name' and 'Description') are not present in the CSV file.")

        # Filter the data to find the matching product name
        matched_row = data[data["Product Name"] == query]

        # Return the description if a match is found
        if not matched_row.empty:
            return matched_row.iloc[0]["Description"]
        else:
            print(f"No description found for product: {query}")
            return ""
    except Exception as e:
        print(f"Error fetching nutritional data for {query}: {e}")
        return ""

# Function to generate random Indian farmer names
def generate_farmer_name():
    first_names = ["Raj", "Amit", "Vikram", "Ramesh", "Suresh", "Anil", "Manoj", "Dinesh", "Sunil", "Prakash"]
    last_names = ["Patel", "Sharma", "Gupta", "Yadav", "Kumar", "Jain", "Rao", "Joshi", "Deshmukh", "Singh"]
    return f"{random.choice(first_names)} {random.choice(last_names)}"

# Generate 1000 rows
output_data = []

for i in range(1000):
    query = random.choice(queries)
    productname, category = query
    na = generate_farmer_name()
    productid = str(uuid4())
    farmerid = f"FAR-"+na.split()[0]+na.split()[1]
    farmername = na
    price = round(random.uniform(10, 100), 2)
    discountedprice = round(price * random.uniform(0.7, 0.9), 2)
    imageurl = fetch_image_url(productname)
    quantity = random.randint(1, 50)
    description = fetch_nutritional_data(productname)
    star = round(random.uniform(3.0, 5.0), 1)

    output_data.append({
        "productid": productid,
        "productname": productname,
        "farmerid": farmerid,
        "farmername": farmername,
        "price": price,
        "discountedprice": discountedprice,
        "image_path": imageurl,
        "quantity": quantity,
        "category": category,
        "description": description,
        "star": star
    })

    # Avoid hitting API rate limits (if integrated in the future)
    time.sleep(0.1)

# Save data to CSV
csv_file = "dataset.csv"
fieldnames = ["productid", "productname", "farmerid", "farmername", "price", "discountedprice", "image_path", "quantity", "category", "description", "star"]

with open(csv_file, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(output_data)

print(f"Data generation complete. Saved to {csv_file}")
