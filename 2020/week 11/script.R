#Libraries
library(tidyverse)
library(ggalluvial)
# Reading Data
tuition_cost <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_cost.csv')

tuition_income <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/tuition_income.csv') 

salary_potential <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/salary_potential.csv')

historical_tuition <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/historical_tuition.csv')

diversity_school <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-03-10/diversity_school.csv')


# Data wrangling
cost_potential_pay <- right_join(tuition_cost, salary_potential, by = c('name','state' = 'state_name')) %>% 
  filter(!is.na(type))

# Summaries of potential pay
summary(cost_potential_pay[,c('early_career_pay', 'mid_career_pay', 'out_of_state_total', 'in_state_total')])

# Creating categories of potential pay vars
cost_potential_pay_1 <- cost_potential_pay %>% 
  mutate(early_career_cat = factor(case_when(early_career_pay < 50000 ~ 'Below \n$50,000',
                                             early_career_pay >= 50000 ~ 'Above \n$50,000')),
         mid_career_cat = factor(case_when(mid_career_pay < 90000 ~ 'Below \n$90,000',
                                           mid_career_pay >= 90000 ~ 'Above \n$90,000')),
         out_state_total_cat = factor(case_when(out_of_state_total > 50000 ~ 1,
                                                between(out_of_state_total, 30000,50000)~2,
                                                out_of_state_total < 30000 ~ 3),
                                      label = c('Above \n$50,000','Between \n$30,000 \n& $50,000',
                                                'Below \n$30,000')),
         in_state_total_cat = factor(case_when(in_state_total > 50000 ~ 1,
                                               between(in_state_total, 30000,50000)~2,
                                               in_state_total < 30000 ~ 3),
                                     label = c('Above \n$50,000','Between \n$30,000 \n& $50,000',
                                               'Below \n$30,000')),
         state = factor(state),
         type = factor(type)) %>% 
  select(state, type, degree_length, early_career_cat, mid_career_cat, in_state_total_cat,
         out_state_total_cat)


cols <- c('#fe3434','#1fbb0a')

# Plot <<<Tuition fee - potential pay>>>
# Plot 1 for in state <<in_state_total_cat>> and plot2 for <<out_state_total_cat>> as the final grouping var and axis1
plot <- cost_potential_pay_1 %>% 
  group_by(state, type, degree_length, early_career_cat, mid_career_cat, out_state_total_cat) %>% 
  summarise(freq = n()) %>% 
  arrange(type, freq) %>% 
  ggplot(aes(axis1 = out_state_total_cat, axis2 = early_career_cat, axis3 = mid_career_cat, y = freq)) +
    geom_alluvium(aes(fill = type), width = 1/2) +
    scale_fill_manual(values = cols) +
    scale_y_continuous(breaks = seq(0,600, 100), expand = expansion(add = c(0.5,0.5))) +
    geom_stratum(width = 1/4, alpha = 0.8, fill = '#040301', col = '#5f5f5d', lwd = 1.4) +
    geom_text(stat = 'stratum', infer.label = TRUE, size = 4, 
              fontface = 'bold', col = '#d2cfc2') +
    scale_x_discrete(limits = c('Tuition Fee ($) for\n [OUT-OF-STATE]\nResidents',
                                'Potential \nEarly-Career \nSalary ($)',
                                'Potential \nMid-Career \nSalary ($)'),
                     expand = c(0.01, 0.01)) +
    labs(y = "Number of Institutions", 
         title = "EARLY & MID-CAREER SALARY($) POTENTIAL BASED ON TUITION FEES", 
         subtitle = "[OUT-OF-STATE] Residents", 
         caption = "Github: @johnmutiso\ndata: TuitionTracker.org\n2020-week 11 TidyTuesday") + 
    theme_minimal() +
    theme(plot.background = element_rect(fill = '#0f0809'), 
          panel.grid = element_blank(), 
          axis.text = element_text(color = '#d2cfc2', size = 12, face = 'bold'), 
          legend.text = element_text(size = 12, color = '#d2cfc2'),
          legend.position = 'top', 
          legend.title = element_blank(),
          axis.title.y = element_text(color = '#d2cfc2', size = 12),
          axis.title = element_blank(),
          plot.caption = element_text(colour = 'grey50', face = 'italic', size = 8),
          plot.title  = element_text(colour = 'grey90', face = 'bold', size = 13),
          plot.subtitle = element_text(colour = 'grey80', face = 'bold.italic', size = 10))

ggsave(filename = 'week 11 plot2.jpeg', plot = plot, device = 'jpeg', path = '2020/week 11/',dpi = 400,
       width = 9, height = 7.2)


