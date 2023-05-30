import numpy as np
import pandas as pd
pd.set_option('display.max_columns', 500)
import re
from datetime import datetime
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import metrics, preprocessing

dtf_products = pd.read_csv('movies.csv')
dtf_users = pd.read_csv('ratings.csv').head(10000)

#Products
dtf_products = dtf_products[~dtf_products['genres'].isna()]
dtf_products['product'] = range(0, len(dtf_products))
dtf_products['name'] = dtf_products['title'].apply(lambda x: re.sub('[\(\[].*?[\)\]]', '', x).strip())
dtf_products['year'] = dtf_products['title'].apply(lambda x: int(x.split('(')[-1].replace(')', '').strip())
                                                   if '(' in x else np.nan)
dtf_products['year'] = dtf_products['year'].fillna(9999).astype(int)
dtf_products['old'] = dtf_products['year'].apply(lambda x: 1 if x < 2000 else 0)

#Users
dtf_users['user'] = dtf_users['userId'].apply(lambda x: x - 1)
dtf_users['timestamp'] = dtf_users['timestamp'].apply(lambda x: datetime.fromtimestamp(x))
dtf_users['daytime'] = dtf_users['timestamp'].apply(lambda x: 1 if 6<int(x.strftime('%H'))<20 else 0)
dtf_users['weekend'] = dtf_users['timestamp'].apply(lambda x: 1 if x.weekday() in [5,6] else 0)
dtf_users = dtf_users.merge(dtf_products[['movieId', 'product']], how='left')
dtf_users = dtf_users.rename(columns={'rating':'y'})

#Clean
dtf_products = dtf_products[['product', 'name', 'year', 'old', 'genres']].set_index('product')
dtf_users = dtf_users[['user', 'product', 'daytime', 'weekend', 'y']]



tags = [i.split('|') for i in dtf_products['genres'].unique()]
columns = list(set([i for lst in tags for i in lst]))
columns.remove('(no genres listed)')
for col in columns:
    dtf_products[col] = dtf_products['genres'].apply(lambda x: 1 if col in x else 0)

#fig, ax = plt.subplots(figsize=(20,5))
#sns.heatmap(dtf_products==0, vmin=0, vmax=1, cbar=False, ax=ax).set_title("Products x Features")
#plt.show()

tmp = dtf_users.copy()
dtf_users = tmp.pivot_table(index='user', columns='product', values='y')
missing_cols = list(set(dtf_products.index) - set(dtf_users.columns))
missings_cols_dtf = pd.DataFrame(np.nan, index=dtf_users.index, columns=missing_cols)
dtf_users = pd.concat([dtf_users, missings_cols_dtf], axis=1)
dtf_users = dtf_users[sorted(dtf_users.columns)]

dtf_users = pd.DataFrame(preprocessing.MinMaxScaler(feature_range=(0.5,1)).fit_transform(dtf_users.values), columns=dtf_users.columns, index=dtf_users.index)

#dtf_users.to_csv('users.csv')
dtf_products.to_csv('products.csv')