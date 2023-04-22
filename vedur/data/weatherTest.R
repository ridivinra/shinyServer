library(ggplot2)
library(maps)

world_map <- map_data("world")
iceland_map <- subset(world_map, region == "Iceland")
load("weather.RData")
weatherObs <- weatherDt %>% 
  filter(type == 'observation') %>% 
  mutate(label = paste0(name,"\n",temperature,"°C\n",wind_speed,"m/s"))
labels <- data.frame(
  name = c("Reykjavik", "Akureyri"),
  lat = c(64.1466, 65.6885),
  long = c(-21.9426, -18.1262)
)

ggplot() +
  geom_polygon(data = iceland_map, aes(x = long, y = lat, group = group), fill = "gray90", color = "black") +
  geom_label(data = weatherObs, aes(x = long, y = lat, label = label), 
             size = 3, hjust = "center", nudge_x = 0.2, alpha = 0.7) +
  labs(title = weatherObs %>% filter(id == 1) %>% pull(ftime)) + 
  coord_cartesian(xlim = c(-24, -13), ylim = c(63, 67)) +
  theme_minimal()
