#!/bin/bash
# Choose between aws accounts script
switch_profile() {
    GREEN="\033[0;92m"
    CYAN="\033[0;96m"
    YELLOW="\033[0;93m"
    ENDCOLOR="\033[0m"
    echo -e ""
    echo -e "${GREEN}"Available AWS accounts for switch:"${ENDCOLOR}"
    options=("default" "2c2puat" "2c2p3dsuat" "2c2ppacouat" "2c2pmmuat" "2c2pmanagement" "2c2pshared" "2c2pprod" "2c2pprodeu") 
    for i in ${options[@]}; do echo -e "${CYAN}$i${ENDCOLOR}"; done
    CLIENT_NAME=$1

    # SWITCH AWS_PROFILE
    if [ 'default' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2puat
        echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2puat' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2puat
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2p3dsuat' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2p3dsuat
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2ppacouat' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2ppacouat
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"
    
    elif [ '2c2pmmuat' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2pmmuat
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"
    
    elif [ '2c2pmanagement' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2pmanagement
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2pshared' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2pshared
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2p3dsuat' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2p3dsuat
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"
    
    elif [ '2c2pprod' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2pprod
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"

    elif [ '2c2p3dsprod' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=ap-southeast-1
        export AWS_PROFILE=2c2p3dsprod
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"
    
    elif [ '2c2pprodeu' = "$CLIENT_NAME" ]; then
        echo -e "${YELLOW}switching to $CLIENT_NAME profile${ENDCOLOR}"
        export AWS_REGION=eu-central-1
        export AWS_PROFILE=2c2pprodeu
       echo -e "${YELLOW}$(aws sts get-caller-identity)${ENDCOLOR}"
    fi
}