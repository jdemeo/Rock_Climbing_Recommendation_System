import http.client
import json
import time
import sys
import collections
import time
import json
import random

# Can get info of 200 routes per call
api_key = ''     # USER YOUR OWN API KEY
start_index = 0
counter = 0
for end_index in range(200, len(all_routes), 200):
    print(start_index)

    # Collect 200 routes
    bolus_of_routes = all_routes[start_index:end_index]

    # Convert all elements to dtype string
    bolus_of_routes = [str(i) for i in bolus_of_routes]

    # takes list and concatenates elements with , as separator
    string_of_routes = ",".join(bolus_of_routes)

    # Setup connection
    conn = http.client.HTTPSConnection("www.mountainproject.com", timeout=180)
    payload = "{}"

    # Make request
    conn.request("GET", "/data/get-routes?routeIds=" + string_of_routes + "&key=" + api_key, payload)

    # Get response
    res = conn.getresponse()

    # Collect data
    data = res.read()

    # Unpackage json object and extract relevant info
    inventory = json.loads(data)
    route_info = inventory['routes']

    # Write array to file
    with open("route_data/routes_" + str(counter) + '.json', 'w') as outfile:
        json.dump(route_info, outfile)

    # Used for next iteration
    start_index = end_index
    counter += 1

    # OPTIONAL: Sleep randomly, just a precaution for too many API calls
    time.sleep(random.randint(1, 30))
