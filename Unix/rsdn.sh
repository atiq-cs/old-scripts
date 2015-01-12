#	Author:	Atiqur Rahman
#	Genre:	Originally developed on Unix (Solaris)
#				However, should run in Linux without modification

#	Usage:	Provide your download links in a text file named queue.txt and run this script
# Feature request
# 	Check download size, match and verify

# constants

# PATH=/usr/bin:/usr/openwin/bin:/usr/ucb:/usr/local/bin:/usr/sfw/bin:/opt/sfw/bin:/opt/csw/bin:/usr/ccs/bin:/export/ar/cs161/bin

saveDIR=$PWD
interval=1
jobid=0
rsdir=/h/sourcecodes/Scripts/unix
logfile=$rsdir/rsdn.log

cd $rsdir

echo AR Rapidshare Download Opponent on MS OS
echo
echo Service started at `date`>>$logfile

for eachUrl in `cat rsqueue.txt`
do
    if [ -z "`echo $eachUrl | grep rapidshare.com`" ]; then
        echo Line feed. Skipping..
        continue
    fi
	let jobid+=1
	echo Job $jobid: $eachUrl
    echo

    tries=0

    # save cookie 1 for all future use
    wget -q --save-cookies=cookie1 $eachUrl -O ForCookie1.html

    server=`grep post ForCookie1.html | grep action | sed 's/[^"]*"\([^"]*\).*/\1/' | head -2 | tail -1`
    echo -e "\rFetching file server info from $server"

    fsize=`grep downloadlink ForCookie1.html | cut -d"|" -f2 | cut -d" " -f2`
    fname=`grep downloadlink ForCookie1.html | cut -d"/" -f6 | cut -d "<" -f1 | cut -d" " -f1`

    # if the file alreay exists
    if [ -s $fname ]; then
        echo
        echo File $fname already exists.
        csize=`ls -l $fname | awk '{print $5}'`
        let csize/=1000
        if [ $fsize = $csize ]; then
            echo File size Ok. Skipping job $jobid
            echo
            continue
        else
            echo Previous download was not successful. Redownloading..
            mv $fname corrupted.rs
        fi
    fi
    res=nothing

    while [ 1 ]; do
        let tries+=1

        # Get previous time of downloading..
        pretime=`date | awk '{print $4}' | cut -d":" -f3`
        # Check for 0 as first digit
        if [ "`echo $pretime | cut -c1`" = "0" ]; then
            pretime=`echo $pretime | cut -c2`
        fi
        # receive cookie to be able to go to next page
        wget -q --load-cookies=cookie1 --post-data=dl.start=Free $server -O ForCookie2.html
        # Get current time
        curtime=`date | awk '{print $4}' | cut -d":" -f3`
        # Check for 0 as first digit
        if [ "`echo $curtime | cut -c1`" = "0" ]; then
            curtime=`echo $curtime | cut -c2`
        fi
        # error check and store the download duration in curtime
        if [ $curtime -lt $pretime ]; then
            let curtime+=60
        fi
    	# First digit of pretime and curtime cannot be zero
        # echo curtime: "$curtime", pretime: "$pretime"
        let curtime-=$pretime
        if [ $jobid -gt 1 ]; then
            let curtime/=2
        fi

        if [ ! -z "`grep "File Download | Free User" ForCookie2.html`" ]; then
            res=download 
    	    # Download time..
            echo Fetching info page took "$curtime" seconds.
            server=`grep post ForCookie2.html | grep action | sed 's/^.*action=//' | cut -d"\"" -f2 | head -1 | tail -1`

            echo Sending download request to the server $server
            echo
            # Get the waiting time and subtract the wasted time in downloading
            err=0
            countdowntime=`grep "var c" ForCookie2.html | cut -d"=" -f2 | cut -d";" -f1`
            if [ $countdowntime -ge $curtime ]; then
                let countdowntime-=$curtime
            fi

            while [ $err -le $countdowntime ]
            do
                echo -n -e "\rCollecting ticket within `expr $countdowntime - $err` seconds. "
                let err+=1
                sleep 1
            done
            echo -e "\r\t\t\tDownload Window\t"
            echo =============================================================================

            # Never supports resume for free user
            echo job $jobid, download initiated at `date`>>$logfile
            echo download link: $server
            wget $server
            # proz -1 -f -v $server
            echo
            echo =============================================================================
            # To leave this loop must pass the checks
            csize=`ls -l $fname | awk '{print $5}'`
            let csize/=1000
            if [ $fsize = $csize ]; then
                echo File size ok.. [$fsize : $csize]
                echo Download of file $fname, job $jobid was successful.
        		echo $fname job $jobid download completed at `date`
                echo -n "Scheduling next download."
               	if [ $csize -gt 99000 ]; then 
        			err=0
       		        while [ $err -lt 30 ]; do
                    	let err+=1
                   		sleep 1
                   		echo -e -n "\rRetrying in `expr 30 - $err` seconds(s)."
               		done
                    echo
               	fi
                break
            else
                echo File size mis-match.. [$fsize : $csize]
                echo File size mis-matched for $fname \(job ID: $jobid\) rs: $fsize KB, downloaded: $csize KB >> $logfile
                echo Checking for error inside..
                if [ $csize -lt 100 ]; then
                    if [ ! -z "`grep "Your IP address" $fname`" ]; then
                        echo Another user took the slot. Returning to waiting state..
                        rm $fname
                        break;
                    elif [ ! -z "`grep "The download cannot be provided" $fname`" ]; then
                        echo Most probably my count down timer was little bit faster than rapidshare.. curtime: $curtime countdowntime: $countdowntime
                        echo Deleting file $fname
                        rm $fname
                    else
                        echo File size is less than 100 KB. Please check out to track the exact error.
                        echo Not deleting $fname
                    fi

                fi
                echo File will be attempted to download again.
            fi
        elif [ ! -z "`grep "Your IP address" ForCookie2.html`" ]; then
            err=`head -75 ForCookie2.html | tail -1 | cut -d"<" -f2 | cut -d">" -f2`
            if [ $res = "slotbusy" ]; then
                echo -n -e "\r\t\t\t     [ No stot still free ]   "
            else
                echo
                echo www.rapidshare.com says
                echo $err
                err=`head -73 ForCookie2.html | tail -1 | cut -d"<" -f2 | cut -d">" -f2`
                echo -n "$err"
                res=slotbusy
            fi

            # echo -n "No slot is free. Waiting.. "
            err=0
    		# We don't know what file size is being downloaded by another user, so we don't wait long..
            while [ $err -lt 30 ]
            do
                let err+=1
                sleep 1 
                echo -n -e "\r\t\t\tRetrying in `expr 30 - $err` seconds(s). "
            done
            echo -n -e "\r\t\t\t      Checking..\t\t"

            # echo Interrupt
            # wget -q --save-cookies=cookie1 "http://rapidshare.com/files/108235428/war.of.the.worlds-www.darkwarez.pl-Don_Vito.part1.rar" -O ForCookie1.html

            # server=`grep post ForCookie1.html | grep action | sed 's/[^"]*"\([^"]*\).*/\1/' | head -2 | tail -1`
            # wget -q --load-cookies=cookie1 --post-data=dl.start=Free $server -O ForCookie2.html
		    # wget -c "http://rs64l33.rapidshare.com/files/108235428/2331444/war.of.the.worlds-www.darkwarez.pl-Don_Vito.part1.rar"
        elif [ ! -z "`grep "Or try again" ForCookie2.html`" ]; then
            err=`head -72 ForCookie2.html | tail -1 | cut -d"<" -f2 | cut -d">" -f2`
            
            if [ $res = "wait" ]; then
                sleep 1
            else
                echo
                echo www.rapidshare.com says
                echo $err
                res=wait
            fi
		
            err=`head -73 ForCookie2.html | tail -1 | cut -d">" -f4 | cut -d"<" -f1`
            echo -n -e "\r$err\t\t"

            waitMin=`echo $err | sed 's/^.*about //' | cut -d" " -f1`
            # choose the minimum of the waitMin and $interval
            # because sometimes after $interval mins rapidshare forgets
            if [ $waitMin -ge $interval ]
            then
                waitMin=$interval
            fi

            err=0
            # echo err: \($err\), waitMin: \($waitMin\)

            while [ $err -le $waitMin ]
            do
                if [ $waitMin = "1" ]; then
                    sleep 5
                    break
                fi
                let err+=1
                echo -n -e "\rRetrying in `expr $waitMin - $err + 1` /2 Minutes."
                sleep 30
            done
            echo -n -e "\r$err [ Retrying.. ] "
        #	exit 127
        elif [ -z "`grep Error ForCookie2.html`" ]; then
            echo No error reported on page. But page is not known.
        else
            mv ForCookie2.html unknown_error.html 
            echo Could not track \(unknown\) error.
        fi
    done
done

echo All downloads completed successfully. You can renew queue.txt.

## clean up
#rm ForCookie1.html
#rm ForCookie2.html
#rm cookie1
#rm cookie2

#restore
# cd $saveDir


# way 2 of parsing
# server=`grep "method=\"post\"" ForCookie1.html | head -1 | tail -1 | sed 's/^.*action=//'`
# server=`echo $server | cut -d"\"" -f2`

# way 3 of parsing
#server=`grep post ForCookie1.html | tr " " "\n" | grep action | sed 's/[^"]*"\([^"]*\).*/\1/' | head -1 | tail -1`

# head -75 ForCookie2.html | tail -1 | cut -d"<" -f2 | cut -d">" -f2
