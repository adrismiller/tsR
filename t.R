devtools::install_github('charlie86/spotifyr')

library(spotifyr)
library(tidyverse)
library(lubridate)
library(caret)

Sys.setenv(SPOTIFY_CLIENT_ID = '556b053ae2fb45ccba1936e608c9739e')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'c54d125fed3741cbb7a3fc26d19e230e')  
# every taylor swift song on spotify 
all_taylor <- get_artist_audio_features(artist="Taylor Swift")

# main 8 albums (no live albums, special edtions ) 
albums = c("Taylor Swift", "Speak Now", "Fearless", "Red", "1989", "reputation", "Lover", "folklore")

main_8 <- all_taylor %>% filter(album_name %in% albums)  

# remove weird kareoke/instrumental/commentary songs 
strings <- c("Commentary", "Live", "Karaoke", "Version","Edit", "Mix", "Remix")
songs <- main_8 %>% filter(!str_detect(track_name, paste(strings, collapse = "|")))

# remove duplicates 
songs <- songs %>% distinct(track_name, .keep_all = TRUE) 

# get rid of columns that aren't useful 
songs <- songs %>% select(-artist_name, -artist_id, -album_type, -album_id, 
                          -album_images,-album_release_date, -album_release_date_precision,
                          -track_id, -track_href, -track_preview_url, -track_uri, 
                          -available_markets, -analysis_url, -time_signature, 
                          -is_local, -external_urls.spotify, -type, -disc_number,
                          -artists)

# positvity is a combination of valence and energy
songs <- songs %>% mutate(positivity=sqrt((valence^2) + (energy^2)))


# some fun plots :)
axistheme <- theme(plot.title = element_text(family = "Helvetica", face = "bold", size = (17), colour="#6b6b6b"),
                      axis.title = element_text(family = "Helvetica", size = (13), colour = "#8b8b8b"),
                      axis.text = element_text(family = "Courier", colour = "darkgrey", size = (10)))
myPalette <- c("#FF9AA2",  "#FFDCF4", "#FFDAC1", "#FFF49C", "#E2F0CB", "#B5EAD7", "#C7CEEA", "#85a8ba", "#ffffff", "#bfbfbf", "#696969", "#141414" )

lightpink <- "#FFDCF4"

# songsPerAlbum.jpeg
songs %>% 
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_name)) + 
  geom_bar(fill=lightpink) + 
  axistheme+ 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title="Number of Songs per Album", x= "Album", y="Number of Songs") 


# danceabilityByTrack.jpeg
songs %>%
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(track_number, danceability, color=album_name)) + 
  geom_smooth(method = loess, alpha=0.00, formula = 'y~x') + 
  axistheme + 
  labs(title="Danceability by Track Number", x= "Track Num", y="Danceability") + 
  theme(panel.background = element_rect(fill = '#f7f7f7')) + 
  scale_color_manual(values=myPalette)
  
#danceabilityByAlbum.jpeg changed
songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(y=danceability, x=album_release_year, fill=album_name)) + 
  geom_boxplot() + 
  axistheme +
  labs(title="Danceability by Album", x= "Release Date", y="Danceability", fill="Album") + 
  scale_fill_manual(values=myPalette) 


# plots about positivity values

#posDistribution.jpeg
songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(positivity)) + 
  geom_density(fill=lightpink) +  
  facet_wrap(album_name ~ .) +
  axistheme + 
  labs(title="Positivity Distribution by Album",x="Distribution", y="Positivity", fill="Album") + 
  scale_fill_manual(values=myPalette) 

# posOverTime.jpeg
songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_release_year, positivity, fill=album_name)) + 
  geom_boxplot() +
  geom_point(show.legend = FALSE, alpha=0.3) + 
  axistheme + 
  labs(title="Positivity by Album",x="Release Year", y="Positivity", fill="Album") + 
  scale_fill_manual(values=myPalette) 

# posByTrack.jpeg
songs %>%
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(track_number, positivity, color=album_name)) + 
  geom_smooth(method = loess, alpha=0.00, formula = 'y~x') + 
  axistheme + 
  labs(title="Positivity by Track Number", x= "Track Num", y="Positivity") + 
  theme(panel.background = element_rect(fill = '#f7f7f7')) + 
  scale_color_manual(values=myPalette)


# albums that have higher positive medeians, have higher variance in positivity
# posVariance.jpeg
songs %>% group_by(album_name) %>% 
  mutate(p_v = var(positivity), m = median(positivity) )   %>% 
  ggplot(aes(x= m,  y=p_v, label=album_name)) + 
  geom_smooth(color="darkgrey", method='loess', formula='y~x')+
  geom_label(fill=lightpink) + 
  axistheme + 
  scale_fill_manual(values=myPalette) +  
  labs(title="Positivity Variance vs Median Positivity",x="Median Positivity", y="Variance in Positivity")

# Duration of albums over time

#durationByAlbum changedß
songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(album_release_year, duration_ms / 1000, fill=album_name)) + 
  geom_boxplot() +
  geom_point(show.legend = FALSE, alpha=0.3) + 
  axistheme +
  labs(title="Duration by Album",x="Release Year", y="Duration", fill="Album") + 
  scale_fill_manual(values=myPalette) 


# key distribution for each album
# keyDistribution.jpeg
songs %>%  
  mutate(album_name = reorder(album_name, album_release_date, FUN= first)) %>%
  ggplot(aes(key_name)) + 
  geom_bar(fill=lightpink, col="darkgrey") + 
  facet_wrap(album_name ~ .) +
  axistheme + 
  labs(title="Key Distribution by Album",x="Key", y="Number of Songs", fill="Album") + 
  scale_fill_manual(values=myPalette) 



# model to determine album based on qualities of music
set.seed(1, sample.kind="Rounding")
test_index <- createDataPartition(songs$album_name, times = 1, p = 0.2, list = FALSE)
train_set <- songs %>% slice(-test_index)
test_set <- songs %>% slice(test_index)

#  different fits 
models <-c( "knn", "naive_bayes", "svmLinear")

# train 4 different models 
fits <- lapply(models, function(model){ 
  if (model == "knn"){
    grid= data.frame(k=seq(1,50,1))
    train(album_name ~ positivity + danceability + key + acousticness, method = model, data = train_set, tuneGrid=grid)
  }else{ 
    train(album_name ~ positivity + danceability + key + acousticness, method = model, data = train_set)
  }
  
}) 

names(fits) <- models

# accuracy of each indiviudal model on train set
acc <- sapply(fits, function(fit){
  mean(fit$results$Accuracy) 
})

# shows naive bayes and svmLinear are best
acc

# make predictions for each models 
preds <- sapply(fits, function(fit){
    predict(fit, test_set)
  
})

# accuracy of ensemble model without knn (worst perfrorming)
pred <- apply(preds[,2:3], 1, function(pred) names(which.max(table(pred))))
mean(pred == test_set$album_name)

# accuracy of each individual model on test set
acc2 <- apply(preds, 2, function(pred){mean(pred == test_set$album_name)})
acc2

