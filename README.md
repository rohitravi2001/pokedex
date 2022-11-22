# pokedex

In this project, I created a pokedex app that was able to retrieve images from the PokéAPI, which has a list of Pokemon names and images. Using a View Controller that had an UI Image View and a UI Collection View emebedded within it, I was able to make API calls to fetch the pokemon images and display them on the screen. Once the user clicks on a pokemon, it will be displayed on the UI Image View on the top center, whcih was milestone 1.

I also implemented the next 2 milestones: pagintion and caching. I used the scroll view components of the UI Collection View to only download more images (20 at a time) once the user hits the bottom of the screen as it is unnecessary to pre-download the entire pokedex. 

Furthermore, I added caching using a NSCache, which was an in memory cache. This is not too useful as I download images into a dataSource array. However, if given more time, I would create a URLCache which persists across relauches of the app so that the number of network calls are limited.

For fast UI creation given the limited amount of time, I used storyboard to create the application so that UI elements could be populated and constrained quickly!
