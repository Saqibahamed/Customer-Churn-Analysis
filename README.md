# 📊 Customer Churn Prediction and Analysis

## 🔍 Project Overview

This project analyzes customer churn behavior in a telecom company to identify key factors influencing customer attrition and provide actionable business recommendations.
- It also includes a machine learning model to predict customer churn.

## 🚀 Live Demo

## 👉 Try the app here: https://your-app.streamlit.app


## 🎯 Objectives
- Identify high-risk customer segments
- Analyze churn across demographics, services, and contracts
- Provide data-driven retention strategies
- Build a predictive model to identify churn-prone customers
  
## 🛠️ Tools Used
- SQL (Data Cleaning & Analysis)
- Power BI (Dashboard & Visualization)
- Excel (Initial exploration)
- Python (Machine Learning)
- Scikit-learn, Imbalanced-learn (SMOTE)

## 🤖 Machine Learning Model

A Logistic Regression model was built to predict customer churn.

### 🔧 Approach
- Data preprocessing using ColumnTransformer
- OneHotEncoding for categorical variables
- Feature scaling using StandardScaler
- Handling class imbalance using SMOTE
- Model built using a pipeline

## 📈 Model Performance
- Recall: ~91%
- ROC-AUC: ~0.84

- 👉 Threshold tuning (0.3) was applied to improve recall and capture more churn customers.

## 🌐 Web Application

-The project is deployed using Streamlit, allowing users to input customer details and get real-time churn predictions.

### Features:

- Interactive UI for user input
- Real-time churn probability prediction
- Threshold-based classification


## 📊 Key Insights
- Customers with month-to-month contracts have the highest churn (~43%)
- Customers with tenure less than 1 year show the highest churn (~47%)
- Fiber optic users have higher churn (~41%)
- Customers without services like Tech Support and Online Security churn more
- Electronic check users show the highest churn (~45%)

## 💡 Business Recommendations
- Promote long-term contracts with incentives
- Improve onboarding for new customers
- Bundle value-added services (Tech Support, Security)
- Optimize payment experience for electronic check users

## 📸 Dashboard Preview

<img width="2044" height="1050" alt="image" src="https://github.com/user-attachments/assets/b1a2b72c-335c-4f81-b2e9-0212e95ad9f4" />

## 🚀 Conclusion

This project combines data analysis and machine learning to uncover key drivers of churn and build a predictive system that helps businesses take proactive actions to retain customers.
