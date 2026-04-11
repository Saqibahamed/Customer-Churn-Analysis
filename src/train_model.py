import pandas as pd
import numpy as np
import joblib

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from imblearn.pipeline import Pipeline
from imblearn.over_sampling import SMOTE
from sklearn.linear_model import LogisticRegression

# =========================
# LOAD DATA
# =========================
df = pd.read_csv("data/Telco_churn.csv") # ensure to change the path and set it as yours

# =========================
# PREPROCESSING
# =========================

# Drop unnecessary column
df.drop(['customerID'], axis=1, inplace=True)

# Fix TotalCharges
df['TotalCharges'] = df['TotalCharges'].replace(' ', np.nan)
df['TotalCharges'] = df['TotalCharges'].astype(float)
df['TotalCharges'].fillna(df['TotalCharges'].median(), inplace=True)

# Convert target
df['churn'] = df['Churn'].map({'Yes': 1, 'No': 0})
df.drop(['Churn'], axis=1, inplace=True)

# Replace "No phone service" → "No"
df['MultipleLines'] = df['MultipleLines'].map({'Yes':'Yes','No':'No','No phone service':'No'})


# Replace "No internet service" → "No"
cols_to_fix = [
     'OnlineSecurity', 'OnlineBackup',
    'DeviceProtection', 'TechSupport',
    'StreamingTV', 'StreamingMovies'
]

for col in cols_to_fix:
    df[col] = df[col].replace('No internet service', 'No')

# =========================
# FEATURES & TARGET
# =========================
X = df.drop("churn", axis=1)
y = df["churn"]

# Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.25, stratify=y, random_state=42
)

# =========================
# FEATURE TYPES
# =========================
cat_features = [col for col in X.columns if X[col].dtype == 'O']
num_features = [col for col in X.columns if X[col].dtype != 'O']

# =========================
# COLUMN TRANSFORMER
# =========================
ct = ColumnTransformer([
    ('encoder', OneHotEncoder(drop="first"), cat_features),
    ('scaler', StandardScaler(), num_features)
])

# =========================
# FINAL PIPELINE
# =========================
pipe = Pipeline([
    ('preprocessor', ct),
    ('smote', SMOTE(random_state=42)),
    ('model', LogisticRegression(max_iter=1000))
])

# =========================
# TRAIN MODEL
# =========================
pipe.fit(X_train, y_train)

# Create folder if not exists
import oss
os.makedirs("model", exist_ok=True)

# =========================
# SAVE MODEL
# =========================
joblib.dump(pipe, "model/churn_model.pkl")

print(" Model trained and saved successfully!")
