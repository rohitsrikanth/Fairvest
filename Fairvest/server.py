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

app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={r"/*": {"origins": "*"}})
buyer_data = {}
user_name = ""
seller_data ={}
user_id=""
# Replace Atlas connection string with the localhost connection for MongoDB Community Edition
CONNECTION_STRING = "mongodb://localhost:27017/Fairvest"  # Default local MongoDB URI
client = MongoClient(CONNECTION_STRING)

# Access your database
db = client["Fairvest"]

# Function to check if collection exists, and if not, create it
def ensure_collection_exists(collection_name):
    if collection_name not in db.list_collection_names():
        db.create_collection(collection_name)

# Ensure 'buyers' and 'sellers' collections exist
ensure_collection_exists("buyers")
ensure_collection_exists("sellers")
ensure_collection_exists("uploads")
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
    required_fields = ["type_of_business", "name", "phone_number", "password", "field_location"]
    missing_fields = [field for field in required_fields if field not in data]
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


@app.route("/buyers_sign3", methods=["POST"])
def signup():
    global buyer_data
    try:
        # Get data from the request for step 3
        step3_data = request.json
        if not step3_data:
            return jsonify({"error": "Invalid data"}), 400

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
    buyer = buyers_collection.find_one({"$or": [{"email": username}, {"phone": username}]})
    print(buyer)
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
        user_data = buyers_collection.find_one({"email": user_name})
        if user_data:
            # Remove the '_id' field if you don't want to expose it
            user_data.pop('_id', None)
            return jsonify(user_data), 200
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


    
@app.route('/add_to_cart', methods=['POST'])
def add_to_cart():
    data = request.json
    user_name = data.get("user_name")
    product_id = data.get("product_id")

    if not user_name or not product_id:
        return jsonify({"error": "Invalid input"}), 400

    # Find the user and update their cart
    result = buyers_collection.update_one(
        {"name": user_name},
        {"$addToSet": {"cart": product_id}},  # Use `$addToSet` to avoid duplicate entries
        upsert=True  # Create the user if they don't exist
    )

    if result.modified_count > 0 or result.upserted_id:
        return jsonify({"message": "Product added to cart successfully"}), 200
    else:
        return jsonify({"error": "Failed to add product to cart"}), 500

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

    # Fetch product details for the cart items
    cart_product_ids = user["cart"]
    print(cart_product_ids)
    
    # Try fetching from the first collection
    products_cursor = uploads_collection.find({"productid": {"$in": cart_product_ids}})
    product_list = list(products_cursor)
    
    # If no products found, try the fallback collection
    if not product_list:
        products_cursor = pnc_collection.find({"product_id": {"$in": cart_product_ids}})
        product_list = list(products_cursor)
    
    if not product_list:
        return jsonify({"error": "No products found for the user's cart"}), 404

    # Prepare the product list
    response_products = []
    for product in product_list:
        response_products.append({
            "name": product.get("productname"),
            "weight": str(product.get("quantity")),
            "price": str(product.get("discountedprice")),
            "original_price": str(product.get("price")),
            "image_path": product.get("image_path")
        })

    print(response_products)
    return jsonify({"cart": response_products}), 200

# Route to create a seller
@app.route("/sellers_sign1", methods=["POST"])
def create_seller():
    data = request.json
    
    # Validate fields here
    if not data.get("name"):
        return jsonify({"error": "Name is required"}), 400
    if not data.get("password") or len(data["password"]) < 6:
        return jsonify({"error": "Password is required and must be at least 6 characters"}), 400
    if data["password"] != data.get("retype_password"):
        return jsonify({"error": "Passwords do not match"}), 400

    data.pop("retype_password", None)  # Remove retype_password field
    data['_id'] = "FAR-"+data["name"]
    sellers_collection.insert_one(data)
    return jsonify({"message": "Seller created successfully"}), 201

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
    data = request.json
    farmer_id = data.get('farmer_id')
    product_id = data.get('product_id')
    print(farmer_id,product_id)
    if not farmer_id or not product_id:
        return jsonify({'success': False, 'message': 'Missing required fields'}), 400

    # Update the cart in the database
    farmer_cart = sellers_collection.find_one({'name': farmer_id})
    if not farmer_cart:
        sellers_collection.insert_one({'farmer_id': farmer_id, 'cart': [product_id]})
    else:
        sellers_collection.update_one(
            {'name': farmer_id},
            {'$addToSet': {'cart': product_id}}  # Ensures no duplicate product IDs
        )

    return jsonify({'success': True, 'message': 'Product added to cart'}), 200

@app.route('/products', methods=['GET'])
def get_products1():
    products = list(pnc_collection.find({}, {'_id': 0}))  # Exclude the '_id' field
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
            user_data.pop('_id', None)
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
            "price": price,
            "description": description,
            "quantity": units,
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
        if not seller_data or "products" not in seller_data:
            return jsonify([])  # Return empty list if no products found

        product_ids = seller_data["products"]  # List of product IDs

        # Fetch product details from the uploads collection
        products = list(uploads_collection.find({"productid": {"$in": product_ids}}))

        # Transform MongoDB documents into JSON-serializable format
        result = [
            {
                "imageUrl": product["image_path"],
                "title": product["productname"],
                "subtitle": product["description"],
                "units": product["quantity"],
            }
            for product in products
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
# Run the Flask application
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True) 