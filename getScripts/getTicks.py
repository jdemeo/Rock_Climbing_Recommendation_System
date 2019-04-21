import http.client
import json
import time
import sys
import collections
import time
import json
import random
import csv

api_key = ''     # USER YOUR OWN API KEY

def main ():
	with open('user_ids3.csv', 'r') as f:   #Enter your CSV file name
	    reader = csv.reader(f)
	    users = [i[0] for i in reader]

	user_ticks(users)


def user_ticks (users, startPos='0'):
	# print (len(users))
	for i in range(len(users)):
		user = users[i]
		# print(user)
		try:
		    # Unpackage json object and extract relevant info
			for i in range(5):
				startPos = str(i*200)
				# print('API call for '+user)
				inventory = connection(user, startPos)
				# print('API call done for '+ user)
				if len(inventory['ticks']) == 0:
					break
				# print(user)
				with open('user_ticks/user'+ str(i) + '_' + user + '.json', 'w') as outfile:
					json.dump(inventory, outfile)
		except:
			time.sleep(random.randint(10, 20))

def connection (user, startPos = ''):
	# Setup connection
	conn = http.client.HTTPSConnection("www.mountainproject.com", timeout=10)
	payload = "{}"

	# Make request
	conn.request("GET", "/data/get-ticks?userId=" + user + "&startPos=" + startPos + "&key=" + api_key, payload)

	# Get response
	res = conn.getresponse()

	# Collect data
	data = res.read()

	return json.loads(data)

if __name__ == '__main__':
	main()


    # OPTIONAL: Time out randomly, just a precaution for too many API calls
    # time.sleep(random.randint(1, 30))
