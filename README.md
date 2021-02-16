# covid_proc

This repository has all the ongoing work with covid procurements. 

The following are the files and what they contain

AOC_Proc.R - Works with the award of contracts document that data  across India From March 5th to End of August 2020 (when the COVID lockdown and subsequent reopening occuring.) The file names are all labelled "aoc_x_number.csv" and can be downloaded from the org google drive. The code is used to clean the files, merge them and then create a box plot for number of bids awarded by state during that time period and also the top ten procurements doing that state. 

Vaccinemaps.R - is a piece of code that takes the vaccinated and to be vaccinated individuals in india and creates a chloropath map of vaccinated individuals, total individuals planned for vaccination and numbers left to vaccinate from the csv files "states_vaccinex.csv" which is directly gotten from the HTML files put out by the [press information bureau 1](https://www.pib.gov.in/PressReleasePage.aspx?PRID=1697568) and [Press Information Bureau 2](https://www.pib.gov.in/PressReleasePage.aspx?PRID=1694433)

Covid_proc_large.RMD is a markdown file which takes data from two kinds of csv's titled

"results_x.csv" which is in turn gotten by running the file titled procuremenrs_scrapper on the mission mode portal. The data is from early march to december. It took two weeks to get all the data. 
"results_state_tenders.csv" - which is a list of ~300 tenders with covid or corona in their title or description. 

For Results_c_csv: 
more detail on data, check file. There are about 50000 unique tender ids in this file. The code cleans and merges the results_csv files.
And then creates a state-wise and worktype-wise box plot to see 

- Average number of days to submit bid
- States with maximum number of tenders
- It also does the same after removing outliers. 
- it also creates a grouped bar graph with number of tender which took <30 days for bid eval, 30-60 days and >60 days. 
- It then goes on to extract any "health" related procurements using a list of keywords (check file for key words)
- And then performs the same analysis on them

For state_tenders.csv
The data was extracted from the eproucrement portal manually. data tagged as covid starts appearing from july. Therefore the data available is from july - dec. 
The file is manually tagged with a column title type covid purchase type - which indicates if the purchase was toward covid detection, information, treatment, ward etc.. 
It then looks at statewise differences in number and value of tenders as well as number of bids. 
It then splits the 6 months of the study into groups of 2 and sees what kind of purchases where made in what month. 

Next steps is to see what the different line item prices for different covid purchases (masks, sanitizer, rtpcr kits, immune assay kits etc..) are in different states and different times. 
As well as see how best to split the tagged health related procurements into meaningful groups for further analysis. 

- Covid_blog.RMD - is a general flow of the potential article. on covid procurements. 
