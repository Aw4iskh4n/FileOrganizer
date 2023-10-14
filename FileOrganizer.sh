#!/bin/bash

# Define default file types based on provided categories
Docs="doc docx odt pdf rtf tex txt wpd"
Sheets="csv ods xls xlsx"
Web="asp aspx css htm html jsp php xml"
Img="bmp gif jpeg jpg png svg avif exif heic tif tiff"
Audio="aac mp3 wav flac m4a"
Video="mp4 mov webm"
Draw="ai cdr svg"
Layout="indd pub"
Code="c cpp cs java py"
Zip="7z bz2 gz rar tar zip"
Media="bin cue iso mdf nrg"
DB="accdb csv db json xml"
Mail="eml msg pst vcf"
Exe="exe app apk deb msi"
Font="eot otf ttf woff woff2"

# Get directory to organize
read -p "Enter directory to organize (Default: $HOME/Downloads): " DIRECTORY
DIRECTORY=${DIRECTORY:-$HOME/Downloads}

cd "$DIRECTORY" || exit 1

while true; do
    echo "Please choose an option:"
    echo "1. Organize all known file types"
    echo "2. Organize specific file types"
    echo "3. Add and organize custom file types"
    echo "4. Undo last organization"
    echo "5. Exit"
    read -r -p "Enter your choice (1/2/3/4/5): " CHOICE

    case $CHOICE in
        1) categories=(Docs Sheets Web Img Audio Video Draw Layout Code Zip Media DB Mail Exe Font) ;;
        2)
            echo "Please select a category of files to organize:"
            select category in Docs Sheets Web Img Audio Video Draw Layout Code Zip Media DB Mail Exe Font "Return to main menu"; do
                [[ $category == "Return to main menu" ]] && continue 2
                categories=($category)
                break
            done
            ;;
        3)
            read -p "Enter custom file extensions (space separated, e.g. jpg png gif): " CUSTOMEXTENSIONS
            read -p "Enter the name of the folder for these files: " CUSTOMFOLDER
            Custom="$CUSTOMEXTENSIONS"
            categories=(Custom)
            ;;
        4)
            if [[ ! -f organization_log.txt ]]; then
                echo "No log file found. Can't undo."
                continue
            fi
            while read -r file folder; do
                mv "$folder/$file" "$file"
            done < organization_log.txt
            rm organization_log.txt
            echo "Organization has been undone!"
            continue
            ;;
        5) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option"; continue ;;
    esac

    for category in "${categories[@]}"; do
        for ext in ${!category}; do
            if ls *.$ext &>/dev/null; then
                mkdir -p "$category"
                mv *.$ext "$category/"
                echo "*.$ext $category/" >> organization_log.txt
            fi
        done
    done

    if [[ $CHOICE == 1 ]]; then
        mkdir -p "Other"
        for file in *; do
            if [[ ! -d $file && $file != organization_log.txt ]]; then
                mv "$file" "Other/"
                echo "$file Other/" >> organization_log.txt
            fi
        done
        echo "Files have been organized based on all known types!"
    else
        echo "Files have been organized based on the selected type!"
    fi
done
