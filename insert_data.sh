#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games;")
$PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1;"
$PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1;"
echo "Sequences reset to 1."

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

do
  #skip header line
  if [[ $YEAR = "year" ]]
  then
    continue
  fi
  #get team_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  #if not found
  if [[ -z $WINNER_ID ]]
  then
    #insert team
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams winner, $WINNER
    fi
    #get new team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  fi
  
  #get team_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  #if not found
  if [[ -z $OPPONENT_ID ]]
  then
    #insert team
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into teams opponent, $OPPONENT
    fi
    #get new team_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  fi

  #debugger value check
  echo "Processing: Year=$YEAR, Round=$ROUND, Winner=$WINNER, Opponent=$OPPONENT, Winner Goals=$WINNER_GOALS, Opponent Goals=$OPPONENT_GOALS"

  if [[ -n $WINNER_ID && -n $OPPONENT_ID ]]
  then
    #get game_id
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID'")
    #if not found
    if [[ -z $GAME_ID ]]
    then
      #insert game
      INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $INSERT_GAME_RESULTS == "INSERT 0 1" ]]
      then
        echo Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
      fi
      #get new game_id
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year='$YEAR' AND round='$ROUND' AND winner_id='$WINNER_ID' AND opponent_id='$OPPONENT_ID'")
    fi
  fi
done
