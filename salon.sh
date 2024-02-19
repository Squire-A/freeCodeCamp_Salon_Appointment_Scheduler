#! /bin/bash
# Salon Apppointment Scheduler for freeCodeCamp Relational Database certification project
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"

MAIN_MENU() {
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  # Display available services
  echo -e "Here are the services we offer:\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nPlease enter a service number:"
  read SERVICE_ID_SELECTED

  if [[ ! "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "~~ Please only enter a number ~~"
  else
    SERVICE_ID_CHECK=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_CHECK ]]
    then
      MAIN_MENU "~~ Sorry that is not a valid service number. ~~"
    else
      BOOK_SERVICE $SERVICE_ID_SELECTED
    fi
  fi
}

BOOK_SERVICE() {
  SERVICE_ID=$1
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID")
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nWe don't have a record of the number. Please enter your name:"
    read CUSTOMER_NAME
    CUSTOMER_ENTRY=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  APPOINTMENT_ENTRY=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
