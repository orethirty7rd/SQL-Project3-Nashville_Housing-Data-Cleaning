# Portfolio_Project 3/4: Nashville Housing Data Cleanup 

Cleaning and standardising the Nashville Housing dataset using MySQL.  
This repo documents how I took a dataset and made it more analysis-ready by separating columns, removing duplicates, and standardising values.

---

## About the Project
The Nashville Housing dataset had a few common data issues:  
- Inconsistent formats (dates, addresses)  
- Duplicate entries  
- Combined values in single columns  

Using MySQL, I cleaned up the dataset so it’s easier to work with for analysis and visualisation.  

---

## SQL Techniques Used
Some of the main things I practised here:  

- **Splitting columns** → separating property and owner addresses into multiple fields using string functions (`SUBSTRING_INDEX`, `TRIM`)  
- **Standardising data** → fixing date formats, making values consistent with `CASE WHEN`  
- **Removing duplicates** → leveraging `ROW_NUMBER()` with CTEs  
- **Filtering & renaming** → using `ALTER TABLE` to make columns clearer  

---

## How to Use
1. Clone this repo  
2. Import the Nashville Housing dataset into MySQL. The original dataset (`Nashville_Housing.xlsx`) is included in the `data/` folder for easy access.
3. Run the SQL scripts to reproduce the cleaning steps  

---

## What I Learned
- How to combine CTEs with window functions to safely remove duplicates  
- Practical use of string functions to clean messy text data  
- The importance of standardising data before analysis  

---

## Future Improvements
- Add data visualisation (Python/Power BI)  
- Automate the cleaning pipeline  
- Extend the project with exploratory analysis  

---

