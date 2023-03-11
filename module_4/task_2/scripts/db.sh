#!/bin/bash

typeset fileName=users.db
typeset fileDir=../data
typeset filePath=$fileDir/$fileName
typeset backupDir=$fileDir/backup

function validateLatinLetters {
  if [[ $1 =~ ^[A-Za-z_]+$ ]]; then return 0; else return 1; fi
}


add() {
    read -p "Enter username: " name

    if ! validateLatinLetters $name; then
        echo "Invalid name. Try again"
        exit 1
    fi

    read -p "Enter role: " role

    if ! validateLatinLetters $role; then
        echo "Invalid role. Try again"
        exit 1
    fi

    echo "$name, $role" >> $filePath
}

list() {
    cat $filePath | awk '{print NR". " $1 " " $2}'
}

find() {
    read -p "Enter username to find: " username

    hasFoundUsers=$(cat $filePath | grep $username | wc -l)

    if [[ hasFoundUsers -gt 0 ]]; then
        cat $filePath | grep $username
    else
        echo "User not found"
        exit 1
    fi
}

backup() {
    local backupName=$(date +'%Y_%m_%d_%H_%M')

    if [[ ! -d $backupDir ]]; then
        mkdir $backupDir
    fi

    cat $filePath > $backupDir/$backupName

    echo "Backup has been created: $backupName"
}

restore() {
    select backupFile in $(ls $backupDir)
    do  
        cat $backupDir/$backupFile > $filePath
        break
    done

    echo "$backupFile has been applied"
}

function help {
    echo "Manages users in db. It accepts a single parameter with a command name."
    echo
    echo "Syntax: db.sh [command]"
    echo
    echo "List of available commands:"
    echo
    echo "add       Adds a new line to the users.db. Script must prompt user to type a
                    username of new entity. After entering username, user must be prompted to
                    type a role."
    echo "backup    Creates a new file, named" $filePath".backup which is a copy of
                    current" $fileName
    echo "find      Prompts user to type a username, then prints username and role if such
                    exists in users.db. If there is no user with selected username, script must print:
                    “User not found”. If there is more than one user with such username, print all
                    found entries."
    echo "list      Prints contents of users.db in format: N. username, role
                    where N – a line number of an actual record
                    Accepts an additional optional parameter inverse which allows to get
                    result in an opposite order – from bottom to top"
    echo "restore		Takes the last created backup file and replaces $fileName with it.
    								If there are no backups - script should print: “No backup file found”"
}

case $1 in
  add)            add;;
  backup)         backup;;
  restore)        restore;;
  find)           find;;
  list)           list;;
  help | '' | *)  help;;
esac
