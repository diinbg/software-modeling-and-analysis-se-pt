# Instagram Analytics

## 9. Author

- **Student name:** Blagovest Borukov
- **Faculty number:** 2501322041

## 1. Project Overview

Instagram Analytics is a university project for modeling an Instagram-like social media platform, implementing a relational database, building a Data Warehouse, and analyzing social media activity using Microsoft Power BI.

The project demonstrates database design, SQL programming, data warehousing, and business intelligence reporting.

## 2. Technologies Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL
- Microsoft Power BI Desktop
- draw.io
- Git and GitHub

## 3. Project Structure

```text
InstagramAnalytics/
├── Database/
│   ├── 01_Create_InstagramDB.sql
│   ├── 02_Seed_InstagramDB.sql
│   └── 03_Procedures_Functions_Triggers.sql
├── DataWarehouse/
│   ├── 04_DataWarehouse_Instagram.sql
│   ├── 05_DW_BridgePostHashtag.sql
│   └── Instagram_DataWarehouse_Diagram.drawio
├── Diagrams/
│   └── Database_Models.drawio
├── PowerBI/
│   ├── InstaDBPowerBI.pbix
│   └── dashboard.png
└── README.md
```

## 4. Relational Database

The relational database is named `InstagramDB` and is implemented in Microsoft SQL Server.

It models the main functionality of a social media platform through entities such as:

- Users
- Posts
- Follows
- Likes
- Comments
- Hashtags
- PostHashtags
- Stories
- Messages
- PostViews

The database includes primary keys, foreign keys, constraints, indexes, stored procedures, user-defined functions, and triggers.

## 5. Data Warehouse

The Data Warehouse is designed for analytical reporting and contains three fact tables:

- `FactPostEngagement`
- `FactPostViews`
- `FactUserActivity`

It includes the following dimensions:

- `DimUser`
- `DimDate`
- `DimPost`
- `DimHashtag`
- `DimActivityType`
- `DimMediaType`

The `BridgePostHashtag` table supports the many-to-many relationship between posts and hashtags.

The physical Data Warehouse model is provided in `DataWarehouse/Instagram_DataWarehouse_Diagram.drawio`.

## 6. Power BI Report

The Power BI dashboard presents key performance indicators and visual analyses, including:

- Total Likes
- Total Views
- Total Comments
- User Activity Over Time
- Top 10 Posts by Engagement
- Views by Media Type

The report uses data from the Data Warehouse to summarize engagement and viewing activity.

## 7. Installation and Execution

### Requirements

Install the following software:

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Microsoft Power BI Desktop

### Step 1: Create the relational database

Open `Database/01_Create_InstagramDB.sql` in SSMS and execute the script.

### Step 2: Insert sample data

Execute `Database/02_Seed_InstagramDB.sql` to populate the relational database with demonstration data.

### Step 3: Create database objects

Execute `Database/03_Procedures_Functions_Triggers.sql` to create the stored procedures, functions, and triggers.

### Step 4: Create and populate the Data Warehouse

Execute the scripts in this order:

1. `DataWarehouse/04_DataWarehouse_Instagram.sql`
2. `DataWarehouse/05_DW_BridgePostHashtag.sql`

### Step 5: Open the Power BI report

Open `PowerBI/InstaDBPowerBI.pbix` using Power BI Desktop.

If necessary, update the SQL Server connection settings and refresh the data.

## 8. Database Diagrams

The `Diagrams/` directory contains the conceptual model using Chen notation and the logical model using Crow's Foot notation.

The `DataWarehouse/` directory contains the physical Data Warehouse diagram.

The diagrams illustrate the entities, attributes, relationships, fact tables, and dimensions used in the project.