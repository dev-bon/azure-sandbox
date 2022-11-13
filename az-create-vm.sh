#!/bin/bash


function server_location {
    echo    1.  East US
    echo    2.  West US
    echo    3.  Australia East
    echo    4.  West Europe
    echo    5.  Germany
    echo    6.  Canada
    read -p "Select your Azure VM region:" ans
    case $ans in
        1  )  echo "East US"; echo eastus > vm;;
        2  )  echo "West US"; echo westus > vm;;
        3  )  echo "Australia East"; echo australiaeast > vm;;
        4  )  echo "West Europe"; echo westeurope > vm;;
        5  )  echo "Germany"; echo germany > vm;;
        6  )  echo "Canada"; echo canada > vm;;
        "" )  echo "None selected"; sleep 1; server_location;;
        *  )  echo "Invalid option"; sleep 1; server_location;;
    esac
}



