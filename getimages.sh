#Name: Tee Hock Nian 
#Student Number: 10533790

#!/bin/bash



overwrite(){ #function to overwrite an image if already existed
    
    wget -q "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/DSC0$line.jpg" -O $dirname/DSC0$line.jpg #wget the image(in quiet mode) and output the file to the location specified
            fsize=$(du -b "$dirname/DSC0$line.jpg" | awk '{size=$1/1024; printf "%.2fKB",size }') #Calculate size of the image in KB
            ftotal=$(echo $ftotal $fsize | awk '{sum=$1+$2; printf "%.2fKB\n",sum}') #Calculate total files downloaded
            echo ""
            echo "Downloading DSC0$line, with the file name DSC0$line.jpg, with a file size of $fsize... .File Download Complete" #Output the result
            echo ""
}

download_image(){ #function to download image

    wget -q -P $dirname "https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/DSC0$line.jpg" #wget the image(in quiet mode) to specified directory given by user ($dirname)
             fsize=$(du -b "$dirname/DSC0$line.jpg" | awk '{size=$1/1024; printf "%.2fKB",size }') #Calculate size of the image in KB
             ftotal=$(echo $ftotal $fsize | awk '{sum=$1+$2; printf "%.2fKB\n",sum}') #Calculate total files downloaded
             echo ""
             echo "Downloading DSC0$line, with the file name DSC0$line.jpg, with a file size of $fsize... .File Download Complete" #Output the result
             echo ""

}

