#! /bin/sh

# Recommendation: Plugin used awk, gawk (Install command of gawk in ubuntu: sudo apt-get install gawk)


# Perform tasks without date and hour 
# Check for four agrs
if [ $# -eq 4 ] 
then
		
		arg4=`echo "$4"`

		# if arg4 is not a file
		if [ ! -f $arg4 ]
		then
				echo -e "Standard input is running..."

				FILE="/dev/stdin"
				# Store std in within stdhttpd file 
				cat ${FILE} > stdhttpd
	
				# Enter choice for functions
				# Limiting the number of result by head $2
				case $3 in
					"-c")
							echo -e "Which IP address makes the most number of connection attempts?\n" 
						  awk -F' ' '{ print $1 }' stdhttpd | sort | uniq -c | sort -rn | head -$2
							rm stdhttpd
						      ;;

					"-2")
							echo -e "\nWhich address makes the most number of successful attempts?\n wait...\n"
							while read row
							do
								status=`echo $row | awk '{print $9}'`
								# Check for the successfull status codes
								if [ "$status" -lt 400 ]
									then
										echo $row | awk '{print $1, $9}' >> r_result
								fi
							done <stdhttpd
							rm stdhttpd
							
							awk -F' ' '{ print $1, $9 }' r_result | sort | uniq -c | sort -rn | head -$2
							rm r_result	            
									;;
									
					"-r")
							echo -e "\nWhat are the most common results codes and where do they come from?\n wait...\n"
							awk '{print $9"\t"$1}' stdhttpd | sort | uniq -c | sort -nr | head -$2
							rm stdhttpd
									;;

					"-F")
							echo -e "\nWhat are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?\n wait...\n"
							while read f_row
							do
								f_status=`echo $f_row | awk '{print $9}'`
								# Check for the failed status code
								if [ "$f_status" -gt 399 ]
									then
										echo $f_row | awk '{print $1, $9}' >> f_result
								fi
							done <stdhttpd
							rm stdhttpd

							cat f_result | awk '{print $2"\t"$1}' | sort | uniq -c | sort -nr | head -$2
							rm f_result
									;;

					"-t")
							echo -e "\nWhich IP number get the most bytes sent to them?\n"
							awk '{print $10"\t"$1}' stdhttpd | sort -nr | head -$2
							rm stdhttpd
									;;

					*)
			        echo "Invalid arguments (Enter: -c or -2 or -r or -F or -t)"
			            ;;
				esac


		else
				# Perform tasks with out std input
				# Check for right directory
				if [ -r $4 ]
				then
				
				case $3 in
					"-c")
					    echo -e "Which IP address makes the most number of connection attempts?\n" 
					    awk -F' ' '{ print $1 }' $4 | sort | uniq -c | sort -rn | head -$2
					        ;;

					"-2")
							echo -e "\nWhich address makes the most number of successful attempts?\n wait...\n"
							while read row
							do
								status=`echo $row | awk '{print $9}'`
								if [ "$status" -lt 400 ]
									then
										echo $row | awk '{print $1, $9}' >> r_result
								fi
							done <$4

							awk -F' ' '{ print $1, $9 }' r_result | sort | uniq -c | sort -rn | head -$2
							rm r_result	            
									;;
									
					"-r")
							echo -e "\nWhat are the most common results codes and where do they come from?\n wait...\n"
							awk '{print $9"\t"$1}' $4 | sort | uniq -c | sort -nr | head -$2
									;;

					"-F")
							echo -e "\nWhat are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?\n wait...\n"
							while read f_row
							do
								f_status=`echo $f_row | awk '{print $9}'`
								if [ "$f_status" -gt 399 ]
									then
										echo $f_row | awk '{print $1, $9}' >> f_result
								fi
							done <$4
							cat f_result | awk '{print $2"\t"$1}' | sort | uniq -c | sort -nr | head -$2
							rm f_result
									;;

					"-t")
							echo -e "\nWhich IP number get the most bytes sent to them?\n"
							awk '{print $10"\t"$1}' $4 | sort -nr | head -$2
									;;

					*)
	            echo "Invalid arguments (Enter: -c or -2 or -r or -F or -t)"
	                ;;
				esac

				else
					echo "wrong file directory or file has permission problem" 
				fi
		
    fi	

