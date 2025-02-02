from flask import Flask, request, jsonify ,send_from_directory
from pymongo import MongoClient
from flask_cors import CORS
import re
import traceback
import http
from werkzeug.utils import secure_filename
from datetime import datetime
import os
from flask_pymongo import PyMongo
from bson import ObjectId  # Ensure proper handling of MongoDB ObjectId
from urllib.parse import quote
import requests
import json
from PIL import Image
import numpy as np
import tensorflow as tf
import io
import logging
from transformers import pipeline, AutoModelForSequenceClassification, AutoTokenizer
from datetime import datetime
app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={r"/*": {"origins": "*"}})
buyer_data = {}
user_name = ""
seller_data ={}
user_id=""
# Replace Atlas connection string with the localhost connection for MongoDB Community Edition

# Retrieve API key from environment variables
GOOEY_API_KEY = "sk-mDh5agIgaFIsKL5bljdb1WAixSSc2rokstxWR3Qm5FBMJaRg"

if not GOOEY_API_KEY:
    raise ValueError("API Key is missing. Please set GOOEY_API_KEY in environment variables.")

classifier = pipeline("zero-shot-classification", model="facebook/bart-large-mnli")


def is_farming_related(prompt): 
    labels = ["farming", "agriculture", "crops"] 
    result = classifier(prompt, labels) 
    print(result["scores"])
    return max(result["scores"]) > 0.4

def req(prompt):
    payload = {
        "input_prompt": prompt
    }
    if is_farming_related(prompt): 
        try:
            response = requests.post(
            "https://api.gooey.ai/v2/video-bots",
            headers={
                "Authorization": f"bearer {GOOEY_API_KEY}",
            },
            json=payload,
            )

        # Ensure the request was successful
            response.raise_for_status()

            result = response.json()
            output_text = result.get("output", {}).get("output_text", "No output found.")
            print(output_text)
            return output_text

        except requests.exceptions.RequestException as e:
            print(f"Request failed: {e}")
            return "There was an error with the request."

    else: 
        response = {"response": "This API only responds to farming-related queries. Please ask a farming-related question."}
        
        return response
    

@app.route('/ask', methods=['POST'])
def ask():
    data = request.json
    question = data.get('question')
    
    if not question:
        return jsonify({"error": "Question is required."}), 400
    print(question)
    # Process the question and generate a response
    response_text = req(question)
    print(response_text)
    # Return the response
    return jsonify({"response": response_text})

CONNECTION_STRING = "mongodb://localhost:27017/"  # Default local MongoDB URI
client = MongoClient(CONNECTION_STRING)

# Access your database
db = client["Fairvest"]

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# Set up paths
working_dir = os.path.dirname(os.path.abspath(__file__))
model_path = os.path.join(working_dir, "assets", "model", "plant_disease_prediction_model.h5")
class_indices_path = os.path.join(working_dir, "assets", "model", "class_indices.json")

# Validate and load the pre-trained model
if not os.path.exists(model_path):
    raise FileNotFoundError(f"Model file not found at {model_path}")

if not os.path.exists(class_indices_path):
    raise FileNotFoundError(f"Class indices file not found at {class_indices_path}")

try:
    model = tf.keras.models.load_model(model_path, compile=False)
    logger.info("Model loaded successfully.")
except Exception as e:
    logger.error(f"Failed to load model: {e}")
    raise

try:
    with open(class_indices_path, 'r') as f:
        class_indices = json.load(f)
    logger.info("Class indices loaded successfully.")
except Exception as e:
    logger.error(f"Failed to load class indices: {e}")
    raise


# Function to load and preprocess the image
def load_and_preprocess_image(image, target_size=(224, 224)):
    try:
        if isinstance(image, str):
            if not os.path.exists(image):
                raise FileNotFoundError(f"The file at {image} was not found.")
            img = Image.open(image).convert('RGB')
        else:
            img = image.convert('RGB')

        img = img.resize(target_size)
        img_array = np.array(img)
        img_array = np.expand_dims(img_array, axis=0)
        img_array = img_array.astype('float32') / 255.0
        return img_array
    except Exception as e:
        logger.error(f"Error in preprocessing image: {e}")
        raise ValueError("Failed to preprocess image. Please provide a valid image file.")


# Function to predict the class of an image
def predict_image_class(image, model, class_indices):
    try:
        preprocessed_img = load_and_preprocess_image(image)
        predictions = model.predict(preprocessed_img)
        predicted_class_index = np.argmax(predictions, axis=1)[0]
        predicted_class_name = class_indices[str(predicted_class_index)]
        return predicted_class_name
    except Exception as e:
        logger.error(f"Prediction failed: {e}")
        raise


# API Endpoint for prediction
@app.route('/predict', methods=['POST'])
def predict_endpoint():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided. Please upload an image."}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "No file selected. Please upload a valid image file."}), 400

    if not file.filename.lower().endswith(('png', 'jpg', 'jpeg')):
        return jsonify({"error": "Unsupported file type. Please upload PNG, JPG, or JPEG files."}), 400

    try:
        # Open the uploaded image
        image = Image.open(io.BytesIO(file.read()))
        
        # Perform prediction
        prediction = predict_image_class(image, model, class_indices)
        
        # Create response
        response = {
            "prediction": prediction
        }
        return jsonify(response), 200
    except Exception as e:
        logger.error(f"Error during prediction: {e}")
        return jsonify({"error": "An error occurred during prediction. Please try again."}), 500
    
# Function to check if collection exists, and if not, create it
# def ensure_collection_exists(collection_name):
#     if collection_name not in db.list_collection_names():
#         db.create_collection(collection_name)

