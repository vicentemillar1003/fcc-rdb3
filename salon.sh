#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
SERVICES_QUERY_RESULT="$($PSQL "SELECT * FROM services")"

MAIN_MENU() {
	if [[ ! -z $1 ]]
	then
		echo "$1"
	fi
	echo "Select service:"
	echo "$SERVICES_QUERY_RESULT" | sed -E 's/\|/) /g'
	read SERVICE_ID_SELECTED

	SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
	if [[ -z $SERVICE_NAME ]]
	then
		MAIN_MENU "Please enter a valid service id"
	else
		SERVICE_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
	fi
}


SERVICE_MENU() {
	echo "You selected $2 (id=$1)"
	echo "Enter your phone number"
	read CUSTOMER_PHONE
	CUSTOMER_ID_RESULT="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
	if [[ -z $CUSTOMER_ID_RESULT ]]
	then
		# new client ask for name
		echo "Welcome! please enter your name"
		read CUSTOMER_NAME
		$PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
		CUSTOMER_ID_RESULT=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
	fi

	CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"

	echo "Please enter the service time"
	read SERVICE_TIME

	$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID_RESULT, $1, '$SERVICE_TIME')" > /dev/null
	echo "I have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
}



MAIN_MENU





