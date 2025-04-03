#!/bin/bash
# Choose between aws accounts script

PS3='Please enter your aws account:'
options=("default" "2c2puat" "2c2p3dsuat" "2c2ppacouat" "2c2pmmuat" "2c2pmanagement" "2c2pshared" "2c2pprod" "2c2pprodeu" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "default")
            aws configure --profile ${options[0]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2puat")
            aws configure --profile ${options[1]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2p3dsuat")
            aws configure --profile ${options[2]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2ppacouat")
            aws configure --profile ${options[3]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2pmmuat")
            aws configure --profile ${options[4]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2pmanagement")
            aws configure --profile ${options[5]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            ;;
        "2c2pshared")
            aws configure --profile ${options[6]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "2c2pprod")
            aws configure --profile ${options[7]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            ;;
        "2c2pprodeu")
            aws configure --profile ${options[8]}
            echo -e "$(export AWS_PROFILE=${options[0]})"
            echo "succsessfully switched to $opt"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
