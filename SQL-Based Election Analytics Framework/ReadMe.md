## Project Overview

This project was undertaken to revolutionize the way our organization handles electoral Form 20 data, which is critical for political consulting and research. Traditionally, this data was manually downloaded, cleaned, and analyzed in Excel—a process that was time-consuming, error-prone, and required repetition for each new analysis request.

## Problem Statement

#### Traditional Method: 
Data analysis was performed in Excel, taking a minimum of 3 hours per analysis, with no centralized storage for the cleaned data. Each analysis was recreated from scratch, leading to inefficiencies and redundant work.

#### Challenges: 
Inconsistent analysis time, manual repetition, and the lack of a centralized database for storing and accessing large datasets.

## Solution

To address these challenges, I leveraged my expertise in Relational Databases and SQL to build a centralized database system that stores all Polling data (Form 20) in a structured format. Here’s what I implemented:

#### Database Design: 
Created a relational database with tables for storing Polling data across various states, election types, and years, ensuring all data is centralized and accessible.
#### Automation with SQL: 
Replaced manual Excel analysis with automated SQL queries. Used advanced SQL concepts such as Stored Procedures, CTEs, Table-Valued Functions, Window Functions, and Dynamic SQL to replicate and enhance the analysis process.
#### Dynamic Analysis: 
Implemented a system where users can easily input parameters like State, Election Type, and Year to dynamically generate analysis for any dataset stored in the database.
#### Power BI Integration: 
Connected the SQL database to Power BI via Direct Query, creating a generalized reporting template. This allows instant visualization of analysis results by simply updating the SQL parameters and refreshing the Power BI report.
#### Data Integrity with Python: 
Leveraged Python Data Analysis Packages like Pandas to create a Data Integrity Script that checks Form 20 data for errors such as unmatched totals, null values, and incorrect string entries. This script identifies files requiring manual intervention, ensuring only clean, accurate data is stored in the database. This automation saved countless hours and significantly improved efficiency.
#### Data Pipeline Automation: 
Developed another Python script that connects directly to the SQL database to automate the processing and storage of Form 20 data. This script streamlined the data loading process, eliminating the need for manual entry via the SQL interface.

### Why SQL Server?
I chose SQL Server for this project due to its enterprise-grade reliability, advanced security features, and seamless integration with other Microsoft tools. SQL Server’s optimized performance, especially with large-scale datasets, made it ideal for managing the complex and voluminous data related to electoral analysis. Its robust support for stored procedures, indexing, and partitioning allowed for efficient query performance, which was essential for the dynamic and real-time analysis required in this project.

Another key reason is SQL Server’s ease of writing table-valued functions, which provided flexibility and reusability in managing complex business logic within queries. Additionally, the importing process in SQL Server offers more control compared to other technologies, allowing for customized data loading strategies that enhance data integrity and reliability. Together, these features made SQL Server a powerful and sustainable solution for the organization's evolving needs.

## Impact

#### Efficiency: 
Reduced the analysis time from 3 hours to just a few minutes, significantly increasing productivity and allowing the team to focus on strategic tasks.
#### Scalability: 
Enabled scalable analysis across different states and election types without the need for repetitive manual work.
#### User-Friendly: 
Made it easy for non-technical users to perform complex data analysis by simplifying the process down to just entering a few parameters.

