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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoRepo"

dnf install mongodb-org -y &>> $LOG_FILE
VALIDATE $? "Installing Mongo Server"
systemctl enable mongod &>> $LOG_FILE
systemctl start mongod 
VALIDATE $? "Enabling and starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "Allowing remote connections"
systemctl restart mongod 
VALIDATE $? "Restarted MongoDB"
