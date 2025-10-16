# E-Commerce Data Pipeline #

## 🎯 Overview ##

This project demonstrates a modern end-to-end data pipeline for e-commerce analytics.
It extracts raw event data, transforms it with Apache Spark, loads it into PostgreSQL, models it using dbt, and visualizes business insights with Apache Superset.

## 🧱 Project Architecture ##

```
Raw CSV (Landing) 
   ↓
Bronze Layer (Spark)
   ↓
PostgreSQL (Staging)
   ↓
dbt (Silver & Gold models)
   ↓
Superset Dashboard (Visualization)
```

![flow diagram](https://github.com/agomaa20011/ecommerce-pipeline/blob/main/pipeline%20Arch.drawio.png)


## ⚙️ Technologies Used ##

| Tool | Purpose |
|------|----------|
| 🐍 **Python** | Core programming language used for scripting and automation |
| 🔥 **Apache Spark** | Data cleaning, transformation, and Parquet file generation |
| 🐘 **PostgreSQL** | Central data warehouse for structured storage |
| 🧱 **dbt** | Data modeling and schema management (staging → silver → gold) |
| 📊 **Apache Superset** | Data visualization and interactive dashboards |
| 🐙 **GitHub** | Version control and project collaboration |

## 🧩 Data Architecture Layers ##

### 🟤 Bronze Layer (Raw → Cleaned Parquet) ###
	•	Tool: Apache Spark
	•	Input: CSV files (data/landing/)
	•	Output: Cleaned, partitioned Parquet files (data/bronze/events/)
	•	Main script: bronze_transform.py

Key operations:
	•	Lowercasing text fields (brand, category_code)
	•	Parsing timestamps
	•	Adding ingestion metadata (ingested_at, event_date)

### 🟠 Staging Layer (stg in PostgreSQL) ###

![stg](https://github.com/agomaa20011/ecommerce-pipeline/blob/main/data%20warehous%20stg.drawio.png)

	•	Table: stg.events
	•	Created by: load_to_postgres.py
	•	Purpose: Store typed, validated event data directly from the bronze layer before business transformations.

### ⚪ Silver Layer (silver schema) ###

![silver](https://github.com/agomaa20011/ecommerce-pipeline/blob/main/data%20warehous%20silver.drawio%20(1).png)

Purpose: Transform raw events into a star schema for analytical modeling.

Relationships:
dim_users (1)───< fact_events >───(1) dim_products

### 🟡 Gold Layer (analytics schema via dbt) ###

Purpose: Create business-ready metrics and aggregations for the dashboard.

| Model | Description |
| ------------- | ------------- |
| analytics.daily_conversion  | Daily conversion rates by date |
| analytics.hourly_activity | Activity trends per hour |
| analytics.session_metrics | Session-level KPIs |
| analytics.top_products | Top-selling and viewed products |
| analytics.category_price_trends  | Price trends per category |

## 📂 Project Structure ##

```
ecommerce-pipeline/
│
├── data/
│   ├── landing/      # raw CSVs (not uploaded)
│   ├── bronze/       # parquet files (not uploaded)
│
├── dbt/
│   ├── models/
│   │   ├── gold/
│   │   │   ├── daily_conversion.sql
│   │   │   ├── hourly_activity.sql
│   │   │   ├── session_metrics.sql
│   │   │   ├── top_products.sql
│   │   │   └── category_price_trends.sql
│   ├── schema.yml
│   ├── source.yml
│   └── dbt_project.yml
│
├── bronze_transform.py      # Spark transformation (landing → bronze)
├── load_to_postgres.py      # Load parquet → PostgreSQL staging
├── run_pipeline.sh          # Runs all steps end-to-end
├── superset_config.py       # Superset configuration
├── requirements.txt         # Python dependencies
├── .gitignore
└── README.md
```

## 🚀 How to Run the Project ##

### 1️⃣ Set up PostgreSQL ###
	1.	Install PostgreSQL (version 14 or newer).
    2.  2. Create a new database and user:
	sql
	CREATE DATABASE ecommerce_pipeline;
	CREATE USER postgres WITH PASSWORD '1234';
	GRANT ALL PRIVILEGES ON DATABASE ecommerce_pipeline TO postgres;

### 2️⃣ Install dependencies ###
```
pip install -r requirements.txt
```

### 3️⃣ Prepare directories ###
```
data/
 ├── landing/  ← place your CSV files here
 └── bronze/
```
 ### 4️⃣ Run the full pipeline ###
 ```
 bash run_pipeline.sh
 ```

 This will:
	•	Read & clean CSV data (Spark)
	•	Write Parquet files
	•	Load them into PostgreSQL
	•	Run dbt models & tests

### 5️⃣ Launch Superset dashboard ###
```
superset run -p 8088 --host 127.0.0.1
```

Then open:
```
http://localhost:8088
```

## 📊 Dashboard Metrics ##
The dashboard includes:
• Top Products by Revenue
• Daily Conversion Rates
• Session Metrics
• Category Price Trends
• Hourly User Activity

![dashboard](https://github.com/agomaa20011/ecommerce-pipeline/blob/main/Screenshot%202025-10-16%20at%2020.59.01.png)
![dashboard](https://github.com/agomaa20011/ecommerce-pipeline/blob/main/Screenshot%202025-10-16%20at%2020.59.28.png)



### 💡 Notes ###
* The raw dataset is not uploaded due to size limits.You can download it from [Kaggle](https://www.kaggle.com/datasets/yashtyagi1712/ecommercebehaviordatafrommulticategorystore).
* Database connection details are defined in profiles.yml.
* To rebuild the dashboard, connect Superset to your PostgreSQL database and import the SQL models.


---

👤 **Author:** Ahmed Abohamad  




