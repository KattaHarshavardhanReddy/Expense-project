#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-log"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){

    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "installl nginx"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "enable nginx"

systemctl start nginx &>>$LOG_FILE_NAME
VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "remove existing code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "adding code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "move html folder"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unziping fe"

cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Copied expense config"


systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "restart fe"