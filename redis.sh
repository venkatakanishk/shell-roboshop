#!/bin/bash
USERID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "disabling the redis"
dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "Enabling redis : 7"
dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"
