devtools::install_github('charlie86/spotifyr')
Sys.setenv(SPOTIFY_CLIENT_ID = '556b053ae2fb45ccba1936e608c9739e')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'c54d125fed3741cbb7a3fc26d19e230e')
library(spotifyr)
library(tidyverse)
library(lubridate)
library(caret)
# every taylor swift song on spotify 
all_taylor <- get_artist_audio_features(artist="Taylor Swift")

# main 8 albums (no live albums, special edtions ) 
albums = c("Taylor Swift", "Speak Now", "Fearless", "Red", "1989", "reputation", "Lover", "folklore")
main_8 <- all_taylor %>% filter(album_name %in% albums)  

# remove weird kareoke/instrumental/commentary songs 
strings <- c("Commentary", "Live", "Karaoke", "Version","Edit", "Mix", "Remix")
songs <- main_8 %>% filter(!str_detect(track_name, paste(strings, collapse = "|")))

# remove duplicates 
songs <- songs %>% distinct(track_name, .keep_all = TRUE) mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%

# some fun plots :)
axistheme <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (17), colour="#6b6b6b"),
                      axis.title = element_text(family = "Helvetica", size = (13), colour = "#8b8b8b"),
                      axis.text = element_text(family = "Courier", colour = "darkgrey", size = (10)))
myPalette <- c("#FF9AA2",  "#FFDCF4", "#FFDAC1", "#FFF49C", "#E2F0CB", "#B5EAD7", "#C7CEEA", "#85a8ba", "#ffffff", "#bfbfbf", "#696969", "#141414" )

lightpink <- "#FFDCF4"
songs %>% 
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_name)) + 
  geom_bar(fill=lightpink) + 
  axistheme+ 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Number of Songs per Album", x= "Album", y="Number of Songs") 

songs %>%
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(track_number, danceability, color=album_name)) + 
  geom_smooth(method = loess, alpha=0.00, formula = 'y~x') + 
  axistheme + 
  labs(title="Danceability by Track Number", x= "Track Num", y="Danceability") + 
  theme(panel.background = element_rect(fill = '#f7f7f7')) + 
  scale_color_manual(values=myPalette)
  


songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(y=danceability, x=album_release_year, fill=album_name)) + 
  geom_boxplot() + 
  axistheme +
  labs(title="Danceability by Album", x= "Time", y="Danceability", fill="Album") + 
  scale_fill_manual(values=myPalette) 
 # expand_limits(y = 0)


songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(y=danceability, x=duration_ms / 1000, fill=album_name)) + 
  geom_point(colour="black",pch=21, size=3) + 
  axistheme +
  labs(title="Danceability versus Duration", x= "Duration(seconds)", y="Danceability", fill="Album") + 
  scale_fill_manual(values=myPalette) 
# expand_limits(y = 0)

songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(y=duration_ms / 1000, x=album_release_year, fill=album_name)) + 
  geom_boxplot() + 
  axistheme +
  scale_fill_manual(values=myPalette)  + 
  labs(title="Release Year versus Duration", x= "Year", y="Duration(seconds)", fill="Album") 

# positvity is a combination of valence and energy
pos <- songs %>% mutate(positivity=sqrt((valence^2) + (energy^2))) 
pos %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(positivity)) + 
  geom_density(fill=lightpink) +  
  facet_wrap(album_name ~ .) +
  axistheme + 
  labs(title="Positivity Distribution by Album",x="Distribution", y="Energy", fill="Album") + 
  scale_fill_manual(values=myPalette) 

pos %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_release_year, positivity, fill=album_name)) + 
  geom_boxplot() +
  geom_point(show.legend = FALSE, alpha=0.3) + 
  axistheme + #stat_summary(fun=mean, geom="line", aes(group=1))  + 
  labs(title="Positivity by Album",x="Release Year", y="Energy", fill="Album") + 
  scale_fill_manual(values=myPalette) 

pos %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_release_year, positivity, fill=album_name)) + 
  geom_boxplot() +
  geom_point(show.legend = FALSE, alpha=0.3) + 
  axistheme + #stat_summary(fun=mean, geom="line", aes(group=1))  + 
  labs(title="Positivity by Album",x="Release Year", y="Energy", fill="Album") + 
  scale_fill_manual(values=myPalette) 

pos %>% group_by(album_name) %>% 
  mutate(p_v = var(positivity), m = mean(positivity) )   %>% 
  ggplot(aes(x= m,  y=p_v, label=album_name)) + 
  geom_smooth(color="darkgrey", method='loess', formula='y~x')+
  geom_label(fill=lightpink) + 
  axistheme + 
  scale_fill_manual(values=myPalette) + 
  labs(title="Positivity Variance by Album",x="Mean Positivity", y="Variance in Positivity")


pos %>% group_by(album_name) %>% 
  ggplot(aes(x= positivity,  y=danceability, fill=album_name)) + 
  geom_point(colour="black",pch=21, size=3) + 
  scale_fill_manual(values=myPalette) + 
  axistheme + 
  labs(title="Positivity x Danceability",x="Positivity", y="Danceability")

pos %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_release_year, duration_ms / 1000, fill=album_name)) + 
  geom_boxplot() +
  geom_point(show.legend = FALSE, alpha=0.3) + 
  axistheme + #stat_summary(fun=mean, geom="line", aes(group=1))  + 
  labs(title="Duration by Album",x="Distribution", y="Energy", fill="Album") + 
  scale_fill_manual(values=myPalette) 

pos %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(key_name)) + 
  geom_bar(fill=lightpink, col="darkgrey") + 
  facet_wrap(album_name ~ .) +
  axistheme + 
  labs(title="Key Distribution by Album",x="Key", y="Number of Songs", fill="Album") + 
  scale_fill_manual(values=myPalette) 

# model to determine 
set.seed(1, sample.kind="Rounding")
test_index <- createDataPartition(songs$album_name, times = 1, p = 0.2, list = FALSE)
train_set <- pos %>% slice(-test_index)
test_set <- pos %>% slice(test_index)


#grid = data.frame(k=seq(3,100, 2))
cor(pos$positivity, pos$key_mode)
fit <- train(album_name ~ positivity + duration_ms + danceability + key, data=train_set, method="lda")

fit$results
pred <-   predict(fit, test_set)
pred
mean(pred == test_set$album_name)

pos$
 