# Perform tasks considering date and hour 
# Check for six agrs
elif [ $# -eq 6 ]
then

	arg6=`echo "$6"`

	if [ ! -f $arg6 ]
	then
		echo -e "Standard input is running..."

		FILE="/dev/stdin"
		cat ${FILE} > stdhttpd

		# Define Min, Hrs
		MPHR=60    # Minutes per hour.
		HPD=24     # Hours per day.
		
		# Calculate time Different
		# %d = day of month, %s = sec 
		diff () {
			printf '%s' $(( $(date -u -d"$TARGET" +%s) -
				        $(date -u -d"$CURRENT" +%s)))
		
		}


    given_hrs=`echo $4`
		given_days=`echo $4`

		# Taken last time in log file
		temp_date=`cat stdhttpd | tail -n1 | cut -d [ -f 2 | cut -d ] -f 1`
		#echo "$temp_date"

		temp_date2=`echo $temp_date | \
		sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
		-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
		#echo "$temp_date2"
		  
		# configure gawk in ubuntu: sudo apt-get install gawk 
		# rettriving year, month, day and time from last line of log file 
		temp_year=`echo $temp_date2 | gawk '{print substr($0,7,4)}'`
		temp_month=`echo $temp_date2 | gawk '{print substr($0,4,2)}'`
		temp_day=`echo $temp_date2 | gawk '{print substr($0,1,2)}'`
		temp_time=`echo $temp_date2 | gawk '{print substr($0,12,8)}'`

		#UTC format
		utc_date="$temp_year-$temp_month-$temp_day $temp_time"
		#echo "$utc_date"

    case "$3" in
	  "-h") 
				# Input hours always less then 24 
				if [ $given_hrs -lt 24 ]
					then

						# Save file in reverse order to read latest hr line 
						linecnt=`wc -l stdhttpd | awk '{print $1}'`

						while [ $linecnt -ge 1 ]
						do
							sed -n "$linecnt"p stdhttpd >> rev_httpd
							linecnt=$(($linecnt - 1))
						done
				    rm stdhttpd
				                  
				    while read line
				    do
								# Taking time from each line of given file
								line_time=`echo $line | awk '{print $4}' | cut -c2-21`

								# Make the time for std format
								line_time2=`echo $line_time | \
								sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
								-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
					

								l_year=`echo $line_time2 | gawk '{print substr($0,7,4)}'`
								l_month=`echo $line_time2 | gawk '{print substr($0,4,2)}'`
								l_day=`echo $line_time2 | gawk '{print substr($0,1,2)}'`
								l_time=`echo $line_time2 | gawk '{print substr($0,12,8)}'`
	
								l_utc_date="$l_year-$l_month-$l_day $l_time"	
								#echo "$l_utc_date"

								c=`echo "$l_utc_date"` 
								t=`echo "$utc_date"`

								CURRENT=$(date -u -d"$c" '+%F %T.%N %Z')
								TARGET=$(date -u -d"$t" '+%F %T.%N %Z')
								# %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

								DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
								CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')
								HOURS=$(( $(diff) / $MPHR / $MPHR ))
								CURRENT=$(date -d"$CURRENT +$HOURS hours" '+%F %T.%N %Z')
				
								# Reading every line and compare hrs difference from last log hrs
								if [ $HOURS -le $given_hrs ]
									then     
						         	# If got line's time (hrs) less then last log file hr; Then stores it to file 
						         	echo $line >> thttpd 
								fi
				    done <rev_httpd
				    # Remove the file after tasks has performed to avoid overlapping input for performing second time 
				    rm rev_httpd
				    
				else 
            echo "please give hours less than 24"
            exit 0
				fi
								;;

    "-d")
    		# Perform tasks for days input and calculate as the same logic as hrs
    		while read line
        do
						line_time=`echo $line | awk '{print $4}' | cut -c2-21`

						line_time2=`echo $line_time | \
						sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
						-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
				

						l_year=`echo $line_time2 | gawk '{print substr($0,7,4)}'`
						l_month=`echo $line_time2 | gawk '{print substr($0,4,2)}'`
						l_day=`echo $line_time2 | gawk '{print substr($0,1,2)}'`
						l_time=`echo $line_time2 | gawk '{print substr($0,12,8)}'`

						l_utc_date="$l_year-$l_month-$l_day $l_time"	
						#echo "$l_utc_date"

						c=`echo "$l_utc_date"` 
						t=`echo "$utc_date"`

						CURRENT=$(date -u -d"$c" '+%F %T.%N %Z')
						TARGET=$(date -u -d"$t" '+%F %T.%N %Z')
						# %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

						DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
						CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')
					
			

						if [ $DAYS -le $given_days ]
						then     
				       	echo $line >> thttpd 
						fi
        done <stdhttpd
        rm stdhttpd
        				 ;;
        				

    *) echo "Please enter choice -h (hours) or -d (days)"
    exit 0
    	           ;;
    esac

		# Perform case on processed data (thttpd)
    case $5 in
	    "-c")
	        echo -e "Which IP address makes the most number of connection attempts?\n" 
	        awk -F' ' '{ print $1 }' thttpd | sort | uniq -c | sort -rn | head -$2
					rm thttpd
	            		;;

	    "-2")
					echo -e "\nWhich address makes the most number of successful attempts?\n wait...\n"
					while read row
					do
						status=`echo $row | awk '{print $9}'`
						if [ "$status" -lt 400 ]
							then
								echo $row | awk '{print $1, $9}' >> r_result
						fi
					done <thttpd
					rm thttpd

					awk -F' ' '{ print $1, $9 }' r_result | sort | uniq -c | sort -rn | head -$2
					rm r_result	            
								;;
								
	    "-r")
					echo -e "\nWhat are the most common results codes and where do they come from?\n wait...\n"
					awk '{print $9"\t"$1}' thttpd | sort | uniq -c | sort -nr | head -$2
					rm thttpd
								;;
								

	    "-F")
					echo -e "\nWhat are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?\n wait...\n"
					while read f_row
					do
						f_status=`echo $f_row | awk '{print $9}'`
						if [ "$f_status" -gt 399 ]
							then
								echo $f_row | awk '{print $1, $9}' >> f_result
						fi
					done <thttpd
					rm thttpd

					cat f_result | awk '{print $2"\t"$1}' | sort | uniq -c | sort -nr | head -$2
					rm f_result
								;;

	    "-t")
					echo -e "\nWhich IP number get the most bytes sent to them?\n wait...\n"
					awk '{print $10"\t"$1}' thttpd | sort -nr | head -$2
					rm thttpd
								;;

	    *)
          echo "Invalid arguments (Enter: -c or -2 or -r or -F or -t)"
	              ;;
     esac

	
	else
    if [ -r $6 ]
    then


				# Define Min, Hrs
				MPHR=60    # Minutes per hour.
				HPD=24     # Hours per day.
		
				# Calculate time Different
				#                       %d = day of month.
				diff () {
					printf '%s' $(( $(date -u -d"$TARGET" +%s) -
								    $(date -u -d"$CURRENT" +%s)))
		
				}

				# Given Hrs and Days passed by arg
				given_hrs=`echo $4`
				given_days=`echo $4`

				# Taken last time in log file
				temp_date=`cat $6 | tail -n1 | cut -d [ -f 2 | cut -d ] -f 1`
				#echo "$temp_date"

				temp_date2=`echo $temp_date | \
				sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
				-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
				#echo "$temp_date2"
				
				# configure gawk in ubuntu: sudo apt-get install gawk 
				temp_year=`echo $temp_date2 | gawk '{print substr($0,7,4)}'`
				temp_month=`echo $temp_date2 | gawk '{print substr($0,4,2)}'`
				temp_day=`echo $temp_date2 | gawk '{print substr($0,1,2)}'`
				temp_time=`echo $temp_date2 | gawk '{print substr($0,12,8)}'`

				#UTC format
				utc_date="$temp_year-$temp_month-$temp_day $temp_time"
				#echo "$utc_date"

      	case "$3" in
	  			"-h") 

						if [ $given_hrs -lt 24 ]
							then
							
							# Save file in reverse order to read latest hr line 
							linecnt=`wc -l $6 | awk '{print $1}'`

							while [ $linecnt -ge 1 ]
							do
								sed -n "$linecnt"p $6 >> rev_httpd
								linecnt=$(($linecnt - 1))
							done
							
							while read line
							do
								line_time=`echo $line | awk '{print $4}' | cut -c2-21`

								line_time2=`echo $line_time | \
								sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
								-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
					

								l_year=`echo $line_time2 | gawk '{print substr($0,7,4)}'`
								l_month=`echo $line_time2 | gawk '{print substr($0,4,2)}'`
								l_day=`echo $line_time2 | gawk '{print substr($0,1,2)}'`
								l_time=`echo $line_time2 | gawk '{print substr($0,12,8)}'`
	
								l_utc_date="$l_year-$l_month-$l_day $l_time"	
								#echo "$l_utc_date"

								c=`echo "$l_utc_date"` 
								t=`echo "$utc_date"`

								CURRENT=$(date -u -d"$c" '+%F %T.%N %Z')
								TARGET=$(date -u -d"$t" '+%F %T.%N %Z')
								# %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

								DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
								CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')
								HOURS=$(( $(diff) / $MPHR / $MPHR ))
								CURRENT=$(date -d"$CURRENT +$HOURS hours" '+%F %T.%N %Z')
				

								if [ $HOURS -le $given_hrs ]
									then     
									    echo $line >> thttpd 
								fi
							done <rev_httpd
							rm rev_httpd
						else 
		            echo "please give hours less than 24"
		            exit 0
		        fi
                    ;;

          "-d")
          		while read line
              do
								line_time=`echo $line | awk '{print $4}' | cut -c2-21`

								line_time2=`echo $line_time | \
								sed -e 's/Jan/01/g' -e 's/Feb/02/g' -e 's/Mar/03/g' -e 's/Apr/04/g' -e 's/May/05/g' \
								-e 's/Jun/06/g' -e 's/Jul/07/g' -e 's/Aug/08/g' -e 's/Sep/09/g' -e 's/Oct/10/g' -e 's/Nov/11/g' -e 's/Dec/12/g'`
					

								l_year=`echo $line_time2 | gawk '{print substr($0,7,4)}'`
								l_month=`echo $line_time2 | gawk '{print substr($0,4,2)}'`
								l_day=`echo $line_time2 | gawk '{print substr($0,1,2)}'`
								l_time=`echo $line_time2 | gawk '{print substr($0,12,8)}'`
	
								l_utc_date="$l_year-$l_month-$l_day $l_time"	
								#echo "$l_utc_date"

								c=`echo "$l_utc_date"` 
								t=`echo "$utc_date"`

								CURRENT=$(date -u -d"$c" '+%F %T.%N %Z')
								TARGET=$(date -u -d"$t" '+%F %T.%N %Z')
								# %F = full date, %T = %H:%M:%S, %N = nanoseconds, %Z = time zone.

								DAYS=$(( $(diff) / $MPHR / $MPHR / $HPD ))
								CURRENT=$(date -d"$CURRENT +$DAYS days" '+%F %T.%N %Z')

								if [ $DAYS -le $given_days ]
									then     
								     	echo $line >> thttpd 
								fi
              done <$6
                    ;;

          *) echo "Please enter choice -h (hours) or -d (days)"
             exit 0
                   ;;
       esac


       case $5 in
	    		"-c")
					    echo -e "Which IP address makes the most number of connection attempts?\n" 
					    awk -F' ' '{ print $1 }' thttpd | sort | uniq -c | sort -rn | head -$2
							rm thttpd
				            ;;

	    		"-2")
						echo -e "\nWhich address makes the most number of successful attempts?\n wait...\n"
						while read row
						do
							status=`echo $row | awk '{print $9}'`
							if [ "$status" -lt 400 ]
								then
									echo $row | awk '{print $1, $9}' >> r_result
							fi
						done <thttpd
						rm thttpd

						awk -F' ' '{ print $1, $9 }' r_result | sort | uniq -c | sort -rn | head -$2
						rm r_result	            
									;;
									
			  	"-r")
						echo -e "\nWhat are the most common results codes and where do they come from?\n wait...\n"
						awk '{print $9"\t"$1}' thttpd | sort | uniq -c | sort -nr | head -$2
						rm thttpd
									;;

	    		"-F")
						echo -e "\nWhat are the most common result codes that indicate failure (no auth, not found etc) and where do they come from?\n wait...\n"
						while read f_row
						do
							f_status=`echo $f_row | awk '{print $9}'`
							if [ "$f_status" -gt 399 ]
								then
									echo $f_row | awk '{print $1, $9}' >> f_result
							fi
						done <thttpd
						rm thttpd

						cat f_result | awk '{print $2"\t"$1}' | sort | uniq -c | sort -nr | head -$2
						rm f_result
									;;

	    		"-t")
						echo -e "\nWhich IP number get the most bytes sent to them?\n"
						awk '{print $10"\t"$1}' thttpd | sort -nr | head -$2
						rm thttpd
									;;

				  *)
            echo "Invalid arguments (Enter: -c or -2 or -r or -F or -t)"
                  ;;
       esac

    else
			echo "You entered wrong file directory, please enter a valid file"
    fi
    
	fi

else
		echo "Please enter input string properly: eg, sh log_sum(.sh|.py) [-n N] [-h H|-d D] [-c|-2|-r|-F|-t] <log_filename> "
		# '-' indicating for std input
		echo "Plese enter input string properly for std input: eg, cat <log_filename> | sh log_sum(.sh|.py) [-n N] [-h H|-d D] [-c|-2|-r|-F|-t] - "
fi


