#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

ELEMENT_QUERY="SELECT e.atomic_number || '|' || e.name || '|' || e.symbol || '|' || t.type || '|' ||
  trim(trailing '0' from trim(trailing '.' from p.atomic_mass::text)) || '|' ||
  CASE WHEN p.melting_point_celsius::text LIKE '%.%' THEN trim(trailing '0' from trim(trailing '.' from p.melting_point_celsius::text)) ELSE p.melting_point_celsius::text END || '|' ||
  CASE WHEN p.boiling_point_celsius::text LIKE '%.%' THEN trim(trailing '0' from trim(trailing '.' from p.boiling_point_celsius::text)) ELSE p.boiling_point_celsius::text END
FROM elements e
JOIN properties p USING (atomic_number)
JOIN types t USING (type_id)"

if [[ $1 =~ ^[0-9]+$ ]]; then
  ELEMENT=$($PSQL -c "$ELEMENT_QUERY WHERE e.atomic_number = $1 LIMIT 1;")
else
  SEARCH=${1//\'/\'\'}
  ELEMENT=$($PSQL -c "$ELEMENT_QUERY WHERE e.symbol ILIKE '$SEARCH' OR e.name ILIKE '$SEARCH' LIMIT 1;")
fi

if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
  exit
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT"
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
