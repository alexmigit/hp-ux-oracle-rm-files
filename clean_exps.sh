#!/bin/ksh
###########################################################################################################
# Copyright (c) 2018 - Alex Migit - All Rights Reserved.
#	NAME   - clean_exps.sh
#
#	VER    - 1.6
#
#	USAGE  - clean_exps.sh
#	RUN AS - oracle user in HP-UX
#
#	PURPOSE:
#		The purpose of this shell script is to remove export dump files and associated output files in
#               The /exports directory that are equal to or older than 14 days
#               The files to remove are: *.dmp, *.log, *.lst, *.buf, *.gz
#               The files to omit are: < 14 days old
#               There will be no files deleted from this directories: /donotdelete, /donotdel
#               This script recursively descends executed directory hierarchy to find and remove dump, log, etc. files
#
#	I/O
#		Parms 	     : N/A
#
#		Input Files  : N/A
#
#		Output Files : N/A
#
#
#  NOTES:
#        1. Common Reference for find command
#        find [-H|-L] pathname list [expression]
#             -atime n: True if the file access time subtracted from initialization time is n-1 to n multiples of 24 hours.
#             -mtime n: True if the file modification time subtracted from initialization time is n-1 to n multiples of 24 hours.
#             -ctime n: True is the time of last change of file status information subtracted from initialization time is n-1 to n multiples of 24 hours.
#
#  MODIFICATION LOG
#  VER    WHO  MM/DD/YY
#  1.0    APM  10/20/17 - Initial Creation.
#  1.1    APM  11/13/17 - Updated to exclude specified directories, use double quote formatting, and add force remove option to avoid 644 mode user input
#  1.2    APM  01/31/18 - Added exclude paths strings
#  1.3	  APM  02/26/18 - Removed *.par from rm, and updating to kick out rm executions
#  1.4    APM  03/09/18 - Increased -mtime from +7 to +14, and changed file name
#  1.5    APM  03/19/18 - Updated find path to avoid stat error (i.e. removed /usr/bin)
#  1.6    APM  04/10/18 - Set environment variables
#
###########################################################################################################
#set -x

. ora11gsetup
. $BU/shrsec.sh
#. $BU/shrfuncs.sh

###########################################################################################################
# Initialize variables
###########################################################################################################
export rpt_time=`date +%Y_%m_%d_%H%M`
export EXP_DIR="/exports"
#. /app/oracle/local/bin/ora11gr2setup
#. /app/oracle/local/bin/dbasetup
#MAIL_LIST="<YOUREMAIL>"
OUTPUT=/app/oracle/UTILS/MAINT/cron_exps_rm/outputs
#RETURNSENDER="<YOUREMAIL>"
#RETURNSENDER="<YOUREMAIL>"

###########################################################################################################
# Create *.lst output file of /exports files to be removed
###########################################################################################################
list=$(cat <<eof
/exports/
eof
)

for i in $list
  do
     find $list ! \( -path "*donotdel*" -o -path "*partion*" \) \
     -type f \( -name "*.dmp" -o -name "*.log" -o -name "*.lst" -o -name "*.buf" -o -name "*.gz" \) -mtime +14 -exec ls -l {} \; \
     > ${OUTPUT}/rm_exps_fls_`date '+%Y%m%d'`.lst
  done

###########################################################################################################
# Send an email of files that will be deleted
###########################################################################################################
#vSubject="Exports Files Removed on `date  +%m/%d/%y-%r`"
#if [ -e ${OUTPUT}/rm_exps_fls.lst ]
#then
#   cat ${OUTPUT}/rm_exps_fls.lst >> ${OUTPUT}/rm_exps_fls.txt
#   cat ${OUTPUT}/rm_exps_fls.txt | /usr/sbin/sendmail -vtr ${RETURNSENDER}
#fi

###########################################################################################################
# Delete files from <server>:/exports directory
###########################################################################################################
find /exports ! \( -path "*donotdel*" -o -path "*partion*" \) \
-type f \( -name "*.dmp" -o -name "*.log" -o -name "*.lst" -o -name "*.buf" -o -name "*.gz" \) -mtime +14 \
-exec rm -f {} \;

#exit 0
