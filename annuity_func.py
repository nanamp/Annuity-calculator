def annuity_func(start_age):
    import pandas as pd
    raw_mort = pd.read_csv('a90m.txt') #read in the mortality table
    mort = raw_mort.rename(columns = {"Age x":"Age", "qx":"Mort_Rate"}) #rename the columns
    mort['Surv_Rate'] = 1 - mort['Mort_Rate'] #add a column for the survival rates

    raw_int = pd.read_csv('Yield Curve.txt') #read in the interest rate table
    interest = raw_int.rename(columns = {"t (year)":"Time", "Interest Rate":"Int_Rate"}) #rename the columns
    interest['Disc_Fac'] = 1 / (1 + interest['Int_Rate']/100) #add a column for the discount factors (v)

    
    # the yield curve is that for spot rates, so each time point has a different v and can be raised to the power t
    interest['Disc_Fac_^_t'] = interest['Disc_Fac'] ** (interest['Time']) #add a column for the discount factor raised to the power t. 

    # create an array with the age, survival rate and cumulative survival rate, starting from the age given
    rows = []
    cumsurv = 1
    for index in mort.index:
        if mort.loc[index,'Age'] >= start_age:
            age = mort.loc[index,'Age']
            surv = mort.loc[index,'Surv_Rate']
            cumsurv = cumsurv * surv
            rows.append([age, surv, cumsurv])
    new_mort = pd.DataFrame(rows, columns = ["Age","Surv_Rate", "Cum_Surv_Rate"])
    last_ind = new_mort.tail(1).index.item()

    # create and array of discount rates with the same size as the cumulative survival rate array above
    rows = []
    for index in interest.index:
        if index <= last_ind:
            disc = interest.loc[index, 'Disc_Fac_^_t']
            rows.append([disc])
            new_disc = pd.DataFrame(rows, columns = ["Discount"])

    annuity = 0 # initialize annuity value
    
    # multiply cumulative survival by discount rate
    for index in new_disc.index:
        value = new_mort.loc[index, 'Cum_Surv_Rate']  * new_disc.loc[index, 'Discount'] 
        annuity = annuity + value
    # display answer
    print(annuity)  
