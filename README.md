# Los Angeles County Police Killings (2000 - May 2020)

This repository contains my work looking into the [Los Angeles Times'](https://www.latimes.com/) [database](https://github.com/datadesk/los-angeles-police-killings-data) of deaths at the hands of local police in Los Angeles County. My latest extraction of their database for my output was on June 13, 2020. 

At the time the data was extracted, there were 885 recorded deaths. Almost all relevant fields were complete with 3 people missing a recorded race, one without a gender & cause of death, and 7 with some details about where the deaths took place missing.

After looking at the deaths as a whole throughout the 20 years in terms of race, cause of death, and neighborhood, I checked to see if there was a pattern in the number of deaths. There didn't seem to be one, but I did learn there were only 4 months in those 20 years that no one died at the hands of police.

Since the deaths of Black people (24.7%) is alarmingly disproportionate with their population (9%), I wanted to learn more about the details of their deaths. Inglewood, Long Beach, and Compton had the highest concentrations of black killings in the last 20 years, accounting for 22% of the 219 killings. The remaining 71 neighborhoods each had less than half of the number of killings in either of the three. Most of them were in their 20s and 30s.

My exploratory data analysis was done in python using `pandas`, `matplotlib`, `seaborn`, `bokeh`, and `plotly`. 

I created a compilation of plots of the findings I wanted to share using R and `ggplot`, `cowplot`, `ggtext`, and `extrafont`. 