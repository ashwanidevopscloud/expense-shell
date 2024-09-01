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

CHECK_ROOT
dnf install nginx -y    &>>$LOG_FILE
VALIDATE $? "INSTALL nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "enable enginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "STAT nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "REMOVING FILES"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "DOWnloading the code by crl -o"

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "redriecting path"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "extacting the code"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "RESTAT THE SEVER"
