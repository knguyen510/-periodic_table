#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z "$1" ]]
then
  echo "Please provide an element as an argument."
  exit
elif [[ "$1" =~ ^[0-9]+$ ]]
then
  # Argument is a number (atomic number)
  QUERY="WHERE e.atomic_number = $1"
else
  # Argument is text (quote it for SQL)
  QUERY="WHERE e.symbol = '$1' OR e.name = '$1'"
fi


ELEMENT_DATA=$($PSQL "
  SELECT 
    e.atomic_number,
    e.name,
    e.symbol,
    p.atomic_mass,
    p.melting_point_celsius,
    p.boiling_point_celsius,
    t.type
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t USING(type_id)
  $QUERY
")

if [[ -n $ELEMENT_DATA ]]
then
echo "$ELEMENT_DATA" | { 
  IFS='|' read ATOMIC_NUMBER NAME SYMBOL MASS MELTING BOILING TYPE
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  }
else echo "I could not find that element in the database."
fi