user_choice=0
exit=6
echo "Retrieving data from https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus......."
curl -s  "https://www.ecu.edu.au/service-centres/MACSC/gallery/gallery.php?folder=ml-2018-campus" | grep  'https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/DSC0' | sed 's/.*\///; s/DSC0//; s/.jpg".*//' > temp.txt
#First pipe: Curl the whole website 
#Second pipe: Use grep to find those lines with the link https://secure.ecu.edu.au/service-centres/MACSC/gallery/ml-2018-campus/DSC0 
#Third pipe: First sed:substitute any strings in front and until the symbol / to nothing. Second sed:substitute DSC0 to nothing. Third sed:substitute .jpg" until the end of the line to nothing.
# All the last 4 digits of each images will be acquired and output to temp.txt file. 
echo ""
echo "data saved in temp.txt file!"
echo ""
while [ $user_choice -ne $exit ];do # if the statement is false, which is 6 not equal 6 , it will exit the program
    echo "1. DOWNLOAD SPECIFIC THUMBNAIL"
    echo "2. DOWNLOAD IMAGES IN A RANGE"
    echo "3. DOWNLOAD A SPECIFIED NUMBER OF IMAGES"
    echo "4. DOWNLOAD ALL THUMBNAILS"
    echo "5. CLEAN UP ALL FILES"
    echo "6. EXIT THE PROGRAM"
    read -p ">>" user_choice

    if [[ $user_choice =~ [[:digit:]] ]];then #Check if user entered digit number 

        if [ $user_choice -eq 1 ];then # DOWNLOAD SPECIFIC THUMBNAIL
        clear
        echo "1. DOWNLOAD SPECIFIC THUMBNAIL"
        echo ""
        read -p "Destination directory: " dirname

        while true;do
            read -p "Enter the last 4 digit of the image:" line
            if [[ $line =~ ^[0-9]{4}$ ]];then #Check to see if inputs contain only 4 digits
                if grep -q "$line" temp.txt;then # grep in quiet mode to compare if the 4 digits entered by user existed in temp.txt or not.
                    if [ -f "$dirname/DSC0$line.jpg" ];then # check if file existed already or not in directory provided by user.
                        echo "The image file DSC0$line.jpg already existed in $dirname directory!"
                        while true;do
                            read -p "1.overwrite or 2.skip: " choice
            
                            if [ $choice -eq 1 ];then #Overwite
                                overwrite # Call overwrite function
                                break
                
                            elif [ $choice -eq 2 ]; then #Skip
                                echo "Image DSC0$line.jpg skipped!"
                                echo ""
                                break
                
                            else
                                echo "Invalid input!"
                            fi
                        done
                           

                    else # If file doesn't exist in directory provided by user, download the image.
                        download_image #Function download_image called.
                    fi

                    ftotal=0 # Reset the value of ftotal to zero.
                    break
                else
                    echo "No records found! Try range from 0200~0674" #4 digits provided not existed in temp.txt file
                fi

            else
                echo "Invalid input!"
            fi
        done
 
        elif [ $user_choice -eq 2 ];then # DOWNLOAD IMAGES IN A RANGE
            clear
            echo "2. DOWNLOAD IMAGES IN A RANGE (0200 ~ 0674)"
            echo ""
            read -p "Destination directory: " dirname

            while true;do
                read -p "Enter the last 4 digit of the image to be your starting range:" num1
                read -p "Enter another last 4 digit of the image to be your ending range:" num2

                if [[ $num1 =~ ^[0-9]{4}$ && $num2 =~ ^[0-9]{4}$ && $num1 < $num2 ]];then # Check if both numbers provided contain only 4 digits and also starting range(num1) must smaller than ending range(num2)
                    counter=0
                    for line in $(cat temp.txt);do # Read temp.txt line by line 
                        if [ $line -ge $num1 -a $line -le $num2 ]; then #Compare the range if it is greater/equal to line and also smaller/equal ending range.
                            if [ -f "$dirname/DSC0$line.jpg" ];then #Check if file existed.
                                echo "The image file DSC0$line.jpg already existed in $dirname directory!"
                                while true;do
                                    read -p "1.overwrite or 2.skip: " choice
                 
                                    if [ $choice -eq 1 ];then #Overwrite
                                        overwrite #Overwite function called
                                        ((counter++)) #value of variable counter increase by 1
                                        break
                
                                    elif [ $choice -eq 2 ]; then #Skip
                                        echo "Image DSC0$line.jpg skipped!" 
                                        echo ""
                                        break
                
                                    else
                                        echo "Invalid input!"
                                    fi
                                done

                            else #If file not existed, download image.
                                download_image
                                ((counter++)) #Counter increase by 1
                            fi
                        else
                            continue
                        fi
                    done

                    if [[ $counter != 0 ]];then # Check the value of variable counter to see if any image downloaded.
                        echo "Total size of $counter images downloaded to $dirname directory is $ftotal"
                        echo ""
                        ftotal=0 #Reset the value of ftotal to zero.
                    else
                        echo "No image found !"
                    fi
                    break


                else
                    echo "Invalid input!"
                fi
            done
 
        elif [ $user_choice -eq 3 ];then #DOWNLOAD A SPECIFIED NUMBER OF IMAGES
            clear
            echo "3. DOWNLOAD A SPECIFIED NUMBER OF IMAGES"
            echo ""
            read -p "Destination directory: " dirname

            while true;do
                read -p "Enter the number of images to download:" num1

                if [[ $num1 =~ ^[0-9]+$ ]];then #Check if number provided contain only 4 digits 
                    if [ $num1 -ge 1 -a $num1 -le 147 ]; then #check if number greater/equal 1 and smaller/equal 147. (147 is the total images on the website.)

                        for line in $(shuf -n $num1 temp.txt);do # shuf command randomly select number of lines from temp.txt and the number is provided by user and read those lines line by line. 
                            if [ -f "$dirname/DSC0$line.jpg" ];then #Check if file existed.
                                echo "The image file DSC0$line.jpg already existed in $dirname directory!"
                                while true;do
                                    read -p "1.overwrite or 2.skip: " choice

                                    if [ $choice -eq 1 ];then #Overwrite
                                        overwrite
                                        break
                
                                    elif [ $choice -eq 2 ];then #Skip
                                        echo "Image DSC0$line.jpg skipped!"
                                        echo ""
                                        break
                
                                    else
                                        echo "Invalid input!"
                                    fi
                                done

                            else #Download image if file didn't exist.
                                download_image
                            fi
                        done
                        echo "Total size of images downloaded to $dirname directory is $ftotal"
                        echo ""
                        ftotal=0 #Reset the value of ftotal to zero
                        break

                    else # Number entered by user is not within the range 1 to 147
                        echo "Number given is not within 1~147!"
                    fi 

                else
                    echo "Invalid input!"
                fi
            done


        elif [ $user_choice -eq 4 ];then #DOWNLOAD ALL THUMBNAILS
            clear
            echo "4. DOWNLOAD ALL THUMBNAILS"
            echo ""
            read -p "Destination directory: " dirname

            for line in $(cat temp.txt);do # read temp.txt file line by line

                if [ -f "$dirname/DSC0$line.jpg" ];then #Check if file existed.
                    echo "The image file DSC0$line.jpg already existed in $dirname directory!"
                    while true;do
                        read -p "1.overwrite or 2.skip: " choice

                        if [ $choice -eq 1 ];then #Overwrite
                            overwrite
                            break
                
                        elif [ $choice -eq 2 ]; then #Skip
                            echo "Image DSC0$line.jpg skipped!"
                            echo ""
                            break
                
                        else
                            echo "Invalid input!"
                        fi
                    done

                else #Download image if file didn't exist
                    download_image
                fi
            done

            echo "Total size of images downloaded to $dirname directory is $ftotal"
            echo ""
            ftotal=0 #Reset the value ftotal to zero





        elif [ $user_choice -eq 5 ];then #CLEAN ALL FILES

            if [[ -n $(find -maxdepth 2 -type f -name 'DSC0*.jpg') ]];then # IF the result of find command contain non empty strings.
                clear
                find -maxdepth 2 -type f -name 'DSC0*.jpg' #Find the file with name starting with DSC0 and ending with extension .jpg and find those files until 1 layer deeper from current directory only.
                echo " $(find -maxdepth 2 -type f -name 'DSC0*.jpg' -printf '.' | wc -c) results found!" #Output the total results found
                echo ""
                while true;do
                    read -p "Delete files? 1. Continue or 2. Cancel: " choice
    
                    if [ $choice -eq 1 ];then
                        find -maxdepth 2 -type f -name 'DSC0*.jpg' -exec rm {} \; #Delete all the images 
                        find -maxdepth 1 -type d -empty -delete  #Delete empty directories on current working directory only.
                        echo "Files successfully cleaned!"
                        echo ""
                        break

                
                    elif [ $choice -eq 2 ];then
                        break

                    else
                        echo "Invalid input!"
                    fi
                done
      
            else 
                echo "No files to clean!"
                echo ""
            fi

        elif [ $user_choice -eq 6 ];then #EXIT THE PROGRAM
            rm temp.txt  #Remove temp.txt file
            echo "temp.txt file deleted."
            echo "Terminating program......"
          
    
        else
            echo "Enter number between 1 to 6 only!"
            echo ""
            user_choice=0 # Reset the value of user_choice to 0.
        fi


    else 
        echo "Invalid input!"
        echo ""
        user_choice=0 # Reset the value of user_choice to 0 to avoid sudden crash of program due to the while loop that cannot compare strings/empty string (If user entered) with numbers.
    fi

done

exit 0