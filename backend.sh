#!/bin/bash

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log
mkdir -p expense
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

uSERID=$(id -u)
CHECK_ROOT(){
    if [ $? -ne 0 ]
    then
       echo -e "$R I don't have root access, Please provide the root access with super pivellieges $N"
       exit 1
    else
       echo -e "$G I have root access.... I will procide with that....$N"
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2 is Failed....check it $N"
        exit 1
    else
        echo -e "$G $2 is success .... completed $N"
    fi
}

echo -e "$Y Script started at execting at::: $(date) $N"
CHECK_ROOT

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "disable NODEJS"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "ENABLE NODEJS"

dnf install nodejs -y  &>>LOG_FILE
VALIDATE $? "INSTALL NODEJS"

useradd expense  &>>LOG_FILE
if [ $? -ne 0 ]
then 
   echo -e "expenseuser user is not exist...$G ceating it..$N " &>>LOG_FILE
   useradd expense  &>>LOG_FILE
   VALIDATE $? "ADDING useradd EXPENSE"
else
   echo -e "expense user already exists.... $Y Skipping it....$N " &>>LOG_FILE
fi

mkdir -P /app &>>LOG_FILE
VALIDATE $? "MAKEING DIRECTORY"
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE
VALIDATE $? "DOWNLOADING THE BACKEND CODE....."

cd /app &>>LOG_FILE
unzip /tmp/backend.zip &>>LOG_FILE
VALIDATE $? "ZIPPING TE BACKEND.ZIP FILE EXTACTING"

npm install &>>LOG_FILE
VALIDATE $? "NPM INSTALL PACKAGES"


