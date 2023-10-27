# G2 Vendor Analysis Overview


### I. Objective
The purpose is to create a tool/dashboard that provides a user with information about selected companies on G2. Visualize several KPIs and comparisons of the selected company to its competitors to show where the selected company stands within that category.

### II. High Level Requirements

| Requirement    | Description |
| -------- | ------- |
| Filter by the name of companies  | A drop-down bar that prompts the user to pick a company   |
| Compare the ratings of the selected company to its top 10 competitors | A number that shows the average rating of the top 10 competitors     |
| Compare the ratings of the selected company to the average ratings of the categories the selected company is in    | A graph that shows the average rating of the companies within that category and the rating of the selected company    |
| Show number of reviews and the average rating (number of stars) of the vendor of choice    | Highest level of information that gives a general overview of the company    |

### III. Metrics

To address the aforementioned technical requirements, the following list of metrics must be extracted:

- Number of reviews
- Average number of stars
  - By the companies in the same category
  - By industry

	
Top 10 competitors provided by G2 can give users a better idea on where the company stands among its competitors in technical terms instead of relying solely on the number of stars.

### IV. Data Sources

The dataset is obtained from this [link](https://gist.github.com/bAcheron/7a360c152fb156f5a4676191e35a7279) provided by [Seattle Data Guy](https://www.youtube.com/@SeattleDataGuy/videos) which he obtained through the Web Scraper IDE on Bright Data for G2.com. 

### V. Infrastructure

- Snowflake 
  - Process raw, scraped data from Bright Data and transform to structured tables
  - Query layers of processed tables to get desired metrics
- Tableau
  - Turn queried tables into interactive dashboards

### VI. Objects

*A separate ID column was not added to the following tables because of the small size of the dataset. However, for future reference, it is a recommended practice to add a primary ID column to each table.*

- vendor_rating

| Parameter | Data Type | Description |
| -------- | ------- | ------- |
| vendor_name | varchar | (PK) Name of the vendor |
| num_reviews | int | Total number of reviews of the vendor |
| num_stars | double | Average number of stars/ratings of the vendor |
| category_list | list[varchar] | List of categories the specific vendor is classified as |

- vendor_competitor_rating

| Parameter | Data Type | Description |
| -------- | ------- | ------- |
| vendor_name | varchar | (PK) Name of the vendor |
| competitor_name | varchar | (PK) Name of the competitor of the vendor |
| competitor_num_review | int | Total number of reviews of the competitor |
| competitor_num_stars | double | Average number of stars/ratings of the competitor |

- vendor_category_comparison

| Parameter | Data Type | Description |
| -------- | ------- | ------- |
| vendor_name | varchar | (PK) Name of the vendor |
| product_category | varchar | (PK) Name of the product category |
| num_of_stars | double | Average number of stars of the vendor |
| num_stars_category | double | Average number of stars/ratings of the companies in the category |