# # Ensure 'buyers' and 'sellers' collections exist
# ensure_collection_exists("buyers")
# ensure_collection_exists("sellers")
# ensure_collection_exists("uploads")
# ensure_collection_exists("orders")
buyers_collection = db["buyers"]
sellers_collection = db["sellers"]
uploads_collection = db["uploads"]
uploads_collection = db["uploads"]
orders_collection = db["orders"]
pnc_collection = db["pnc"]
# Validate buyer data
def validate_buyer(data):
    required_fields = ["name", "email", "phone", "password"]
    missing_fields = [field for field in required_fields if field not in data]

    if missing_fields:
        return False, f"Missing fields: {', '.join(missing_fields)}"
    
    user =buyers_collection.find_one({"name" : data.get("name")})
    if user:
        return False, "User Name exist! Please try different Name"
    # Validate email
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_pattern, data.get("email", "")):
        return False, "Invalid email address"

    # Validate phone number
    phone_pattern = r'^\+91[6-9]\d{9}$' 
    phone_number = data.get("phone", "") 
    print(phone_number)
    if not re.match(phone_pattern, phone_number): 
        return False,"Invalid phone number"

    # Validate password
    if len(data.get("password", "")) < 6:
        return False, "Password must be at least 6 characters long"

    return True, "Valid data"

# Schema for Sellers
def validate_seller(data):
    required_fields = ["business_type", "name", "phone", "password"]
    missing_fields = [field for field in required_fields if field not in data]
    phone_pattern = r'^\+91[6-9]\d{9}$' 
    phone_number = data.get("phone", "") 
    print(phone_number)
    if data.get("email"):
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, data.get("email", "")):
            return False, "Invalid email address"
    if not re.match(phone_pattern, phone_number): 
        return False,"Invalid phone number"
    if missing_fields:
        return False, f"Missing fields: {', '.join(missing_fields)}"
    return True, "Valid data"

# Buyer Routes
@app.route("/buyers_sign1", methods=["POST"])
def create_buyer():
    global buyer_data
    data = request.json
    print("Request data:", request.json)
    valid, message = validate_buyer(data)
    if not valid:
        print(message)
        return jsonify({"error": message}), 400
    buyer_data.update(data)
    return jsonify({"message": "Buyer created successfully"}),200

@app.route('/seller', methods=['GET'])
def get_seller():
    seller = sellers_collection.find_one({"_id": seller_data.get("_id")})
    if seller:
        return jsonify({
            "id": str(seller["_id"]),
            "name": seller["name"],
            "email": seller["email"],
            "phone": seller["phone"],
            "password": seller["password"],
            "business_type": seller["business_type"],
        })
    return jsonify({"message": "Seller not found"}), 404

# Update Seller Data
@app.route('/seller', methods=['PUT'])
def update_seller():
    data = request.get_json()
    
    updated_data = {
        "name": data.get("name"),
        "email": data.get("email"),
        "phone": data.get("phone"),
        "password": data.get("password"),
        "business_type": data.get("business_type"),
    }

    result = sellers_collection.update_one(
        {"_id": seller_data.get("_id")}, {"$set": updated_data}
    )

    if result.modified_count > 0:
        return jsonify({"message": "Seller info updated"})
    return jsonify({"message": "No changes made"}), 400

@app.route('/update_user', methods=['POST'])
def update_user():
    """Update user details based on _id, email, and name."""
    data = request.json  # Data sent from the frontend
    global buyer_data

    # Get the filter criteria
    user_id = buyer_data.get("_id")
    email = buyer_data.get("email")
    name = buyer_data.get("name")

    # Ensure all criteria are present
    if not user_id or not email or not name:
        return jsonify({"error": "Missing _id, email, or name in the request"}), 400

    # Fields to update
    updated_fields = {
        "name": data.get("name"),
        "email": data.get("email"),
        "phone": data.get("phone"),
        "password": data.get("password"),
        "address": data.get("address"),
        "type": data.get("type"),
    }

    # Update the document that matches all three conditions
    result = buyers_collection.update_one(
        {"_id": user_id, "email": email, "name": name},
        {"$set": updated_fields}
    )

    # Check if the update was successful
    if result.matched_count > 0:
        return jsonify({"message": "User updated successfully"}), 200
    return jsonify({"error": "No matching user found"}), 404


@app.route("/buyers_sign3", methods=["POST"])
def signup():
    global buyer_data
    try:
        # Get data from the request for step 3
        step3_data = request.json
        if not step3_data:
            return jsonify({"error": "Invalid data"}), 400
        
        def random_string(length=3): 
            letters = string.ascii_letters + string.digits 
            return ''.join(random.choice(letters) for i in range (length))
        buyer_data['_id']='C'+random_string()+buyer_data['name']
        # Update global buyer_data with step 3 details
        buyer_data.update(step3_data)
        print("Final buyer_data (after sign3):", buyer_data)

        # Validate the combined data
        required_fields = ["name", "email", "phone", "password", "address", "type"]
        missing_fields = [field for field in required_fields if field not in buyer_data]
        if missing_fields:
            return jsonify({"error": f"Missing fields: {', '.join(missing_fields)}"}), 400


        # Insert data into MongoDB
        buyers_collection.insert_one(buyer_data)

        # Clear global data after successful insertion
        buyer_data.clear()

        return jsonify({"message": "User details saved successfully!"}), 200
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500

@app.route("/buyers_login", methods=["POST"])
def buyers_login():
    global user_name
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    user_name = username
    
    # Search for the buyer by email, username, or phone
    buyer = buyers_collection.find_one({"$or": [{"email": username}, {"phone": username},{'_id': username}]})
    print(buyer)
    buyer_data.update(buyer)
    seller_data.clear()
    if buyer:
        # Compare password with stored hash
        if buyer['password'] == password:
            return jsonify({"message": "Login successful"}), 200
        else:
            return jsonify({"message": "Incorrect password"}), 401
    else:
        return jsonify({"message": "User not found"}), 404


