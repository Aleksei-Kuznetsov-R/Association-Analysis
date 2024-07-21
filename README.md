# Association-Analysis

It is often used to identify patterns or rules that describe the relationship between different events or objects. In the hospitality industry, it can be used to analyze the services that customers most frequently order together.

Hotels typically conduct such analysis on services that they later include in package deals. For example, booking a deluxe room and getting a discount on a spa service. This way, sales of a specific room category and spa services are stimulated.

We will consider a more complex example that is extremely rare in the hospitality industry. Suppose the task is to consider guests' preferences and outlets.So we will try to find what guests prefer to order together and when and where.

So let's first define the terms:

**Support:**
_Support_ measures how frequently the itemset appears in the dataset. Formally, the support of the rule A→B is defined as the proportion of transactions that contain both A and B.

Support (𝐴→𝐵)= Number of transactions containing both A and B / Total number of transactions

**Confidence:**
_Confidence_ measures how often the items in B appear in transactions that contain A. Formally, the confidence of the rule A→B is defined as the proportion of transactions containing A that also contain B.

Confidence(𝐴→𝐵) = Number of transactions containing both A and B / Number of transactions containing A
 
**Coverage:**
_Coverage_ measures the proportion of transactions that contain the antecedent A. It is essentially the support of A.

Coverage(𝐴→𝐵) = Number of transactions containing A / Total number of transactions

**Lift:**
_Lift_ measures how much more likely the consequent B is to appear in transactions that contain the antecedent A compared to its typical frequency in all transactions. Formally, lift is defined as the ratio of the confidence of the rule to the support of the consequent. Lift indicates the strength of the association between A and B. If the lift is greater than 1, it indicates a positive association between A and B; if the lift is less than 1, it indicates a negative association.

Lift(𝐴→𝐵) = Confidence(𝐴→𝐵) / Support(𝐵)

**Count:**
The absolute number of transactions containing both A and B.

Files in repository:
1. Association Analysis.R - full R code to conduct calculations
2. Micros_Base_csv - a base from POS system which is called Oracle Simphony POS Systems, which consist of raw data
3. 2_way_association_rules.csv and other x_way.csv files - are results from calculations

Association Analysis.R:
Has 3 different approaches for calculations:
1. Simple and straightforward analysis of 2 way lift
2. Simple loop for X-way-lift
3. Custom analysis where you can choose what to analysis in each side (rhs or lhs)
