import http.client
import json
import csv
import time
import random
from uuid import uuid4

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
    ("jalepeno", "Fresh Vegetables"),
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
    ("sweetcorn", "Fruits and Berries"),
    ("grapes", "Fruits and Berries"),
    ("watermelon", "Fruits and Berries"),
    ("kiwi", "Fruits and Berries"),
    ("pomegranate", "Fruits and Berries"),
    ("pear", "Fruits and Berries"),
    ("lemon", "Fruits and Berries") ]
''',
    ("Wheat", "Grains"),
    ("Rice", "Grains"),
    ("Barley", "Grains"),
    ("Oats", "Grains"),
    ("Corn", "Grains"),
    ("Quinoa", "Grains"),
    ("Buckwheat", "Grains"),
    ("Millet", "Grains"),
    ("Sorghum", "Grains"),
    ("Spelt", "Grains"),
    ("Triticale", "Grains"),
    ("Farro", "Grains"),
    ("Amaranth", "Grains"),
    ("Rye", "Grains"),
    ("Teff", "Grains"),
    ("Wild Rice", "Grains"),
    ("Kamut", "Grains"),
    ("Freekeh", "Grains"),
    ("Einkorn", "Grains"),
    ("Emmer", "Grains"),
    ("Chickpeas", "Pulses"),
    ("Lentils", "Pulses"),
    ("Black Beans", "Pulses"),
    ("Kidney Beans", "Pulses"),
    ("Pinto Beans", "Pulses"),
    ("Soybeans", "Pulses"),
    ("Green Peas", "Pulses"),
    ("Split Peas", "Pulses"),
    ("Adzuki Beans", "Pulses"),
    ("Mung Beans", "Pulses"),
    ("Urad Beans", "Pulses"),
    ("Cannellini Beans", "Pulses"),
    ("Fava Beans", "Pulses"),
    ("Chesnuts", "Pulses"),
    ("Borlotti Beans", "Pulses"),
    ("Navy Beans", "Pulses"),
    ("Tepary Beans", "Pulses"),
    ("Anasazi Beans", "Pulses"),
    ("Hyacinth Beans", "Pulses"),
    ("Black-eyed Peas", "Pulses"),
    ("Cranberry Beans", "Pulses"),
    ("Sunflower Seeds", "Oil Seeds"),
    ("Soybeans", "Oil Seeds"),
    ("Peanuts", "Oil Seeds"),
    ("Flax Seeds", "Oil Seeds"),
    ("Chia Seeds", "Oil Seeds"),
    ("Sesame Seeds", "Oil Seeds"),
    ("Mustard Seeds", "Oil Seeds"),
    ("Canola Seeds", "Oil Seeds"),
    ("Pumpkin Seeds", "Oil Seeds"),
    ("Poppy Seeds", "Oil Seeds"),
    ("Hemp Seeds", "Oil Seeds"),
    ("Walnut Seeds", "Oil Seeds"),
    ("Almond Seeds", "Oil Seeds"),
    ("Cotton Seeds", "Oil Seeds"),
    ("Rapeseed", "Oil Seeds"),
    ("Borage Seeds", "Oil Seeds"),
    ("Jojoba Seeds", "Oil Seeds"),
    ("Perilla Seeds", "Oil Seeds"),
    ("Guar Gum", "Oil Seeds"),
    ("Tung Oil Seeds", "Oil Seeds"),
    ("Olive Oil", "Oils"),
    ("Coconut Oil", "Oils"),
    ("Canola Oil", "Oils"),
    ("Sunflower Oil", "Oils"),
    ("Sesame Oil", "Oils"),
    ("Peanut Oil", "Oils"),
    ("Grapeseed Oil", "Oils"),
    ("Avocado Oil", "Oils"),
    ("Walnut Oil", "Oils"),
    ("Safflower Oil", "Oils"),
    ("Corn Oil", "Oils"),
    ("Rice Bran Oil", "Oils"),
    ("Flaxseed Oil", "Oils"),
    ("Mustard Oil", "Oils"),
    ("Palm Oil", "Oils"),
    ("Hazelnut Oil", "Oils"),
    ("Almond Oil", "Oils"),
    ("Soybean Oil", "Oils"),
    ("Cottonseed Oil", "Oils"),
    ("Poppy Seed Oil", "Oils"),
    ("Jojoba Oil", "Oils")
]'''

# Function to fetch image URL
def fetch_image_url(query):
    try:
        '''create a code snippet that the data is in path like Dataset/query that can contain any no
           of images so take the length of the images and image names like Image_1,Image_2,.....Image_n 
           from that take a random one image'''
    except Exception as e:
        print(f"Error fetching image for {query}: {e}")
    return ""

# Function to fetch nutritional data
def fetch_nutritional_data(query):
    try:
        '''the csv data having the fields so could please retrieve return the data
        '''
    except Exception as e:
        print(f"Error fetching nutritional data for {query}: {e}")
    return ""

# Generate 10,000 rows
output_data = []

for i in range(950):
    query = random.choice(queries)
    productname, category = query

    productid = str(uuid4())
    farmerid = "FAR-"+"" #sempty string will contain the same farmername
    farmername = "" #give some indian based random names
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
        "imageurl": imageurl,
        "quantity": quantity,
        "category": category,
        "description": description,
        "star": star
    })

    # Avoid hitting API rate limits
    time.sleep(0.5)

# Save data to CSV
csv_file = "products_data.csv"
fieldnames = ["productid", "productname", "farmerid", "farmername", "price", "discountedprice", "imageurl", "quantity", "category", "description", "star"]

with open(csv_file, mode="w", newline="", encoding="utf-8") as file:
    writer = csv.DictWriter(file, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(output_data)

print(f"Data generation complete. Saved to {csv_file}")