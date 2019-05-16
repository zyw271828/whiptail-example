#!/bin/bash

# 编程实现创建成绩单文件 score.txt
# 要求：
# 成绩单至少包括学号、姓名及其成绩 3 项内容，至少能够从键盘添加、删除和查询。
# Programming implementation to create a transcript file score.txt
# Requirements:
# The transcript includes at least 3 items of student number, name and grade,
# which can be added, deleted and queried from the keyboard.

LINE=14               # Height of dialog
COLUMN=70             # Width of dialog
FILE_PATH="score.txt" # Path to the transcript file

show_welcome() {
    whiptail --title "Score Management System - Welcome" \
        --msgbox "Welcome to Score Management System." $LINE $COLUMN
}

show_menu() {
    whiptail --nocancel --title "Score Management System - Menu" \
        --menu "Choose an option:" $LINE $COLUMN $(($LINE - 8)) \
        "List" "List all records on the system." \
        "Add" "Add a record to the system." \
        "Delete" "Delete an existing record." \
        "Modify" "Modify an existing record." \
        "Query" "Query records on the system." \
        "Exit" "Exit this system." 3>&1 1>&2 2>&3
}

show_list() {
    whiptail --scrolltext --title "Score Management System - List" \
        --textbox $FILE_PATH $LINE $COLUMN
}

show_add() {
    num=$(whiptail --title "Score Management System - Add" \
        --inputbox "Please enter the student number:" $LINE $COLUMN 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then # Student number entered
        # Replace all ' ' with '_', IFS will be set to ' ' when searching
        num=$(echo $num | tr ' ' _)
        # Check for duplicate student numbers
        while IFS=' ' read -r col1 col2 col3; do
            if [ $col1 = $num ]; then # Duplicate student number
                whiptail --title "Score Management System - Add" \
                    --msgbox "Error: Duplicate with existing student number." $LINE $COLUMN
                return 1
            fi
        done <$FILE_PATH
        name=$(whiptail --title "Score Management System - Add" \
            --inputbox "Please enter the student name:" $LINE $COLUMN 3>&1 1>&2 2>&3)
        if [ $? -eq 0 ]; then # Student name entered
            name=$(echo $name | tr ' ' _)
            score=$(whiptail --title "Score Management System - Add" \
                --inputbox "Please enter the score:" $LINE $COLUMN 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ]; then # Score entered
                score=$(echo $score | tr ' ' _)
                echo "$num $name $score" >>$FILE_PATH
            fi
        fi
    fi
}

show_delete() {
    while IFS=' ' read -r col1 col2 col3; do
        res+=("$col1" "$col2 $col3" "OFF")
    done <$FILE_PATH
    targets=$(whiptail --scrolltext --title "Score Management System - Delete" --checklist \
        "Please select the records you want to delete:" $LINE $COLUMN $(($LINE - 8)) "${res[@]}" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then # Selected items to be deleted
        for target in $targets; do
            # Remove double quotes
            target=$(sed -e 's/^"//' -e 's/"$//' <<<"$target")
            sed -i "/^$target/d" $FILE_PATH
        done
    fi
    unset res
}

show_modify() {
    while IFS=' ' read -r col1 col2 col3; do
        res+=("$col1" "$col2 $col3" "OFF")
    done <$FILE_PATH
    target=$(whiptail --scrolltext --title "Score Management System - Modify" --radiolist \
        "Please select the record you want to modify:" $LINE $COLUMN $(($LINE - 8)) "${res[@]}" 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then # Selected the item to be modified
        while IFS=' ' read -r col1 col2 col3; do
            if [ $col1 = $target ]; then # Found the target to be modified
                new_name=$(whiptail --title "Score Management System - Modify" \
                    --inputbox "Please enter the new student name:" $LINE $COLUMN $col2 3>&1 1>&2 2>&3)
                if [ $? -eq 0 ]; then # New student name entered
                    new_name=$(echo $new_name | tr ' ' _)
                    new_score=$(whiptail --title "Score Management System - Modify" \
                        --inputbox "Please enter the new score:" $LINE $COLUMN $col3 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then # New score entered
                        new_score=$(echo $new_score | tr ' ' _)
                        sed -i "s/$col1\ $col2\ $col3/$target\ $new_name\ $new_score/g" $FILE_PATH
                    fi
                fi
            fi
        done <$FILE_PATH
    fi
    unset res
}

show_query() {
    i=$(whiptail --title "Score Management System - Query" --radiolist \
        "Which item do you want to query?" $LINE $COLUMN $(($LINE - 8)) \
        "Number" "Student Number" ON \
        "Name" "Student Name" OFF \
        "Score" "Test Score" OFF 3>&1 1>&2 2>&3)
    if [ $? -eq 0 ]; then # Selected the item to be queried
        if [ $i = "Number" ]; then # Query by student number
            num=$(whiptail --title "Score Management System - Query" \
                --inputbox "Please enter the student number:" $LINE $COLUMN 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ]; then # Student number entered
                while IFS=' ' read -r col1 col2 col3; do
                    if [ $col1 = $num ]; then # Found the target to be queried
                        res+=("$col1 $col2 $col3")
                    fi
                done <$FILE_PATH
                if [ -z ${res+x} ]; then # Did not find the target to be queried
                    res="< Empty >"
                fi
                whiptail --title "Score Management System - Query - $i = $num" \
                    --scrolltext --msgbox "$res" $LINE $COLUMN
            fi
        elif [ $i = "Name" ]; then # Query by student name
            name=$(whiptail --title "Score Management System - Query" \
                --inputbox "Please enter the student name:" $LINE $COLUMN 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ]; then # Student name entered
                while IFS=' ' read -r col1 col2 col3; do
                    if [ $col2 = $name ]; then # Found the target to be queried
                        res+=("$col1 $col2 $col3")
                    fi
                done <$FILE_PATH
                if [ -z ${res+x} ]; then # Did not find the target to be queried
                    res="< Empty >"
                fi
                whiptail --title "Score Management System - Query - $i = $name" \
                    --scrolltext --msgbox "$res" $LINE $COLUMN
            fi
        elif [ $i = "Score" ]; then # Query by score
            score=$(whiptail --title "Score Management System - Query" \
                --inputbox "Please enter the score:" $LINE $COLUMN 3>&1 1>&2 2>&3)
            if [ $? -eq 0 ]; then # Score entered
                while IFS=' ' read -r col1 col2 col3; do
                    if [ $col3 -eq $score ]; then # Found the target to be queried
                        res+=("$col1 $col2 $col3")
                    fi
                done <$FILE_PATH
                if [ -z ${res+x} ]; then # Did not find the target to be queried
                    res="< Empty >"
                fi
                whiptail --title "Score Management System - Query - $i = $score" \
                    --scrolltext --msgbox "$res" $LINE $COLUMN
            fi
        fi
    fi
    unset res
}

show_exit() {
    whiptail --title "Score Management System - Exit" \
        --msgbox "Thanks for using. Goodbye." $LINE $COLUMN
}

show_welcome
if [ ! -f $FILE_PATH ]; then # File does not exist
    touch $FILE_PATH
fi
while :; do
    item=$(show_menu)
    if [ $item = "List" ]; then
        show_list
    elif [ $item = "Add" ]; then
        show_add
    elif [ $item = "Delete" ]; then
        show_delete
    elif [ $item = "Modify" ]; then
        show_modify
    elif [ $item = "Query" ]; then
        show_query
    elif [ $item = "Exit" ]; then
        show_exit
        break
    fi
done