@app.route('/getuser', methods=['GET'])
def get_user():
    global user_name
    print(user_name)
    try:
        # Query the MongoDB collection
        print("helo")
        user_data = buyers_collection.find_one({"$or": [{"email": user_name}, {"phone": user_name},{'_id': user_name}]})
        if user_data:
            # Remove the '_id' field if you don't want to expose it
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/get_users_list/<user>', methods=['GET']) 
def get_users_list(user): 
    print(user)
    if user == "Consumer": 
        data = buyers_collection.find({}) 
        sent_data = [] 
        for user in data: 
            purchase_history =[]
            purchase_history = [ order["products_id"] for order in orders_collection.find({"buyer_id": user["email"]}) ] 
            sent_data.append({ "id": user["email"], "name": user["name"], "profileImage": user.get("profileImage",""), "purchaseHistory": purchase_history}) 
            print(sent_data)
            return jsonify(sent_data), 200 
    else: 
        data = sellers_collection.find({"business_type": user}) 
        sent_data = [] 
        for seller in data: 
            sent_data.append({ "id": seller["_id"], "name": seller["name"], "profileImage": seller.get("profileImage",""), "sales_history": seller.get("sales_history","") }) 
        print(sent_data)
        return jsonify(sent_data),200
    

    
@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    data = request.json
    user_name = data.get("user_name")
    product_id = data.get("product_id")

    if not user_name or not product_id:
        return jsonify({"error": "Invalid input"}), 400

    user = buyers_collection.find_one({"$or": [{"email": user_name}, {"phone": user_name},{'_id': user_name},{'name':user_name}]})
    if not user:
        return jsonify({"error": "User not found"}), 404
    print(user)
    cart_item = next((item for item in user.get("cart", []) if item["product_id"] == product_id), None)
    if cart_item:
        # Update the quantity if the product is already in the cart
        result = buyers_collection.update_one(
            {"name": user_name, "cart.product_id": product_id},
            {"$inc": {"cart.$.quantity": 1}}
        )
    else:
        # Add the product to the cart
        result = buyers_collection.update_one(
            {"name": user_name},
            {"$push": {"cart": {"product_id": product_id, "quantity": 1}}}
        )
    print(result)
    if result.modified_count > 0:
        return jsonify({"message": "Product added to cart successfully"}), 200
    else:
        return jsonify({"error": "Failed to add product to cart"}), 500

@app.route('/update_cart', methods=['POST'])
def update_cart():
    data = request.json
    user_name = data.get("user_name")
    product_id = data.get("product_id")
    new_quantity = data.get("quantity")
    print(data)
    if not user_name or not product_id or new_quantity is None:
        return jsonify({"error": "User name, product ID, and quantity are required"}), 400

    # Find the user in buyers or sellers collection
    user = buyers_collection.find_one({"name": user_name}) or sellers_collection.find_one({"name": user_name})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Update the cart
    updated = False
    for item in user.get("cart", []):
        if item["product_id"] == product_id:
            item["quantity"] = new_quantity
            updated = True
            break

    if not updated:
        return jsonify({"error": "Product not found in cart"}), 404

    # Save the updated user document
    if buyers_collection.find_one({"name": user_name}):
        buyers_collection.update_one({"name": user_name}, {"$set": {"cart": user["cart"]}})
    else:
        sellers_collection.update_one({"name": user_name}, {"$set": {"cart": user["cart"]}})

    return jsonify({"message": "Cart updated successfully"}), 200

@app.route('/search', methods=['GET'])
def search_products():
    query = request.args.get('q', '')  # Get search query from the URL parameter
    if not query:
        return jsonify({'error': 'No search query provided'}), 400

    # Search for products matching the query (case-insensitive)
    products = uploads_collection.find(
    {
        'productname': {'$regex': query, '$options': 'i'}  # Regex search (case-insensitive)
    },
    {
        '_id': 0  # Exclude the _id field from the results
    }
)

    # Convert products cursor to a list and format it for the response
    products_list = []
    for product in products:
        products_list.append(product)
    print(products_list)
    return jsonify({'products': products_list})

@app.route('/search1', methods=['GET'])
def search_product():
    query = request.args.get('q', '')  # Get search query from the URL parameter
    if not query:
        return jsonify({'error': 'No search query provided'}), 400

    # Search for products matching the query (case-insensitive)
    products = pnc_collection.find(
    {
        'productname': {'$regex': query, '$options': 'i'}  # Regex search (case-insensitive)
    },
    {
        '_id': 0  # Exclude the _id field from the results
    }
)

    # Convert products cursor to a list and format it for the response
    products_list = []
    for product in products:
        products_list.append(product)
    print(products_list)
    return jsonify({'products': products_list})

@app.route('/get_cart', methods=['GET'])
def get_cart():
    user_name = request.args.get("user_name")
    if not user_name:
        return jsonify({"error": "User name is required"}), 400
    print(user_name)
    
    # Fetch user document from the buyers or sellers collection
    user = buyers_collection.find_one({"name": user_name}) or sellers_collection.find_one({"name": user_name})
    if not user or "cart" not in user:
        return jsonify({"error": "No cart found for the user"}), 404
    
    cart_items = user["cart"]
    cart_product_ids = [item["product_id"] for item in cart_items]
    print(cart_product_ids)
    
    # Try fetching from the first collection
    products_cursor = uploads_collection.find({"productid": {"$in": cart_product_ids}})
    product_list = list(products_cursor)
    
    # If no products found in the first collection, try the fallback collection
    if not product_list:
        products_cursor = pnc_collection.find({
  "$or": [
    {"product_id": {"$in": cart_product_ids}},
    {"productid": {"$in": cart_product_ids}}
  ]
})

        product_list = list(products_cursor)
        print(product_list)
    # If still no products found, return an error
    if not product_list:
        return jsonify({"error": "No products found for the user's cart"}), 404
    
    # Map product details with quantity
    response_products = []
    for item in cart_items:
        product_id = item["product_id"]
        print(product_id)
        # Check both product_id and productid in the product_list
        product = next((p for p in product_list if p.get("product_id") == product_id or p.get("productid") == product_id), None)
        print(product)
        if product:
            response_products.append({
    "product_id": product.get("productid", product.get("product_id")),
    "name": product.get("productname"),
    "weight": str(product.get("quantity")),
    "price": str(product.get("discountedprice") if product.get("discountedprice") is not None else product.get("price")),
    "original_price": str(product.get("price")),
    "image_path": product.get("image_path"),
    "quantity": item["quantity"]
})

    
    # If no products were matched, return an error
    if not response_products:
        return jsonify({"error": "No matching products found for the user's cart"}), 404

    print(response_products)
    return jsonify({"cart": response_products}), 200

