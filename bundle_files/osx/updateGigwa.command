#!/bin/bash

if [ $# -ne 3 ] ; then
    echo 'USAGE: updateGigwa.command Path_of_new_gigwa_webapp Path_of_old_gigwa_webapp Path_of_where_to_create_backup'
    exit 1
fi

if [ -d "$1" ]; then
	if [ -d "$2" ]; then
		
		DATE=$(date +%Y%m%d%H%M)

		#save old gigwa files
		mkdir -p $3 && cp -av $2 $3/gigwa.$DATE

		#remove gigwa folder
		rm -rf $2

		#copy new gigwa folder
		cp -av $1 $2

		#copy configuration files from saved folder to new gigwa folder
		cp -av $3/gigwa.$DATE/WEB-INF/classes/applicationContext-data.xml $2/WEB-INF/classes/applicationContext-data.xml
		cp -av $3/gigwa.$DATE/WEB-INF/classes/applicationContext-security.xml $2/WEB-INF/classes/applicationContext-security.xml
		cp -av $3/gigwa.$DATE/WEB-INF/classes/datasources.properties $2/WEB-INF/classes/datasources.properties
		cp -av $3/gigwa.$DATE/WEB-INF/classes/users.properties $2/WEB-INF/classes/users.properties
		cp -av $3/gigwa.$DATE/WEB-INF/classes/config.properties $2/WEB-INF/classes/config.properties
		cp -av $3/gigwa.$DATE/WEB-INF/classes/log4j.xml $2/WEB-INF/classes/log4j.xml

		# Changes specific to migration to v2.5
		sed -i 's/project\$CREATOR/SUPERVISOR/g' $2/WEB-INF/classes/users.properties	# replace the deprecated project-CREATOR role with the new DB-level SUPERVISOR role
		if [ "$(grep -c dumpFolder $2/WEB-INF/classes/config.properties)" -eq 0 ]; then
			printf "\ndumpFolder=$HOME/gigwaDumps\n" >> $2/WEB-INF/classes/config.properties	# add dumpFolder entry to config.properties it not present
		fi		
	fi
fi

chmod -R 755 $2

echo
echo "Update complete. You may want to apply chown -R on the updated folder."