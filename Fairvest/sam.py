from pymongo import MongoClient

def add_product_id_to_collection():
    # Connect to the MongoDB server
    client = MongoClient("mongodb://localhost:27017/")  # Replace with your connection string
    db = client["Fairvest"]  # Replace with your database name
    collection = db["pnc"]  # Replace with your collection name

    # Fetch all documents
    documents = list(collection.find())

    # Add or update the `product_id` for each document
    for idx, doc in enumerate(documents):
        product_id = f"PROD-{str(idx + 1).zfill(4)}"  # Generate unique product ID
        collection.update_one(
            {"_id": doc["_id"]},
            {"$set": {"product_id": product_id}}
        )
    
    print("Product IDs have been successfully added or updated.")

# Call the function
add_product_id_to_collection()