# Route to create a seller
@app.route("/sellers_sign1", methods=["POST"])
def create_seller():
    data = request.json
    valid, message = validate_seller(data)
    if not valid:
        print(message)
        return jsonify({"error": message}), 400
    
    # Validate fields here
    if not data.get("name"):
        return jsonify({"error": "Name is required"}), 400
    if not data.get("password") or len(data["password"]) < 6:
        return jsonify({"error": "Password is required and must be at least 6 characters"}), 400
    if data["password"] != data.get("retype_password"):
        return jsonify({"error": "Passwords do not match"}), 400

    data.pop("retype_password", None)  # Remove retype_password field
    user_role = data['business_type']
    if user_role == "Farmer" :
        data['_id'] = "FAR-"  + data["name"]
    elif user_role == "Food Mill Operator":
        data['_id'] = "FMO-" + data["name"]
    elif user_role == "Wholesale Seller":
        data['_id'] = "WHS-" + data["name"]
    elif user_role == "Pesticide and Crop Seller":
        data['_id'] = "PNC-" + data["name"]
    seller_data.update(data)
    return jsonify({"message": "Seller created successfully"}), 201

@app.route("/sellers_sign3", methods=["POST"])
def signup2():
    global seller_data
    try:
        # Get data from the request for step 3
        step3_data = request.json
        if not step3_data:
            return jsonify({"error": "Invalid data"}), 400

        # Update global buyer_data with step 3 details
        seller_data.update(step3_data)
        print("Final buyer_data (after sign3):", seller_data)

        # Validate the combined data
        #required_fields = ["name", "email", "phone", "password", "address", "type"]
        #missing_fields = [field for field in required_fields if field not in buyer_data]
        #if missing_fields:
            #return jsonify({"error": f"Missing fields: {', '.join(missing_fields)}"}), 400
        sellers_collection.insert_one(seller_data)
        return jsonify({"message": "User details saved successfully!"}), 200
    except Exception as e:
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
        
@app.route("/sellers_login", methods=["POST"])
def sellers_login():
    global user_name,seller_data,user_id
    data = request.json
    user1= data.get("user_id")
    password = data.get("password")
    user_name,user_id= user1.split("-")
    if user1[0] == "S":
        user_role = user1[:4]
    else :
        user_role = user1[:3]
    if user_role == "FAR" or user_role == "SFAR":
        user_role = "Farmer"
    elif user_role == "FMO":
        user_role = "Food Mill Operator"
    elif user_role == "WHS":
        user_role = "Wholesale Seller"
    elif user_role == "PNC":
        user_role = "Pesticide and Crop Seller"
    print(user_name,user_id,password)
    if not user_id or not password:
        return jsonify({"status": "error", "message": "Missing user_id or password"}), 400
    user = sellers_collection.find_one({"$or": [{"name": user_id}, {"phone": user_id}]})
    seller_data.update(user)
    buyer_data.clear()
    print(seller_data)
    print(user)
    if user and user.get("password") == password:
        print("yes1")
        if user['business_type'] == user_role:
            print("yes")
            user["_id"] = str(user["_id"])  # Convert ObjectId to string
            return jsonify({"status": "success", "message": "Login successful", "data": user}), 200
        else:
            return jsonify({"status": "error", "message": "Invalid user login"}), 401
    else:
        return jsonify({"status": "error", "message": "Invalid credentials"}), 401

@app.route('/add_to_cart1', methods=['POST'])
def add_to_cart1():
    global seller_data
    data = request.json
    farmer_id = data.get("user_name")
    product_id = data.get("product_id")
    
    if not farmer_id or not product_id:
        return jsonify({"error": "Invalid input"}), 400

    farmer_cart = sellers_collection.find_one({"name": farmer_id})
    if not farmer_cart:
        return jsonify({"error": "Farmer not found"}), 404

    cart_item = next((item for item in farmer_cart.get("cart", []) if item["product_id"] == product_id), None)
    if cart_item:
        # Update the quantity if the product is already in the cart
        result = sellers_collection.update_one(
            {"name": farmer_id, "cart.product_id": product_id},
            {"$inc": {"cart.$.quantity": 1}}
        )
    else:
        # Add the product to the cart
        result = sellers_collection.update_one(
            {"name": farmer_id},
            {"$push": {"cart": {"product_id": product_id, "quantity": 1}}}
        )
    seller_data=sellers_collection.find_one({"_id":seller_data.get("_id")})
    if result.modified_count > 0:
        return jsonify({"message": "Product added to cart successfully"}), 200
    else:
        return jsonify({"error": "Failed to add product to cart"}), 500
    
ibid = ""

@app.route('/process_order', methods=['POST'])
def pro():
    global ibid 
    # Extract product_id from the incoming JSON request
    data = request.json
    ibid = data.get("product_id")
    
    if not ibid:
        return jsonify({"error": "Product ID is required"}), 400  # Return error if no product_id
    
    print(f"Product ID: {ibid}")  # Just for logging, you can remove this in production
    
    return jsonify({"message": "Order processed successfully"}), 200

import time,random,string

@app.route('/orders/<id>', methods=['GET']) 
def generate_reference_number(id):
    print('orders start....') 
    global buyer_data,seller_data,ibid
    sam ='0'
    print(buyer_data,seller_data)
    timestamp = int(time.time()) 
    random_str = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6)) 
    
    reference_number = f"{timestamp}-{random_str}" 
    print(reference_number) 
    now = datetime.now() 
    products2 = [] 
    print(ibid)
    if id == "0": 
        products2 = ibid
    else:
        if buyer_data:
            products2 =buyer_data.get("cart")
        else:
            products2 =seller_data.get("cart") 
        # if product_id: 
        #     products2 = [order['product_id'] for order in product_id]
       
    print(buyer_data)
    print(buyer_data.get("email", seller_data.get("_id")))
    print(products2)
    print(buyer_data.get("cart",seller_data.get("cart")))
    order_data = {
         "order_id": reference_number, 
         "date": now.strftime("%Y-%m-%d"), 
         "time": now.strftime("%H:%M:%S"), 
         "buyer_id": buyer_data.get("email", seller_data.get("_id")), 
         "products_id": products2 
    } 

    if buyers_collection.find_one({"email": buyer_data.get("email")}):
        user = buyers_collection.find_one({"email": buyer_data["email"]})

        if user and "cart" in user and len(user["cart"]) > 0:
            buyers_collection.update_one({"email": user["email"]}, {"$unset": {"cart": ""}})
    else:
        user =sellers_collection.find_one({"_id" : seller_data["_id"]})
        if user and "cart" in user and len(user["cart"]) > 0:
            sellers_collection.update_one({"_id": user["_id"]}, {"$unset": {"cart": ""}})
            sam = '1'

    orders_collection.update_one( {"order_id": reference_number}, {"$set": order_data}, upsert=True )    
    print("orders end...")
    return jsonify({"reference_number": reference_number,"isSeller":sam})

