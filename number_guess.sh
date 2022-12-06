#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=guessing_game -t --no-align -c"

echo -e "\n~~ Number Guessing Game ~~\n"
echo -e "\nEnter your username:"
read USERNAME

PLAY_GAME(){

if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
then
PLAY_GAME "That is not an integer, guess again:"
else
RAND=$(( $RANDOM % 1000 + 1 ))
echo $RAND

NUMBER_OF_GUESSES=1
while [ $USER_GUESS != $RAND ]
do
if [[ $USER_GUESS < $RAND ]]
then
echo "It's higher than that, guess again:"
  read USER_GUESS
((NUMBER_OF_GUESSES++))
else
echo "It's lower than that, guess again:"
read USER_GUESS
((NUMBER_OF_GUESSES++))
fi
done

# if user guesses the correct number
if [[ $USER_GUESS = $RAND ]]
then
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RAND. Nice job!"
# fetch user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# insert game info
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID)")
fi
fi
}


CHECK_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $CHECK_USER ]]
then
echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
#prompt user to guess a secret number
PLAY_GAME
else 
# if user exits
EXISTING_USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*)user_id FROM games WHERE user_id ='$EXISTING_USER_ID'")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id='$EXISTING_USER_ID'")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
PLAY_GAME
fi
