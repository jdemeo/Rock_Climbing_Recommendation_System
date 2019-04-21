import pandas as pd
from math import sqrt
import re
import routes

pd.set_option('display.max_columns', 500)
pd.set_option('precision', 10)


df = pd.read_csv('mongoData.csv').drop(['Unnamed: 0','_id','success'], axis=1)
dfRoute = pd.read_csv('routeData.csv')


id_list = dfRoute['id'].tolist()
id_list = [str(i) for i in id_list]
type_list = dfRoute['type'].tolist()

type_dict = dict(zip(id_list,type_list))



lookup = {'+':.333, '-':-.333, 'a':.15, 'a/b':.275, 'b':.4, 'b/c':.525, 'c':.65, 'c/d':.775, 'd':.9}

df['route_count'] = df['ticks'].apply(lambda x: x.count('routeId'))

df = df[df['average'] != '5.?']
df = df[df['average'] != '4th']
df = df[df['average'] != '3rd']

df.average = df.average.apply(lambda x: x.replace('5.',''))
df.average = df.average.apply(lambda x: x.replace('Easy 5th','0'))
df.average = df.average.apply(lambda x: x.replace('+','.333'))
df.average = df.average.apply(lambda x: str(float(x.replace('-',''))-.333) if '-' in x else x)
df.average = df.average.apply(lambda x: x.replace('a/b','.275'))
df.average = df.average.apply(lambda x: x.replace('b/c','.525'))
df.average = df.average.apply(lambda x: x.replace('c/d','.775'))
df.average = df.average.apply(lambda x: x.replace('a','.15'))
df.average = df.average.apply(lambda x: x.replace('b','.4'))
df.average = df.average.apply(lambda x: x.replace('c','.65'))
df.average = df.average.apply(lambda x: x.replace('d','.9'))


df = df[df['hardest'] != '5.?']
df = df[df['hardest'] != '4th']
df = df[df['hardest'] != '3rd']

df.hardest = df.hardest.apply(lambda x: x.replace('5.',''))
df.hardest = df.hardest.apply(lambda x: x.replace('Easy 5th','0'))
df.hardest = df.hardest.apply(lambda x: x.replace('+','.333'))
df.hardest = df.hardest.apply(lambda x: str(float(x.replace('-',''))-.333) if '-' in x else x)
df.hardest = df.hardest.apply(lambda x: x.replace('a/b','.275'))
df.hardest = df.hardest.apply(lambda x: x.replace('b/c','.525'))
df.hardest = df.hardest.apply(lambda x: x.replace('c/d','.775'))
df.hardest = df.hardest.apply(lambda x: x.replace('a','.15'))
df.hardest = df.hardest.apply(lambda x: x.replace('b','.4'))
df.hardest = df.hardest.apply(lambda x: x.replace('c','.65'))
df.hardest = df.hardest.apply(lambda x: x.replace('d','.9'))


# Extract routes from users
def routes_list(tick_data):
    return re.findall("'routeId': ([0-9]*)", tick_data)

df['route_list'] = df['ticks'].apply(lambda x: routes_list(x))


df = df.set_index('user').drop('ticks', axis=1)#.astype(float)


user = 108738732


#Creating similarity score, which is the number of same routes user has climbed with another user
userList = set(df.loc[user].route_list)

def similarity(x):
	return len(userList.intersection(set(x)))

df['similarity'] = df['route_list'].apply(lambda x: similarity(x))



ids = routes.getList()
ids = [str(i) for i in ids]

print(len(ids))



#filter df to users that have climbed one of the routes within the distance chosen
df['filter'] = df['route_list'].apply(lambda x: 1 if len(set(x).intersection(set(ids))) > 0 else 0)

df = df[df['filter'] == 1]

#number of similar route types
df['type_replace'] = df['route_list'].apply(lambda x: list(map(type_dict.get, list(x))))

df['trad'] = df['type_replace'].apply(lambda x: str(x).count('Trad'))
df['sport'] = df['type_replace'].apply(lambda x: str(x).count('Sport'))
df['tr'] = df['type_replace'].apply(lambda x: str(x).count('TR'))
df['boulder'] = df['type_replace'].apply(lambda x: str(x).count('Boulder'))
df['ice'] = df['type_replace'].apply(lambda x: str(x).count('Ice'))
df['alpine'] = df['type_replace'].apply(lambda x: str(x).count('Alpine'))
df['snow'] = df['type_replace'].apply(lambda x: str(x).count('Snow'))
df['aid'] = df['type_replace'].apply(lambda x: str(x).count('Aid'))
df['mixed'] = df['type_replace'].apply(lambda x: str(x).count('Mixed'))

print(df.head(10))

df.to_csv('processedData.csv', encoding='utf-8')