@app.route('/products1', methods=['GET'])
def get_products1():
    products = list(pnc_collection.find({}, {'_id': 0}))  # Exclude the '_id' field
    return jsonify(products)

@app.route('/get_orders', methods=['GET'])
def get_orders100():
    global buyer_data, seller_data
    
    user_id = buyer_data.get("email") if "email" in buyer_data else seller_data.get("_id")
    if not user_id:
        return jsonify({"error": "User ID not found"}), 404

    # Find all orders for the user
    orders = list(orders_collection.find({"buyer_id": user_id}, {"_id": 0}))
    
    response_data = []
    for order in orders:
        if 'products_id' not in order:
            continue
            
        product_ids = [prod['product_id'] for prod in order['products_id']]
        
        # Try uploads collection first
        products = list(uploads_collection.find(
            {"productid": {"$in": product_ids}},
            {"_id": 0}
        ))
        
        # If not found, try pnc collection
        if not products:
            products = list(pnc_collection.find(
                {"product_id": {"$in": product_ids}},
                {"_id": 0}
            ))
            
        if products:
            order_data = {
                'order': order.get('order_id', ''),
                'date': str(order.get('date', '')),
                'time': str(order.get('time', '')),
                'logoPath': 'assets/fairvest_logo.png',
                'products': products
            }
            response_data.append(order_data)
            
    return jsonify(response_data), 200 if response_data else 404



    
@app.route('/products200/<cat>', methods=['GET'])
def get_products2(cat):
    print(cat)
    products = list(uploads_collection.find({"category" : cat}, {'_id': 0}))  # Exclude the '_id' field
    print(products)
    return jsonify(products)

@app.route('/getuser1', methods=['GET'])
def get_user1():
    print(seller_data)
    print(seller_data.get('name'))
    try:
        # Query the MongoDB collection
        user_data = sellers_collection.find_one({"name": seller_data.get('name')})
        if user_data:
            # Remove the '_id' field if you don't want to expose it
            # user_data.pop('_id', None)
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
def get_trending_now():
    """Fetch trending products based on number of orders"""
    pipeline = [
        # Join products with orders
        {"$lookup": {
            "from": "orders",
            "localField": "product_id",
            "foreignField": "product_id",
            "as": "orders"
        }},
        # Count number of orders for each product
        {"$addFields": {"order_count": {"$size": "$orders"}}},
        # Sort by order count in descending order
        {"$sort": {"order_count": -1}},
        {"$limit": 10},  # Get top 10 trending products
        # Project required fields
        {"$project": {
            "_id": 0,
            "product_id": 1,
            "name": 1,
            "price": 1,
            "discount_percentage": 1,
            "image_url": 1,
            "order_count": 1
        }}
    ]
    
    trending_products = list(uploads_collection.aggregate(pipeline))
    return trending_products

def get_products_by_type(product_type):
    """Fetch products based on type"""
    try:
        if product_type == "top_offers":
            # Top offers: Discount >= 20%
            query = {"discount_percentage": {"$gte": 29.85}}
        elif product_type == "all_time_favorites":
            # All-time favorites: Star >= 4.5
            query = {"star": {"$gte": 5}}
        elif product_type == "trending_now":
            return get_trending_now()
        else:
            return []
        # Fetch products and convert to list
        products = list(uploads_collection.find(query, {"_id": 0}))
        print(product_type,"\n",len(products))
        return products
    except Exception as e:
        print(f"Error fetching products: {e}")
        return []

