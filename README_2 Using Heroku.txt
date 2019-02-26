Make sure you have installed:
Git
Composer
PHP
Heroku

The following commands then need to be run to set up Git to work with Heroku:

$ Heroku login

// the above will open browser, to authenticate login credentials (you'll need access beforehand)

// next, make sure you're on the master branch (I tried an alternative but it didn't like it ... but then it's a little new to me, so was probably something I was doing wrong). Then 

$ Heroku create speaker-sweepstake

// Heroku then updates git (for that folder) to add references and tracking to your heroku account/app/repo

// you don't need the speaker-sweepstake bit, but if you don't use a name heroku will generate a random one - which will be the name of your app.

// When ready to run the app, use:

$ git push heroku master

// which takes your (committed master branch) changes and adds them to heroku.

// The Procfile dictates where the "start" file is

// to start the app use:

$ heroku ps:scale web=1

// the following page was very useful:
// https://devcenter.heroku.com/articles/getting-started-with-php

// to see app:

$ heroku open