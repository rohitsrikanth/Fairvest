import pandas as pd
from pymongo import MongoClient
import random as r

# MongoDB connection string
CONNECTION_STRING = "mongodb://localhost:27017/Fairvest"

# Connect to MongoDB
client = MongoClient(CONNECTION_STRING)

# Access your database and collection
db = client["Fairvest"]
collection = db["sellers"]

# Function to generate a random phone number
def ph(): 
    ph_no = [] 
    ph_no.append(r.randint(6, 9)) 
    for i in range(1, 10): 
        ph_no.append(r.randint(0, 9))
    return "".join(map(str, ph_no))

# Read the CSV data
data = pd.read_csv(r'C:\Users\91956\StudioProjects\flutter_application_1\farmers.csv')
districts = [
    "Thanjavur",
    "Erode",
    "Coimbatore",
    "Chengalpattu",
    "Salem",
    "Madurai",
    "Tiruchirappalli",
    "Nagapattinam",
    "Vellore",
    "Dindigul"
]

# Iterate through the DataFrame and prepare the data for MongoDB
for _, row in data.iterrows():
    farmer_data = {
        "_id": str(row["farmerid"]),
        "name": row["farmername"],
        "email": row["farmername"].split()[0] + str(r.randint(1000, 9999)) + "@gmail.com",
        "phone": ph(),
        "password": "welcome",
        "business_type": "Farmer",
        "location": r.choice(districts)
    }
    # Upsert the document into MongoDB
    collection.update_one({"_id": farmer_data["_id"]}, {"$set": farmer_data}, upsert=True)

print("Data successfully uploaded to MongoDB collection 'sellers'")