@app.route("/products/<product_type>", methods=["GET"])
def fetch_products(product_type):
    """
    Fetch products based on type: top_offers, all_time_favorites, trending_now.
    """
    valid_types = ["top_offers", "all_time_favorites", "trending_now"]
    if product_type not in valid_types:
        return jsonify({"error": "Invalid product type"}), 400
    
    try:
        products = get_products_by_type(product_type)
        return jsonify({
            "products": products, 
            "type": product_type,
            "count": len(products)
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

RAPIDAPI_KEY = "1d1a6467cemsh9c30f981210e6a9p1632f4jsna329e1545fb2"

def get_weather_by_city(city_name):
    conn = http.client.HTTPSConnection("open-weather13.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': RAPIDAPI_KEY,
        'x-rapidapi-host': "open-weather13.p.rapidapi.com"
    }

    conn.request("GET", f"/city/{city_name}/EN", headers=headers)

    res = conn.getresponse()
    data = res.read()
    print(data)
    return data.decode("utf-8")

def get_weather_by_latlon(lat, lon):
    conn = http.client.HTTPSConnection("open-weather13.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': RAPIDAPI_KEY,
        'x-rapidapi-host': "open-weather13.p.rapidapi.com"
    }

    conn.request("GET", f"/city/latlon/{lat}/{lon}", headers=headers)

    res = conn.getresponse()
    data = res.read()

    return data.decode("utf-8")

def get_five_day_forecast(lat, lon):
    conn = http.client.HTTPSConnection("open-weather13.p.rapidapi.com")

    headers = {
        'x-rapidapi-key': RAPIDAPI_KEY,
        'x-rapidapi-host': "open-weather13.p.rapidapi.com"
    }

    conn.request("GET", f"/city/fivedaysforcast/{lat}/{lon}", headers=headers)

    res = conn.getresponse()
    data = res.read()

    return data.decode("utf-8")


@app.route('/weather/<city_name>', methods=['GET'])
def weather_by_city(city_name):
    print(city_name)
    weather_data = get_weather_by_city(city_name)
    return jsonify({"weather": weather_data})


@app.route('/weather/latlon/<lat>/<lon>', methods=['GET'])
def weather_by_latlon(lat, lon):
    weather_data = get_weather_by_latlon(lat, lon)
    print(weather_data)
    return jsonify({"weather": weather_data})


@app.route('/weather/forecast/latlon/<lat>/<lon>', methods=['GET'])
def weather_forecast(lat, lon):
    forecast_data = get_five_day_forecast(lat, lon)
    print(forecast_data)
    return jsonify({"forecast": forecast_data})



@app.route('/upload-product', methods=['POST'])
def upload_product():
    global seller_data
    print(seller_data)
    
    try:
        # Configure the upload folder and allowed extensions
        UPLOAD_FOLDER = 'assets/uploads'
        ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
        app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

        # Create the upload folder if it doesn't exist
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        # Get form data
        description = request.form.get('description')
        name = request.form.get('product_name')
        units = request.form.get('units')
        date = request.form.get('date')
        category = request.form.get('category')
        price = request.form.get('price_per_unit')
        image = request.files.get('image')

        # Validate the inputs
        if not description or not units or not date or not image or not category or not price or not name:
            return jsonify({"error": "All fields are required!"}), 400

        # Function to check if the uploaded file is allowed
        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

        # Validate the image
        if not allowed_file(image.filename):
            return jsonify({"error": "Invalid image format!"}), 400

        # Secure the image file name
        filename = secure_filename(image.filename)

        # Save the image to the upload folder
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace('\\', '/')
        
        # Convert date to a datetime object
        try:
            selected_date = datetime.strptime(date, '%Y-%m-%d')
        except ValueError:
            return jsonify({"error": "Invalid date format! Use YYYY-MM-DD."}), 400

        # Prepare product data
        product_data = {
            "productid": seller_data['name'] + str(len(sellers_collection.find_one({"name": seller_data["name"]}).get("products", []))),
            "productname": name,
            "farmerid": "FAR-" + seller_data.get("name"),
            "farmername": seller_data.get("name"),
            "price": float(price),
            "description": description,
            "quantity": float(units),
            "date": selected_date.strftime('%Y-%m-%d'),
            "image_path": image_path,
            "category": category.replace(' ', '_')
        }

        # Insert product data into the uploads collection
        uploads_collection.insert_one(product_data)
        image.save(image_path)

        # Function to update seller with product
        def update_seller_with_product(seller_id, product_id):
            seller = sellers_collection.find_one({"name": seller_id})
            if seller:
                if "products" in seller:
                    if product_id not in seller["products"]:
                        sellers_collection.update_one(
                            {"name": seller_id},
                            {"$push": {"products": product_id}}
                        )
                else:
                    sellers_collection.update_one(
                        {"name": seller_id},
                        {"$set": {"products": [product_id]}}
                    )
            else:
                sellers_collection.insert_one({"name": seller_id, "products": [product_id]})

        # Update seller with product
        update_seller_with_product(seller_data["name"], product_data["productid"])
        product_data.pop("_id")
        print("Received Product Data:", product_data)
        return jsonify({"message": "Product uploaded successfully!", "product": product_data}), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500
    
@app.route('/upload-product1', methods=['POST'])
def upload_product1():
    global seller_data
    print(seller_data)
    
    try:
        # Configure the upload folder and allowed extensions
        UPLOAD_FOLDER = 'assets/uploads'
        ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
        app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

        # Create the upload folder if it doesn't exist
        if not os.path.exists(UPLOAD_FOLDER):
            os.makedirs(UPLOAD_FOLDER)

        # Get form data
        description = request.form.get('description')
        name = request.form.get('product_name')
        units = request.form.get('units')
        date = request.form.get('date')
        category = request.form.get('category')
        price = request.form.get('price_per_unit')
        image = request.files.get('image')

        # Validate the inputs
        if not description or not units or not date or not image or not category or not price or not name:
            return jsonify({"error": "All fields are required!"}), 400

        # Function to check if the uploaded file is allowed
        def allowed_file(filename):
            return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

        # Validate the image
        if not allowed_file(image.filename):
            return jsonify({"error": "Invalid image format!"}), 400

        # Secure the image file name
        filename = secure_filename(image.filename)

        # Save the image to the upload folder
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename).replace('\\', '/')
        
        # Convert date to a datetime object
        try:
            selected_date = datetime.strptime(date, '%Y-%m-%d')
        except ValueError:
            return jsonify({"error": "Invalid date format! Use YYYY-MM-DD."}), 400

        # Prepare product data
        product_data = {
            "productid": seller_data['name'] + str(len(sellers_collection.find_one({"name": seller_data["name"]}).get("products", []))),
            "productname": name,
            "farmerid": "FAR-" + seller_data.get("name"),
            "farmername": seller_data.get("name"),
            "price": float(price),
            "description": description,
            "quantity": float(units),
            "date": selected_date.strftime('%Y-%m-%d'),
            "image_path": image_path,
            "category": category.replace(' ', '_')
        }

        # Insert product data into the uploads collection
        pnc_collection.insert_one(product_data)
        image.save(image_path)

        # Function to update seller with product
        def update_seller_with_product(seller_id, product_id):
            seller = sellers_collection.find_one({"name": seller_id})
            if seller:
                if "products" in seller:
                    if product_id not in seller["products"]:
                        sellers_collection.update_one(
                            {"name": seller_id},
                            {"$push": {"products": product_id}}
                        )
                else:
                    sellers_collection.update_one(
                        {"name": seller_id},
                        {"$set": {"products": [product_id]}}
                    )
            else:
                sellers_collection.insert_one({"name": seller_id, "products": [product_id]})

        # Update seller with product
        update_seller_with_product(seller_data["name"], product_data["productid"])
        product_data.pop("_id")
        print("Received Product Data:", product_data)
        return jsonify({"message": "Product uploaded successfully!", "product": product_data}), 200

    except Exception as e:
        print(f"An error occurred: {e}")
        traceback.print_exc()
        return jsonify({"error": str(e)}), 500


@app.route("/get_orders_pnc", methods=["GET"])
def get_orders():
    # Fetch current orders from the 'orders' collection
    orders = list(orders_collection.find({}))
    print(orders)
    # Format response
    orders_list = []
    
    for order in orders:
        farmer = sellers_collection.find_one({"_id" : order["buyer_id"]})
        if farmer:
            farmer ={"name":"unknown"}
        print(farmer)
        da = order["products_id"][0]
        product = pnc_collection.find_one({"productid" : da.get("products_id")})
        orders_list.append({
            "date": order["date"],
            "time": order["time"],
            "farmer_name": farmer.get("name", "Unknown"), 
            "product_name": product.get("productname", "Unknown"),
            "quantity": da.get("quantity"),
            "price": order.get("price",0)
        })
    print(orders_list)
    return jsonify(orders_list)

@app.route('/manage-products', methods=['GET'])
def manage_products():
    global seller_data
    # Get seller ID from query parameters
    seller_id = seller_data["_id"]  # Assuming the seller_id is passed as a query parameter
    print(seller_id)
    if not seller_id:
        return jsonify({"error": "Seller ID is required"}), 400

    try:
        # Fetch seller data using the seller_id
        seller_data = sellers_collection.find_one({"_id": seller_id})
        print(seller_data.keys())
        if  not seller_data or "products" not in seller_data.keys():
            return jsonify([])  # Return empty list if no products found

        product_ids = seller_data["products"]  # List of product IDs
        print(product_ids)
        # Fetch product details from the uploads collection
        products_cursor = uploads_collection.find({"productid": {"$in": product_ids}})
        product_list = list(products_cursor)

# If no products are found, try fetching from pnc_collection
        if not product_list:
            products_cursor = pnc_collection.find({"productid": {"$in": product_ids}})
            product_list = list(products_cursor)
        # Transform MongoDB documents into JSON-serializable format
        result = [
            {
                "imageUrl": product["image_path"],
                "title": product["productname"],
                "subtitle": product["description"],
                "units": product["quantity"],
            }
            for product in product_list
        ]
        print(result)
        return jsonify(result)

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"error": "An error occurred while fetching products"}), 500


