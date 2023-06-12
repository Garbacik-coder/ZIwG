import numpy as np
import pandas as pd
pd.set_option('display.max_columns', 500)
import re
from datetime import datetime
import matplotlib.pyplot as plt
from tensorflow.keras import models, layers

dtf_users = pd.read_csv('users.csv', index_col='user')
dtf_products = pd.read_csv('products.csv', index_col='product')
dtf_products = dtf_products.drop(['name', 'year', 'genres', 'description', 'image', 'length'], axis=1)

def create_model(dtf_users, dtf_products):
    features = dtf_products.columns

    split = int(0.8 * dtf_users.shape[1])
    dtf_train = dtf_users.iloc[:, :split]
    dtf_test = dtf_users.iloc[:, split:]

    train = dtf_train.stack(dropna=True).reset_index().rename(columns={'level_1':'product', 0:'y'})
    train['product'] = train['product'].apply(lambda x: int(x))

    train = train.merge(dtf_products[features], how='left', left_on='product', right_index=True)

    embeddings_size = 50
    usr, prd = dtf_users.shape[0], dtf_users.shape[1]
    feat = len(features)

    xusers_in = layers.Input(name='xusers_in', shape=(1,))
    xproducts_in = layers.Input(name='xproducts_in', shape=(1,))

    cf_xusers_emb = layers.Embedding(name='cf_xusers_emb', input_dim=usr, output_dim=embeddings_size)(xusers_in)
    cf_xusers = layers.Reshape(name='cf_xusers', target_shape=(embeddings_size,))(cf_xusers_emb)

    cf_xproducts_emb = layers.Embedding(name='cf_xproducts_emb', input_dim=prd, output_dim=embeddings_size)(xproducts_in)
    cf_xproducts = layers.Reshape(name='cf_xproducts', target_shape=(embeddings_size,))(cf_xproducts_emb)

    cf_xx = layers.Dot(name='cf_xx', normalize=True, axes=1)([cf_xusers, cf_xproducts])

    nn_xusers_emb = layers.Embedding(name='nn_xusers_emb', input_dim=usr, output_dim=embeddings_size)(xusers_in)
    nn_xusers = layers.Reshape(name='nn_xusers', target_shape=(embeddings_size,))(nn_xusers_emb)

    nn_xproducts_emb = layers.Embedding(name='nn_xproducts_emb', input_dim=prd, output_dim=embeddings_size)(xproducts_in)
    nn_xproducts = layers.Reshape(name='nn_xproducts', target_shape=(embeddings_size,))(nn_xproducts_emb)

    nn_xx = layers.Concatenate()([nn_xusers, nn_xproducts])
    nn_xx = layers.Dense(name='nn_xx', units=int(embeddings_size/2), activation='relu')(nn_xx)

    features_in = layers.Input(name='features_in', shape=(feat,))
    features_x = layers.Dense(name='features_x', units=feat, activation='relu')(features_in)

    y_out = layers.Concatenate()([cf_xx, nn_xx, features_x])
    y_out = layers.Dense(name='y_out', units=1, activation='linear')(y_out)

    model = models.Model(inputs=[xusers_in, xproducts_in, features_in], outputs=y_out, name='Hybrid_Model')
    model.compile(optimizer='adam', loss='mean_absolute_error', metrics=['mean_absolute_percentage_error'])

    training = model.fit(x=[train['user'], train['product'], train[features]], y=train['y'], 
                         epochs=100, batch_size=128, shuffle=True, verbose=0, validation_split=0.3)
    model = training.model

    model.save('zapisany_model3')