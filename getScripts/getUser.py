import http.client
import json
import time
import sys
import collections
import time
import json
import random

with open('user_ids0.txt', 'r') as f:
    users = f.read().splitlines()


api_key = ''     # USER YOUR OWN API KEY

# Can get info of each user in your list
for i in range(len(users)):

    user = users[i]

    # Setup connection
    conn = http.client.HTTPSConnection("www.mountainproject.com", timeout=10)
    payload = "{}"

    # Make request
    conn.request("GET", "/data/get-user?userId=" + user + "&key=" + api_key, payload)

    # Get response
    res = conn.getresponse()

    # Collect data
    data = res.read()

    # Unpackage json object and extract relevant info
    inventory = json.loads(data)

    # Write array to file; make sure to make a directory user_data
    with open("user_data/user_" + user + '.json', 'w') as outfile:
        json.dump(inventory, outfile)

    # OPTIONAL: Time out randomly, just a precaution for too many API calls
    # time.sleep(random.randint(1, 30))
