#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN() {
  if [[ $1 ]]; then echo -e "\n$1"; 
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  $PSQL "select service_id, name from services" | while read -r MENU_ID MENU_NAME; do
    if [[ $MENU_ID ]]; then
      echo "$MENU_ID)$(echo $MENU_NAME | sed 's/| / /')"
    fi
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then MAIN "I could not find that service. What would you like today?"
  else
    SERVICE=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")
    SERVICE=$(echo "$SERVICE" | sed 's/^ *//; s/ *$//')
    if [[ -z $SERVICE ]]; then MAIN "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]; then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        INSERT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
      fi
      CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed 's/^ *//; s/ *$//')
      
      echo -e "\nWhat time would you like your $SERVICE, $NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

      INSERT=$($PSQL "insert into appointments(customer_id, service_id, time) values('$CUSTOMER_ID','$SERVICE_ID_SELECTED','$SERVICE_TIME')")

      echo "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi
}

MAIN