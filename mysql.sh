LOG_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOG_FOLDER

uSERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $uSERID -ne 0 ]
    then
        echo -e "$R Please rn this script with root privelliges $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G i have root access procide with that .... $N" | tee -a $LOG_FILE
    fi
}
VALIDATE(){
    if [ $1 -ne 0 ]
    then
       echo -e "$2 is .... $R FAILED $N" | tee -a $LOG_FILE
       exit 1
    else
       echo -e "$2 is .....$G SuCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "script started execting at :: $(date)"

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing MYSQL server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabled MYSQL SERVER"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "started MYSQL SEVER"




if [ $? -ne 0 ]
then
   echo -e "$R mysql root password is not setp, setting now $N"
   mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
   VALIDATE $? "setting root password"
else
    echo -e  "$G mysql root password is already setp, skipping now $N"
fi
