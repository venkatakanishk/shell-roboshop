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
dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable NodeJS"
dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling NodeJS : 20"
dnf install nodejs -y         &>> $LOG_FILE
VALIDATE $? "Installing NodeJS version : 20"
id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Creating system user"
else 
    echo -e "User Roboshop already exists .....$Y SKIPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading catalogue code"
cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "removing existing code"

unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping Catalogue code"

npm install
VALIDATE $? "Installing and Resolving dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Catalogue service file is created"

systemctl daemon-reload
VALIDATE $? "Service file is updated"
systemctl enable catalogue 
systemctl start catalogue
VALIDATE $? "Enabling and staring catalogue"