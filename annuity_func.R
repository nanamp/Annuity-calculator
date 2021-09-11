annuity_func <- function(start_age) {
# load libraries
library(tidyverse)

# load data (mortality & interest rates)
raw_mort <- read.csv('a90m.txt')
raw_int <- read.csv('Yield Curve.txt')

# rename columns
mort <- rename(raw_mort, Age = Age.x, Mort_Rate = qx)
interest  <- rename(raw_int, Time = t..year., Int_Rate = Interest.Rate)

# calculate survival probabilities
mort['Surv_Rate'] = 1 - mort['Mort_Rate']

# calculate discount factors
interest['Disc_Fac'] = 1 / (1 + interest['Int_Rate']/100) 
# the yield curve is that for spot rates, so each time point has a different v and can be raised to the power t
interest['Disc_Fac_^_t'] = interest['Disc_Fac'] ^ (interest['Time'])


# create an array with the age, survival rate and cumulative survival rate, starting from the age given
cumsurv <- 1
min_age <- mort[1, "Age"]
max_age <- mort[nrow(mort), "Age"]
max_row <- nrow(mort)
output <- matrix(,(max_age - start_age + 1), 3)
counter <- 0 # counter for the rows
for (i in 1:max_row) {
  if (mort[i, "Age"] >= start_age) {
    counter <- counter + 1
    age <- mort[i, "Age"]
    surv <- mort[i, "Surv_Rate"]
    cumsurv <- cumsurv * surv        
    output[counter,] <- c(age, surv, cumsurv) # assign values to the empty rows
  }
new_mort <- data.frame(output) # assign output to a data frame
colnames(new_mort) <- c("Age","Surv_Rate", "Cum_Surv_Rate")} # set column names

# create an array of discount rates with the same size as the cumulative survival rate array above
output <- matrix(,(max_age - start_age + 1), 1)
max_row <- nrow(interest)
nrow_req <- (max_age - start_age + 1) # maximum number of rows required
counter <- 0
for (i in 1:max_row) {
  if (i <= nrow_req) {
    counter <- counter + 1
    disc <- interest[i, "Disc_Fac_^_t"]
    output[counter,] <- c(disc)
  }
new_int <- data.frame(output)
colnames(new_int) <- c("Discount") }

# multiply cumulative survival by discount rate and sum
annuity <- 0 # initialize annuity value
for (i in 1:nrow(new_int)) {
  value <- new_mort[i, "Cum_Surv_Rate"] * new_int[i, "Discount"]
  annuity <- annuity + value }
  
annuity  
}