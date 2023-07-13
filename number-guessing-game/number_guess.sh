#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

EXISTING_USER=$($PSQL "select count(*) from users where username like '%$USERNAME%';")

if [[ $EXISTING_USER -eq 1 ]]; then
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< $($PSQL "select games_played, best_game from users where username like '%$USERNAME%';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  INSERT_RESULT=$($PSQL "insert into users (username) values ('$USERNAME');")
  if [[ $INSERT_RESULT == "INSERT 0 1" ]]; then echo "Welcome, $USERNAME! It looks like this is your first time here."; fi
fi

echo "Guess the secret number between 1 and 1000:"

TRIES=0
while :; do
    read GUESS

    if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        continue
    fi

    ((TRIES++))
    if [[ $GUESS -eq $RANDOM_NUMBER ]]; then
        UPDATE_RESULT=$($PSQL "update users set games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR $TRIES < best_game THEN $TRIES ELSE best_game END where username like '%$USERNAME%';")
        if [[ $UPDATE_RESULT == "UPDATE 1" ]]; then echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"; fi
        break
    elif [[ $GUESS -gt $RANDOM_NUMBER ]]; then
        echo "It's lower than that, guess again:"
    else
        echo "It's higher than that, guess again:"
    fi
    
done