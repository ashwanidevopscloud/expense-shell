#!/bin/bash

LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

uSERID=$(id -u)
CHECK_ROOT(){
    if [ $? -ne 0 ]
    then
       echo -e "$R I don't have root access, Please provide the root access with super pivellieges $N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$G I have root access.... I will procide with that....$N" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$R $2 is Failed....check it $N" | tee -a $LOG_FILE
        exit 1 
    else
        echo -e " $2 $G is success .... completed $N" | tee -a $LOG_FILE
    fi
}

echo -e "$Y Script started at execting at::: $(date) $N" | tee -a $LOG_FILE
CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disable NODEJS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLE NODEJS :20"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "INSTALL NODEJS"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then 
   echo -e "expenseuser user is not exist...$G ceating it..$N" | tee -a $LOG_FILE
   useradd expense  &>>$LOG_FILE
   VALIDATE $? "ADDING useradd EXPENSE"
else
   echo -e "expense user already exists.... $Y Skipping it....$N" | tee -a $LOG_FILE
fi

mkdir -p /app  | tee -a $LOG_FILE
VALIDATE $? "Creating /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "DOWNLOADING THE BACKEND CODE....."

cd /app &>>$LOG_FILE
rm -rf /app/* #removing the existing code
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "ZIPPING TE BACKEND.ZIP FILE EXTACTING"

npm install &>>$LOG_FILE
VALIDATE $? "NPM INSTALL PACKAGES"

cp /home/ec2-user/expense-shell/backend.sevice   /etc/systemd/system/backend.service &>>$LOG_FILE

# load data base schema

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Install MYSQL"

mysql -h db.asividevops.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "MYSQL ROOT PASSWORD SETTING schema loading is"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? " systemctl demon-reload"
systemctl start backend &>>$LOG_FILE
VALIDATE $? "START BACKEND"
systemctl enable backend &>>$LOG_FILE
VALIDATE $? "ENABLE BACKEND"
systemctl restart backend &>>$LOG_FILE
VALIDATE $? "RESTART BACKEND"



