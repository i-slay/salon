#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ WELCOME TO THE SALON ~~~~\n"

WELCOME() {

  echo -e "How may I help you today?\n"
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID != 'service_id' && $SERVICE_NAME != 'service_name' ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || $SERVICE_ID_SELECTED != [1-6] ]]
  then
    WELCOME "Please choose a service from the list."
  fi
}

COLLECT_CUSTOMER_DATA() {
  echo -e "\nPlease write your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "I do not see your data in our clients base.\nCan you tell me your name, please?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
}

MAKE_APPOINTMENT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  echo "What time would you like your $(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?" 
  read SERVICE_TIME

  if [[ -z $SERVICE_TIME ]]
  then
    WELCOME "Please provide a valid service time."
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo "I have put you down for a $(echo "$SERVICE_NAME" | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo "$CUSTOMER_NAME" | sed -r 's/^ *| *$//g')."
  fi
}

MAIN() {
  WELCOME
  COLLECT_CUSTOMER_DATA
  MAKE_APPOINTMENT
}

MAIN