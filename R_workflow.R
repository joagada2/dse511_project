# IMPORT REQUIRED LIBRARIES

# IGNORE WARNINGS
options(warn = -1)
update.packages(ask = FALSE)
install.packages("glue")
install.packages("Rcpp")
install.packages("ggplot2")
install.packages("rvest")
install.packages("tidyr")
install.packages("corrplot")
install.packages("reshape2")
install.packages("reshape2", type = "source")
Sys.which("make")



library(tidyr)
library(ggplot2)
library(rvest)
library(dplyr)
library(ggplot2)
library(tidyr)
library(corrplot)
library(reshape2)
library(GGally)
library(corrplot)



# SCRAPING NBA DATA
url <- "https://www.basketball-reference.com/leagues/NBA_2024_per_game.html"
webpage <- read_html(url)

# EXTRACT THE DATA TABLE
nba_table <- webpage %>%
  html_node("table#per_game_stats") %>%
  html_table(fill = TRUE)

# CLEANING THE DATA
nba_data <- nba_table %>% 
  filter(Rk != "Rk") %>%                # Remove header rows
  mutate(across(everything(), as.character)) %>% 
  mutate(across(where(is.numeric), as.numeric)) # Convert numeric columns

# VIEW BASIC DATA INFO
head(nba_data)           # View first 5 rows
dim(nba_data)            # Get dimensions (rows and columns)
colnames(nba_data)       # Display column names
str(nba_data)            # Check structure of the data

# CHECK FOR MISSING VALUES
missing_summary <- nba_data %>% summarise(across(everything(), ~ sum(is.na(.))))
missing_percentage <- missing_summary / nrow(nba_data) * 100

# HANDLE MISSING VALUES
nba_data <- nba_data %>%
  select(-Awards) %>%                            # Drop 'Awards' column
  mutate(across(where(is.numeric), ~ replace_na(., mean(., na.rm = TRUE)))) %>%
  drop_na(Team)                                  # Remove rows with missing 'Team'

# GENERATE DESCRIPTIVE STATISTICS
summary_stats <- nba_data %>%
  summarise(across(where(is.numeric), list(mean = ~ mean(.), sd = ~ sd(.))))

# ANALYSIS: RELATIONSHIP BETWEEN VARIABLES
# Number of Games by Age
age_vs_games <- nba_data %>%
  group_by(Age) %>%
  summarise(Games = sum(G, na.rm = TRUE))

str(nba_data$G)
nba_data$G <- as.numeric(nba_data$G)



ggplot(age_vs_games, aes(x = Age, y = Games)) +
  geom_line() +
  labs(title = "Age vs Number of Games", x = "Age", y = "Number of Games") +
  theme_minimal()

# Minutes Played by Age
age_vs_minutes <- nba_data %>%
  group_by(Age) %>%
  summarise(Minutes = sum(MP, na.rm = TRUE))

ggplot(age_vs_minutes, aes(x = Age, y = Minutes)) +
  geom_line() +
  labs(title = "Age vs Minutes Played", x = "Age", y = "Minutes Played") +
  theme_minimal()

# DISTRIBUTION OF POINTS PER GAME
ggplot(nba_data, aes(x = PTS)) +
  geom_histogram(bins = 20, fill = "blue", color = "black") +
  labs(title = "Distribution of Points per Game", x = "Points per Game", y = "Frequency") +
  theme_minimal()

# CORRELATION MATRIX
numeric_cols <- nba_data %>%
  select(where(is.numeric))

cor_matrix <- cor(numeric_cols, use = "complete.obs")

# Heatmap of Correlation
corrplot(cor_matrix, method = "color", col = colorRampPalette(c("blue", "white", "red"))(200), tl.cex = 0.8)

# VISUALIZATION OF RELATIONSHIPS
# Pairplot
ggpairs(numeric_cols, diag = list(continuous = "densityDiag"))

# Scatter Plot: Rank vs Field Goal
ggplot(nba_data, aes(x = Rk, y = FG)) +
  geom_point(color = "red") +
  labs(title = "Rank vs Field Goal", x = "Rank", y = "Field Goal") +
  theme_minimal()

# Scatter Plot: Assists vs Points
ggplot(nba_data, aes(x = AST, y = PTS)) +
  geom_point(color = "red") +
  labs(title = "Assists vs Points", x = "Assists per Game", y = "Points per Game") +
  theme_minimal()
