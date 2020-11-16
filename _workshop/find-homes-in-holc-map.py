import pandas as pd
import csv
import json

from shapely.geometry import shape, GeometryCollection, Point

with open('wax-main/OHCleveland1939.geojson', 'r') as f:
  js = json.load(f)

input = pd.read_csv('wpa-workers-doc-9031-georeferenced.csv')
print(input.head(3))
csvheaders = list(input.columns)
print(csvheaders)

df = pd.DataFrame(input)
df['holc_id'] = '' # add new column

for index in df.index:
  if (df.loc[index, 'longitude'] != ''):
    # print(float(worker['longitude']))
    point = Point(float(df.loc[index, 'longitude']), float(df.loc[index, 'latitude']))

    for feature in js['features']:

      polygon = shape(feature['geometry'])

      if polygon.contains(point):
        print (feature['properties']['holc_id'], ' ', df.loc[index, 'signature'])
        df.loc[index, 'holc_id'] = feature['properties']['holc_id']
  else:
    print('     ', df.loc[index, 'signature'])
    df.loc[index, 'holc_id'] = ''

df.to_csv('wpa-workers-doc-9031-georeferenced-holc.csv')

