#!/bin/bash

export PGPASSWORD=zackdb
PSQL="psql -X --username=postgres --dbname=number_guess -t --no-align -c"

while [[ true ]]
do
    THE_NUMBER=$(( $RANDOM % 1000 + 1 ))
    echo -e "\nEnter your username:"
    read USERNAME
    CHECK_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME';")
    if [[ -z $CHECK_USER ]]
    then
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
    else
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
        GAMES_PLAYED=$($PSQL "SELECT COUNT(game_number) FROM games WHERE user_id = $USER_ID")
        BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID;")
        echo -e "\nWelcome back, $CHECK_USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi
    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    TRIES=0
    while [[ ! $GUESS =~ ^[0-9]+$ ]]
    do
        echo "That is not an integer, guess again:"
        read GUESS
    done
    while [[ $GUESS > $THE_NUMBER || $GUESS < $THE_NUMBER ]]
    do
        if [[ $GUESS > $THE_NUMBER ]]
        then
            echo "It's lower than that, guess again:"
            read GUESS
            TRIES=$((TRIES+1))
        elif [[ $GUESS < $THE_NUMBER ]]
        then
            echo "It's higher than that, guess again:"
            read GUESS
            TRIES=$((TRIES+1))
        fi
    done
    if [[ $GUESS = $THE_NUMBER ]]
    then
        TRIES=$((TRIES+1))
        INSERT_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $TRIES)")
        echo -e "\nYou guessed it in $TRIES tries. The secret number was $THE_NUMBER. Nice job!\n"
        break;
    fi
done
