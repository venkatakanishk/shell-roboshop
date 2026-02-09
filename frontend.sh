#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD

if [ $USERID -ne 0 ]; then
    echo -e "$R please run the script with root user access $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE (){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ....$R is failure $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 ....$G is success $N" | tee -a $LOG_FILE
    fi
}
dnf module list nginx &>> $LOG_FILE
VALIDATE $? "List nodejs modues"
dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "Disabiling  Nginx"
dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "Enabling Nginx"
dnf install nginx -y &>> $LOG_FILE
VALIDATE $? " Installing Nginx"
systemctl enable nginx 
systemctl start nginx 
VALIDATE $? "Enabaling and starting Nginx"