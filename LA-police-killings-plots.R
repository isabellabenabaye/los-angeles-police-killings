library(tidyverse)
library(ggtext)
library(cowplot)
library(extrafont)
fonttable <- fonttable()
loadfonts(device = "win", quiet = TRUE) ## to load the font

# Import data -----
killings_data <- read_csv('https://raw.githubusercontent.com/datadesk/los-angeles-police-killings-data/master/los-angeles-police-killings.csv') %>% 
  mutate(race = as.factor(race),
         race = str_to_title(race))
population_data <- read_csv('QuickFacts Jun-12-2020.csv', n_max = 7, skip = 10, col_names = c("race","x1","percent","x2"))

pop_data <- population_data %>% 
  select(race,percent) %>% 
  filter(!race %in% c("American Indian and Alaska Native alone, percent","Native Hawaiian and Other Pacific Islander alone, percent","Two or More Races, percent")) %>% 
  mutate(pop_percent = as.numeric(sub("%", "", percent))/100,
         race = word(race,1),
         race = if_else(race == "Hispanic","Latino",race))

percentages <- killings_data %>% 
  group_by(race) %>% 
  summarise(n = n()) %>% 
  mutate(killings_percent = n/sum(n)) %>% 
  inner_join(pop_data)

# Theme -----
theme_set(theme_minimal())
theme <- theme_update(text = element_text(family = "IBM Plex Mono", color = "gray20"),
                      title = element_text("IBM Plex Mono SemiBold", size = 24),
                      plot.title = element_markdown(size = 25, color = "gray10", lineheight = 1.3),
                      plot.title.position = "plot",
                      plot.caption = element_text(family = "IBM Plex Mono", size = 14),
                      plot.subtitle = element_text(size = 20),
                      axis.text = element_text(size = 16),
                      axis.line = element_line(color = "gray20"),
                      plot.margin = margin(0, 30, 20, 0),
                      panel.grid = element_blank(),
                      plot.background = element_rect(fill = "#F7F7F7", color = "#F7F7F7"))

# Plots -----

# Percentage of population vs. deaths
perc_plot <- percentages %>% 
  ggplot(aes(y = fct_reorder(race, killings_percent))) +
  labs(x = "", y = "",
       title = "Percentage of <span style = 'color:#8F8F8F;'>population</span> vs. deaths at the hands of local police") +
  geom_bar(aes(x = pop_percent), stat = "identity", alpha = 0.15) +
  geom_bar(aes(x = killings_percent, fill = race), stat = "identity", width = 0.5, show.legend = FALSE) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1), expand = expansion(0,0), limits = c(0,.6)) +
  paletteer::scale_fill_paletteer_d("ggsci::default_jama") +
  theme(axis.line.y = element_blank(), axis.ticks.x = element_line(color = "gray20"))


# In which neighborhoods were the most Black and Latino people killed by police?
# Neighborhoods with the most deaths of black people
neighborhoods_black <- killings_data %>% 
  filter(race == "Black") %>% 
  group_by(neighborhood) %>% 
  summarise(n = n()) %>% 
  top_n(7) %>% 
  ungroup() %>% 
  ggplot(aes(n, fct_reorder(neighborhood,n))) +
  labs(x = "", y = "",
       title = "") +
  geom_bar(stat = "identity", fill = "#DF8F44") +
  ## count labels
  geom_text(aes(label = n),
            color = "white",
            position = position_stack(vjust = 0.5), family = "IBM Plex Mono", size = 5) +
  theme(axis.text.x = element_blank(), axis.line = element_blank())

# Neighborhoods with the most deaths of latino people
neighborhoods_latino <- killings_data %>% 
  filter(race == "Latino") %>% 
  group_by(neighborhood) %>% 
  summarise(n = n()) %>% 
  top_n(7) %>% 
  ungroup() %>% 
  ggplot(aes(n, fct_reorder(neighborhood,n))) +
  labs(x = "", y = "") + 
  geom_bar(stat = "identity", fill = "#00A1D5") +
  ## count labels
  geom_text(aes(label = n),
          color = "white",
          position = position_stack(vjust = 0.5), family = "IBM Plex Mono", size = 5) +
  theme(axis.text.x = element_blank(), axis.line = element_blank())


# Ages at time of death of Black and Latino people who were killed
ages <- killings_data %>% 
  ggplot(aes(age)) +
  labs(x = "Age", y = "", title = "How old were they?", caption = "Data: Los Angeles Times, US Census Bureau | Plot: @_isabellamb") +
  geom_histogram(data = subset(killings_data, race == "Latino"), fill = "#00A1D5", alpha = 0.6) + 
  geom_histogram(data = subset(killings_data, race == "Black"), fill = "#DF8F44", alpha = 0.6) +
  scale_x_continuous(limits = c(10,90), breaks = seq(0,90,10), expand = expansion(0,0)) +
  scale_y_continuous(expand = expansion(0,0)) +
  theme(axis.ticks.x = element_line(color = "gray20"),
        axis.ticks.y = element_line(color = "gray20"))

# Titles
t1 <- ggplot() +
  labs(title = "<span style = 'color:#DF8F44;'>Black</span> and <span style = 'color:#00A1D5;'>Latino</span> communities are disproportionately  <br>affected by police violence in Los Angeles County") +
  theme(axis.line = element_blank(), plot.margin = margin(10,0,0,0), plot.title = element_markdown(size = 29, lineheight = 1.5, color = "black"))

t2 <- ggplot() +
  labs(title = "Where were the most <span style = 'color:#DF8F44;'>Black</span> and <span style = 'color:#00A1D5;'>Latino</span> people killed by police?") +
  theme(axis.line = element_blank(), plot.margin = margin(10,0,0,0))

# Creating the rows
row1 <- plot_grid(t1,perc_plot, ncol = 1, rel_heights = c(0.2,0.8))

neighborhoods <- plot_grid(neighborhoods_black, neighborhoods_latino)
row2 <- plot_grid(t2,neighborhoods, ncol = 1, rel_heights = c(0.1,0.9))

# Final plot - putting it all together
plot_grid(row1, row2, ages, ncol = 1, rel_heights = c(0.4,0.3,0.3)) +
  theme(plot.margin = margin(30,20,10,30), plot.background = element_rect(fill = "#F7F7F7", color = "#F7F7F7"))
ggsave("police_killings.png", device = "png", type = "cairo", width = 15, height = 20, dpi = 300)
