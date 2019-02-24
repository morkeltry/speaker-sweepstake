Grrr!
Slack is such an awful interface!!!

thecloud.com is such an awful connection!!!

This file has to be pushed to github because slack running over a thecloud.com cannot maintain its connection long enough to upload a couple of hundred bytes of message :(

  ####push / pull to github instructions:

  So to pull from and push to github:
  browse to https://github.com/morkeltry/speaker-sweepstake ,click the green clone button and copy the address that pops up.
  Then, in terminal, do `git clone`  and the address.
  `cd` into the speaker-sweepstake directory.
  https://github.com/morkeltry/speaker-sweepstake/invitations
  From that directory, you can always do `git pull origin master` to get the latest version (or replace master with your own branch)
  To work on it, make a new branch: `git checkout -b mynewbranch`
  Since you've already changed the files, copy in the changed files to the same location but in this directory
  Do `git add .` and `git commit -m "Added pics in buttons"` or whatever commit message is appropriate
  You need to accept the invitation https://github.com/morkeltry/speaker-sweepstake/invitations before you can push up.
  Since you're on a new branch, push up to this branch: `git push origin mynewbranch` .
  Then, in the github repo in the browser, go to pull requests and make a new pull request, master <- mynewbranch.
  
