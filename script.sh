#!/bin/bash
confFilePath=$HOME/.classScript/conf.cfg
if [ ! -d $HOME/.classScript/ ]
then
    mkdir -p $HOME/.classScript/
fi
if [ ! -f $confFilePath ]
then
    touch $confFilePath
fi
source $confFilePath

getPath () {
    read -r path
    path=$(echo $path | sed 's/\\/\//g')
}


if [ -z "$mainPath" ]
then
    echo -e '-----------------\n Enter file path to main repo'
    getPath
else   
    echo -e "-----------------\n Main repo path \"$mainPath\" previously used.  Use again? y/n"
    read useAgain
    if [ $useAgain == 'y' ] || [ $useAgain == 'Y' ]
    then
        path=$mainPath
    else
        echo -e '-----------------\n Enter file path to main repo'
        getPath
    fi

fi

while :
do
    if [ ! -d "$path/01-Class-Content" ]
    then
        echo -e "-----------------\n\"$path\" does not exist or seems incorrect.  Please try again"
        getPath
    else
        break
    fi
done

mainPath="$path/01-Class-Content"
echo "mainPath=\"$path\"" > $confFilePath



if [ -z "$classPath" ]
then
    echo -e "-----------------\n Enter file path to class repo"
    getPath
else   
    echo -e "-----------------\n Class repo path \"$classPath\" previously used.  Use again? y/n"
    read useAgain
    if [ $useAgain == 'y' ] || [ $useAgain == 'Y' ]
    then
        path=$classPath
    else
        echo -e "-----------------\n Enter file path to class repo"
        getPath
    fi

fi

while :
do
    if [ ! -d "$path" ]
    then
        echo -e "-----------------\n \"$path\" does not exist.  Please try again"
        getPath
    else
        break
    fi
done

classPath=$path
echo "classPath=\"$path\"" >> $confFilePath


echo -e '-----------------\n What Unit to Copy?'
read unit
zeros="00"
tempUnit=$zeros$unit
unit=${tempUnit:(-2)}

echo "Unit - $unit"
mainPathUnit=$(find "$mainPath" -maxdepth 1 -mindepth 1 -name "$unit*")
echo "$mainPathUnit"
cp -a "$mainPathUnit" "$classPath"
classPathUnit=$(find "$classPath" -maxdepth 1 -mindepth 1 -name "$unit*")
find "$classPathUnit" -mindepth 1 -iname "solved" -type d -exec rm -rf {} +
find "$classPathUnit" -mindepth 1 -iname "main" -type d -exec rm -rf {} +

cd "$classPathUnit"

echo -e '-----------------\n Do you want to do a commit? y/n'
read commitVerify
if [ $commitVerify == "y" ] || [ $commitVerify == "Y" ]
then
    if [ -z "$sshKeyPath" ]
    then
        echo -e "-----------------\n Enter path to your SSH private key"
        getPath
    else   
        echo -e "-----------------\n SSH private key path \"$sshKeyPath\" previously used.  Use again? y/n"
        
        read useAgain
        if [ $useSSHAgain == 'y' ] || [ $useSSHAgain == 'Y' ]
        then
            path=$sshKeyPath
        else
            echo -e "-----------------\n Enter file path to SSH Private key"
            getPath
        fi

    fi
    git add .
    git commit -m "Unit $unit initial commit"
    git push
fi


echo -e '-----------------\n Do you want to copy solved back in? y/n'
read copySolved

if [ $copySolved == "y" ] || [ $copySolved == "Y" ]
then
    cp -an "$mainPathUnit" "$classPath"
    find "$classPathUnit" -mindepth 1 -iname "main" -type d -exec rm -rf {} +
fi


