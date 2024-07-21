# Installing the necessary packages
install.packages("tidyr")
install.packages("dplyr")
install.packages("arules")
install.packages("data.table")
# load the libraries
library(tidyr)
library(dplyr)
library(arules)
library(data.table)

#Loading data from file
file_path <- "D:/GitHub/Associations/Micros_Base.csv"
original_data <- fread(file_path)

#Data preperation ----------
# Collecting unique "Outlet" entries to exclude those not participating in data collection
unique_outlets <- unique(original_data$Outlet)
# Filtering data to exclude unnecessary "Outlet" entries
# This way, we retain only key dining points such as the restaurant, lobby bar, and room service.
data <- original_data %>%
  filter(
    !Outlet %in% c(
      "Pavillion Pantry",
      "Banquet",
      "Canteen",
      "Offsite Catering",
      "Grab N Go"
    )
  )

# Keep only the columns #Check, Family_Group, Serving_Period, and Outlet.
data <- data %>% select(`#Check`, Family_Group, Serving_Period, Outlet)


# Collecting unique Family_Group entries
unique_Family_Group <- unique(data$Family_Group)

# Creating a list of phrases for removal
remove_FG <- c(
  "Open Food",
  "Periodical Promoti",
  "Delivery Charge",
  "ADDITIVES",
  "Open Wine",
  "Open Beer",
  "Chockolate",
  "Misc. Tax",
  "JUICE",
  "Food Modifiers",
  "Breakfast",
  "Banquet Food",
  "Amenities",
  "Open Beverage",
  "Juice",
  "Water",
  "Set Menu",
  "Milk"
  # Add all necessary phrases here
)

# Find rows containing any of the texts from remove_FG
rows_to_remove <- unique(unlist(lapply(remove_FG, function(x)
  grep(x, data$Family_Group))))
# Add rows where text_column == NA
rows_to_remove <- c(rows_to_remove, which(is.na(data$Family_Group)))
# Remove rows identified for removal
df_cleaned <- data[-rows_to_remove, ]

# Converting tibble to data.table
df_cleaned <- as.data.table(df_cleaned)

# Creating unique values for each column
df_cleaned[, Outlet := paste0("", Outlet)]
df_cleaned[, Serving_Period := paste0("", Serving_Period)]
df_cleaned[, Family_Group := paste0("", Family_Group)]

# Combining all values into one long table
data_long <- rbindlist(list(df_cleaned[, .(`#Check`, variable = Outlet)], df_cleaned[, .(`#Check`, variable = Serving_Period)], df_cleaned[, .(`#Check`, variable = Family_Group)]))

# Removing duplicates
data_long <- unique(data_long)

# Adding a column with dummy variables
data_long[, value := 1]

# Converting data to wide format
df_transformed <- dcast(data_long,
                        `#Check` ~ variable,
                        value.var = "value",
                        fill = 0)

# Removing the #Check column
df_transformed <- df_transformed[, -c("#Check", "NA"), with = FALSE]

# Converting data to transactions object
data_transactions <- as(as.matrix(df_transformed), "transactions")

# 2-way lift analysis ----
# Performing association analysis using the Apriori algorithm
rules_2 <- apriori(data_transactions, parameter = list(
  supp = 0.1,
  conf = 0.5,
  maxlen = 2
))
# Sorting the best 2-way lift rules
rules_2way_sorted <- sort(rules_2, by = "lift")

# Saving the 2-way lift rules to a CSV file
rules_2way_df <- as(rules_2way_sorted, "data.frame")
write.csv(rules_2way_df,
          "D:/GitHub/Associations/2_way_association_rules.csv",
          row.names = FALSE)


#X-way-lift (loop example) ----

x = 1

repeat {
  x = x + 1
  
  # Performing association analysis using the Apriori algorithm for rules with x elements
  rules <- apriori(data_transactions, parameter = list(
    supp = 0.1,
    conf = 0.5,
    maxlen = x
  ))
  # Filtering rules to keep only those with exactly x elements
  rules_elements <- subset(rules, size(rules) == x)
  # Sorting rules by lift
  rules_sorted <- sort(rules_elements, by = "lift")
  
  #Save report -----
  # Saving association rules to a CSV file
  rules_df <- as(rules_sorted, "data.frame")
  write.csv(
    rules_df,
    paste0("D:/GitHub/Associations/", x, "_way_association_rules.csv"),
    row.names = FALSE
  )
  
  if (x == 7) {
    break
  }
  
}

# Custom search ----

# Performing association analysis using the Apriori algorithm for rules with up to n elements
rules <- apriori(data_transactions, parameter = list(
  supp = 0.01,
  conf = 0.05,
  maxlen = 2
))
# Filtering rules to keep only those with exactly n elements
rules_elements <- subset(rules, size(rules) == 2)
# Sorting rules by lift
rules_sorted <- sort(rules_elements, by = "lift")

# Functions for Custom search
# Function to find rules where an item is in the left-hand side (LHS)
find_rules_lhs <- function(item) {
  subset_rules <- subset(rules_sorted, lhs %pin% item)
  # Exclude rules with an empty right-hand side (RHS)
  subset_rules <- subset(subset_rules, size(rhs(subset_rules)) > 0)
  return(subset_rules)
}
# Function to find rules where an item is in the right-hand side (RHS)
find_rules_rhs <- function(item) {
  subset_rules <- subset(rules_sorted, rhs %pin% item)
  # Exclude rules with an empty left-hand side (LHS)
  subset_rules <- subset(subset_rules, size(lhs(subset_rules)) > 0)
  return(subset_rules)
}


# Example usage of the functions
# Finding rules with "Room Service" in the left-hand side (LHS)
rules_lhs <- find_rules_lhs("Room Service")
rules_lhs_sorted <- sort(rules_lhs, by = "lift")
inspect(head(rules_lhs_sorted, 20))

# Finding rules with "Room Service" in the right-hand side (RHS)
rules_rhs <- find_rules_rhs("Room Service")
rules_rhs_sorted <- sort(rules_rhs, by = "lift")
inspect(head(rules_rhs_sorted, 20))