centers_collection = db["centers"]
@app.route('/center_login', methods=['POST'])
def center_login():
    try:
        data = request.json
        if not data:
            return jsonify({'message': 'Missing data', 'status': 'failure'}), 400

        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return jsonify({'message': 'Username and password are required', 'status': 'failure'}), 400

        print(f"Login attempt: {username}, {password}")  # For debugging

        user = centers_collection.find_one({'id': username})
          # Query using 'username'
        if user and user['password'] == password:
            return jsonify({'message': 'Login successful', 'status': 'success'}), 200
        
        return jsonify({'message': 'Invalid credentials', 'status': 'failure'}), 401

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Server error', 'status': 'failure'}), 500

farmers_collection = db["sellers"]
@app.route('/farmers', methods=['GET'])
def get_farmers():
    try:
        # Fetch all farmers and exclude '_id' from the output
        farmers = list(farmers_collection.find({}))
        print(farmers)
        # Filter farmers whose `_id` does not start with "SFAR"
        filtered_farmers = [
            {**farmer, "_id": str(farmer["_id"])}  # Convert _id to string
            for farmer in farmers
            if str(farmer.get("_id", "")).startswith("SFAR")
        ]     
        farmers_with_ids = [
            {**farmer, "id": str(farmer["_id"])} for farmer in filtered_farmers
        ]   
        print(farmers_with_ids)  # Debug print to see the filtered result
        return jsonify(farmers_with_ids), 200
    except Exception as e:
        # Handle exceptions and send an error response
        return jsonify({"error": str(e)}), 500




@app.route('/farmers', methods=['POST'])
def add_farmer():
    """Add a new farmer."""
    data = request.get_json()
    if not data.get('name') or not data.get('phone'):
        return jsonify({'error': 'Name and Phone are required'}), 400

    farmer = {
        '_id' : "SFAR-"+data['name'],
        'name': data["name"],
        'email': data.get('email', ''),
        'phone': data['phone'],
        'password':"welcome",
        'business_type':"Farmer",
        'location': data.get('location', '')
    }
    result = farmers_collection.insert_one(farmer)
    return jsonify(farmer), 201


@app.route('/farmers/<farmer_id>', methods=['PUT'])
def update_farmer(farmer_id):
    """Update an existing farmer."""
    data = request.get_json()

    try:
        farmer = farmers_collection.find_one({'_id': farmer_id})
        if not farmer:
            return jsonify({'error': 'Farmer not found'}), 404

        updated_data = {
            'name': data.get('name', farmer['name']),
            'email': data.get('email', farmer.get('email', '')),
            'phone': data.get('phone', farmer['phone']),
            'location': data.get('location', farmer.get('location', ''))
        }
        farmers_collection.update_one({'_id': farmer_id}, {'$set': updated_data})
        updated_data['id'] = farmer_id
        return jsonify(updated_data), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400


