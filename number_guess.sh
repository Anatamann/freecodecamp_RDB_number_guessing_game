#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#guess_number_game logic
GUESS_NUMBER(){

    echo "Guess the secret number between 1 and 1000:"
    TARGET=$((RANDOM % 1000 +1))
    echo $TARGET
    STATUS=1
    COUNT=0
    USER_ID=$1

    #game-function to match the guess with the target
      GAME(){
        
        GUESS=$1
        USER_ID=$2
        #echo $USERNAME
        COUNT=$((COUNT + 1))

        if [[ $GUESS -eq $TARGET ]]
        then
          echo "You guessed it in $COUNT tries. The secret number was $TARGET. Nice job!"
          INSERT=$($PSQL "INSERT INTO games(user_id,nos_guess) VALUES($USER_ID, $COUNT)")
          return 0
        elif [[ $GUESS -lt $TARGET ]]
        then
          echo "It's higher than that, guess again:"
          return 1
        else
          echo "It's lower than that, guess again:"
          return 1
        fi
    }

    #User input function
    while [[ $STATUS != 0 ]]
    do
      read GUESS
      if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
        echo "That is not an integer, guess again:"
      else
        #calling the game-function to check user's guess against the TARGET value
        GAME $GUESS $USER_ID
        STATUS=$?
      fi
    done


}

MAIN(){

  echo "Enter your username:"
  read USERNAME
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME'")
    GUESS_NUMBER $USER_ID
  else
    USER_INFO=$($PSQL "SELECT username, COUNT(game_id), MIN(nos_guess) FROM users AS u JOIN games AS g USING(user_id) WHERE u.user_id=$USER_ID GROUP BY username")
    while IFS='|' read -r USER TOT_GAMES BEST_GAME
    do
      echo "Welcome back, $USER! You have played $TOT_GAMES games, and your best game took $BEST_GAME guesses."
    done <<< "$USER_INFO"
    USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME'")
    GUESS_NUMBER $USER_ID
  fi


}
#calling the main function
MAIN
