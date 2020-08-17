# Taylor Swift: Data Visualization and ML 
Uses R to visualize how Taylor Swift's music has changed over the years!

  # Cleaning Data
  - Using spotifyR package, gets data on all Taylor Swift songs from Spotify API 
  - Using dplyr, removes weird albums (ie Karaoke, Special Edtions, Remixes), and 
  removes any duplicate songs, remove columns with unnecessary info 
  - Adds a column for positivity, which is a combination of valence and energy 
  
  # Visualization 
  - Using ggplot2, creates graphs visualizing the changes in Taylor Swift music over time
  (in positivity, danceability, duration, etc)
  
  ## Graphs! 
  
  How key album features (number of songs,the duration of songs, and the distribution of each key) vary per album
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/songsPerAlbum.jpeg)
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/durationByAlbum.jpeg)
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/keyDistribution.jpeg) 
  
  How positivity varies by each album, how positivity changes over the course of the album, and how positivity 
  varies for each album. Albums with higher median positivity tend to have a higher variance (ie sadder albums stay sad, 
  but happy albums still have sadder songs) 
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/posByAlbum.jpeg )
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/posByTrack.jpeg)
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/posDistribution.jpeg)
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/posVariance.jpeg)
  
  How danceability varies by each album, and how it changes over the course of albums
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/danceabilityByAlbum.jpeg)
  ![Alt text](https://github.com/adrismiller/tsR/blob/master/graphs/danceabilityByTrack.jpeg)

  
  # ML 
  - Divides data into training set and test set by album name
  - Using caret, creates 4 models (knn, qda, naive_bayes, and svmLinear), using 
  danceability, key, positivity, and acousticness to predict which album it came from
  - Using an ensemble model, we got an accuracy of around 37% when testing on the training set 
  (which is not great, but much better than randomly guessing one of 8 albums) 
  - Probably not going to get much more accurate, becuase all of her music shares a qualities 
  - One problem with the model is that a lot of it's accuracy comes from over guessing a couple albums 
   (Fearless is guessed 40% percent of the time, Speak Now is only guessed 2% of the time) 