@app.route('/farmers/<farmer_id>', methods=['DELETE'])
def delete_farmer(farmer_id):
    """Delete a farmer."""
    try:
        result = farmers_collection.delete_one({'_id':farmer_id})
        if result.deleted_count == 0:
            return jsonify({'error': 'Farmer not found'}), 404
        return jsonify({'message': 'Farmer deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400


# Upload folder configuration
UPLOAD_FOLDER = 'assets/uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Allowed file extensions
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Collection for the existing upload table

@app.route('/products', methods=['GET'])
def get_products():
    search_query = request.args.get('search', '')
    query = {'name': {'$regex': search_query, '$options': 'i'}} if search_query else {}
    products = list(uploads_collection.find(query, {'_id': 0}))  # Exclude '_id' from results
    return jsonify(products), 200

@app.route('/products', methods=['POST'])
def add_product():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    image = request.files['image']
    if image and allowed_file(image.filename):
        filename = secure_filename(image.filename)
        image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        image.save(image_path)
        print(image_path)
        product = {
            'name': request.form.get('name', ''),
            'productId': request.form.get('productId', ''),
            'farmerId': request.form.get('farmerId', ''),
            'image': image_path
        }

        uploads_collection.insert_one(product)
        return jsonify({'message': 'Product added successfully'}), 201

    return jsonify({'error': 'Invalid image file'}), 400

@app.route('/products/<product_id>', methods=['PUT'])
def update_product(product_id):
    existing_product = uploads_collection.find_one({'productId': product_id})
    if not existing_product:
        return jsonify({'error': 'Product not found'}), 404

    updated_fields = {}
    if 'name' in request.form:
        updated_fields['name'] = request.form['name']
    if 'farmerId' in request.form:
        updated_fields['farmerId'] = request.form['farmerId']

    # Handle image update
    if 'image' in request.files:
        image = request.files['image']
        if image and allowed_file(image.filename):
            filename = secure_filename(image.filename)
            image_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            image.save(image_path)
            updated_fields['image'] = image_path

    if updated_fields:
        uploads_collection.update_one({'productId': product_id}, {'$set': updated_fields})
        return jsonify({'message': 'Product updated successfully'}), 200

    return jsonify({'error': 'No valid fields to update'}), 400

@app.route('/products/<product_id>', methods=['DELETE'])
def delete_product(product_id):
    result = uploads_collection.delete_one({'productId': product_id})
    if result.deleted_count > 0:
        return jsonify({'message': 'Product deleted successfully'}), 200
    return jsonify({'error': 'Product not found'}), 404  



@app.route('/orders100', methods=['GET'])
def get_orders10():
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    orders = list(db.orders.find({"date": {"$gte": start_date, "$lte": end_date}}))
    return jsonify(orders)

@app.route('/top-products100', methods=['GET'])
def top_products100():
    pipeline = [
        {"$unwind": "$products_id"},
        {"$group": {"_id": "$products_id.product_id", "total_quantity": {"$sum": "$products_id.quantity"}}},
        {"$sort": {"total_quantity": -1}},
        {"$limit": 10}
    ]
    result = list(db.orders.aggregate(pipeline))
    return jsonify(result)

@app.route('/buyer-stats', methods=['GET'])
def buyer_stats():
    pipeline = [
        {"$group": {"_id": "$buyer_id", "total_orders": {"$sum": 1}}},
        {"$sort": {"total_orders": -1}}
    ]
    result = list(db.orders.aggregate(pipeline))
    return jsonify(result)

@app.route('/revenue', methods=['GET'])
def revenue():
    pipeline = [
        {"$unwind": "$products_id"},
        {"$lookup": {"from": "products", "localField": "products_id.product_id", "foreignField": "product_id", "as": "product_details"}},
        {"$unwind": "$product_details"},
        {"$project": {"date": 1, "revenue": {"$multiply": ["$products_id.quantity", "$product_details.price"]}}},
        {"$group": {"_id": "$date", "total_revenue": {"$sum": "$revenue"}}}
    ]
    result = list(db.orders.aggregate(pipeline))
    return jsonify(result)


@app.route('/products200', methods=['GET'])
def get_products500():
    # Fetch products from PNC and Uploads tables
    pnc_products = list(db.pnc.find({}, {'_id': 0}))
    uploads_products = list(db.uploads.find({}, {'_id': 0}))
    
    # Merge both collections
    all_products = pnc_products + uploads_products
    return jsonify(all_products)

@app.route('/analysis200', methods=['GET'])
def product_analysis500():
    # Fetch all products
    pnc_products = list(db.pnc.find({}, {'_id': 0}))
    uploads_products = list(db.uploads.find({}, {'_id': 0}))
    all_products = pnc_products + uploads_products

    # Analysis
    top_discounted = sorted(all_products, key=lambda x: x['discount_percentage'], reverse=True)[:5]
    high_rated = sorted(all_products, key=lambda x: x['star'], reverse=True)[:5]
    category_count = {}
    for product in all_products:
        category = product.get("category", "Unknown")
        category_count[category] = category_count.get(category, 0) + 1

    return jsonify({
        "top_discounted": top_discounted,
        "high_rated": high_rated,
        "category_count": category_count
    })

@app.route('/farmer/<farmer_id>', methods=['GET'])
def get_farmer_details(farmer_id):
    farmer = db.sellers.find_one({'_id': farmer_id})
    if farmer:
        return jsonify(farmer)
    return jsonify({'error': 'Farmer not found'}), 404

@app.route('/check_review/<order_id>/<product_id>', methods=['GET'])
def check_review(order_id, product_id):
    review = db.reviews.find_one({
        'order_id': order_id,
        'product_id': product_id
    })
    return jsonify({'exists': review is not None})

# Submit a new review
@app.route('/submit_review', methods=['POST'])
def submit_review():
    data = request.json
    
    # Create review document
    review = {
        'order_id': data['order_id'],
        'product_id': data['product_id'],
        'farmer_id': data['farmer_id'],
        'rating': data['rating'],
        'review': data['review'],
        'date': data['date']
    }
    
    try:
        # Insert review
        db.reviews.insert_one(review)
        
        # Update product's average rating
        product_reviews = db.reviews.find({'product_id': data['product_id']})
        total_rating = sum(r['rating'] for r in product_reviews)
        count = db.reviews.count_documents({'product_id': data['product_id']})
        avg_rating = total_rating / count
        
        db.products.update_one(
            {'productid': data['product_id']},
            {'$set': {'average_rating': avg_rating}}
        )
        
        # Add review to farmer's feedback
        db.sellers.update_one(
            {'_id': data['farmer_id']},
            {'$push': {'feedback': {
                'rating': data['rating'],
                'comment': data['review'],
                'date': data['date']
            }}}
        )
        
        return jsonify({'message': 'Review submitted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
# Run the Flask application
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True) 