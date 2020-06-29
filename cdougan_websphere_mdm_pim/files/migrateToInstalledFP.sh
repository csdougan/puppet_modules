BM Confidential
# OCO Source Materials
# 5724-V51
#
# (c) Copyright IBM Corp. 2000, 2014 All Rights Reserved.
#
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

# Please consult InfoSphere MDM Server for PIM Support before attempting to use this script
top=`perl $PERL5LIB/getTop.pl`
pwd=`perl $PERL5LIB/getDBPasswordFromConfig.pl`
source $top/bin/compat.sh

if [ -z "$TOP" -o ! -r "$TOP" ]; then
   ${ECHO} TOP variable not defined
   exit 1
fi

. ${TOP}/bin/get_params.sh

printUsage()
{
    perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_USAGE_SH
    ${ECHO} $0" --fromversion=<fromversion> --dbpassword=<Database password>"
    perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_EXAMPLE_SH
    ${ECHO} $0" --fromversion=BASE, FP1, FP2, FP3, FP4, FP5 --dbpassword=password"
    ${ECHO}
}

if [[ $# -lt 1 ]]
then
        printUsage
        exit 0
fi

FROMVERSION=`${ECHO} $1 |${CUT} -d "=" -f2`;export FROMVERSION
FROMVERSION=`${ECHO} ${FROMVERSION}| ${TR} 'abcdefghijklmnopqrstuvwxyz' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'`
export FROMVERSION

if [ "${FROMVERSION}" != "BASE" ] && \
        [ "${FROMVERSION}" != "FP1" ] && \
        [ "${FROMVERSION}" != "FP2" ] && \
        [ "${FROMVERSION}" != "FP3" ] && \
        [ "${FROMVERSION}" != "FP4" ] && \
        [ "${FROMVERSION}" != "FP5" ]; then
                ${ECHO} "WRONG fromversion"
                printUsage
                exit 0
fi

if [ "${pwd}" = "" ]; then
if [ "${_CCD_DBPASSWORD}" = "" ]; then
    printUsage
    perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_PROMPT_DB_PASSWORD_SH
    pwd=`perl $PERL5LIB/getDBPassword.pl`
    if [ "${pwd}" = "" ]; then
        ${ECHO}
        perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_NO_DB_PASSWORD_SH
        ${ECHO}
        exit 0
    fi
else
    pwd=${_CCD_DBPASSWORD}
fi
fi

${ECHO}
${ECHO} "********************************************************"
${ECHO} "********************************************************"
${ECHO} "**"
perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_MIGRATE_SCHEMA_SH
${ECHO}
perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_BACKUP_DB_WARNING_SH
${ECHO}
${ECHO} "**"
${ECHO} "********************************************************"
${ECHO} "********************************************************"
${ECHO}

#perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_ISCONTINUE_SH
#read res
#if [ ! "$res" = "y" ]; then
#        perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_NOCONTINUE_SH
#        ${ECHO}
#    exit
#fi

DB_CMN_SCRIPTS="$DB_DIR/dbscripts/common"
if [ ${CCD_DB} == "db2" ]; then
        DB_SCRIPTS="$DB_DIR/dbscripts/db2"
else
        DB_SCRIPTS="$DB_DIR/dbscripts/oracle"
fi

_ERROR_LOGS=$TOP/logs/errfile.log
${ECHO} " " > $_ERROR_LOGS
_VERIFY_SQL=${DB_SCRIPTS}/verifyMigration.sql
${ECHO} " " > $_VERIFY_SQL
_VERIFY_LOG=$TOP/logs/verify.log
`${RM} $_VERIFY_LOG `
_REFERENCE=$TOP/bin/migration/reference.file
${ECHO} " " > $_REFERENCE
_VERIFY_SCRIPT=$TOP/bin/migration/verify.pl
${ECHO} " " > $_VERIFY_SCRIPT
_GDS_PERL=$TOP/bin/migration/gds_perl.pl
${ECHO} " " > $_GDS_PERL
_TEMP_SQL=$TOP/logs/temp.sql
_TEMP_LOG=$TOP/logs/temp.log

sqlfile=$DB_CMN_SCRIPTS/get_cmpcode.sql
COMPANIES=`perl $PERL5LIB/runSQL.pl --dbpassword=${pwd} --sql_file=$sqlfile`
ERROR_MSG=""
count=0;
gdsEnabled="no"

isGdsEnabled()
{
        ${ECHO} "use Pim::EnvConfig;" >> $_GDS_PERL
        ${ECHO} "my \$envConfig = new Pim::EnvConfig();" >> $_GDS_PERL
        ${ECHO} "my \$isGDSEnabled = lc \$envConfig->isGDSEnabled();" >> $_GDS_PERL
        ${ECHO} "@out=\"\$isGDSEnabled\n\";" >> $_GDS_PERL
        ${ECHO} "print \"@out\";" >> $_GDS_PERL
        gdsEnabled=`perl $_GDS_PERL`
        if [ "$gdsEnabled" == "yes" ]; then
                ${ECHO} "GDS is enabled. GDS privileges will now be loaded."
 #               perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_ISCONTINUE_SH
                #read res
                #if [ ! "$res" == "y" ]; then
                 #       gdsEnabled="no"
                #fi
        fi
}

getErrorCountInLogFile()
{
    if [ ! -f $_ERROR_LOGS ]; then
        errorCount=0
    else
        errorCount=`${CAT} $_ERROR_LOGS | wc -c`
    fi
}

DoStartAndPrepare()
{
    ${ECHO}
    perl $PERL5LIB/getLocalizedMessage.pl --key=$1
    ${ECHO} $2
    ${ECHO}

    getErrorCountInLogFile
    initial=$errorCount
}

DoEndAndReportError()
{

    getErrorCountInLogFile
    final=$errorCount

    if [ ! $initial -eq $final ]; then

        ${ECHO} "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        perl $PERL5LIB/getLocalizedMessage.pl --key=$1
        ${ECHO} $3
        ${ECHO} "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_CHECK_ERROR_LOG_FILE_SH
        ${ECHO} $_ERROR_LOGS
        ERROR_MSG=$ERROR_MSG$3", "

    else
        ${ECHO} ""
        ${ECHO} "-----------------------------------------"
        perl $PERL5LIB/getLocalizedMessage.pl --key=$2
        ${ECHO} $3
        ${ECHO} "-----------------------------------------"
        fi

}

updateRichSearchResultsScript()
{
    DoStartAndPrepare "COMMON_INFO_UPDATING_SH" "updateRichSearchResultsScript"

    for CMP_CODE_COL in $COMPANIES;
    do
    CMP_CODE=`${ECHO} ${CMP_CODE_COL} | ${GREP} 'cmpcode%' | ${CUT} -f2 -d "%"`
    if [ "$CMP_CODE" != "" ]; then
        ${ECHO} "COMPANY_CODE $CMP_CODE"
        #updateRichSearchResultsScript
        ${JAVA_RT} com.ibm.ccd.docstore.util.DocLoader "$CMP_CODE" Admin $TOP/src/db/scripts/common/report_scripts.xml Cp1252 2>/dev/null
    fi
    done

    DoEndAndReportError  "COMMON_INFO_FAILED_SH" "COMMON_INFO_SUCCEEDED_SH" "updateRichSearchResultsScript"
}

updateLdapLogin()
{
        DoStartAndPrepare "COMMON_INFO_UPDATING_SH" "updateLdapLogin"
        for CMP_CODE_COL in $COMPANIES;
        do
                CMP_CODE=`${ECHO} ${CMP_CODE_COL} | ${GREP} 'cmpcode%' | ${CUT} -f2 -d "%"`
                if [ "$CMP_CODE" != "" ]; then
                        ${ECHO} "COMPANY_CODE $CMP_CODE"
                        ${JAVA_RT} com.ibm.ccd.docstore.common.DocStoreMgr -company_code="$CMP_CODE" -op=upload -path1=$TOP/src/db/scripts/common/user_authentication/Login.script -path2=/scripts/login/Login.wpcs  2>/dev/null
                fi
        done
        DoEndAndReportError  "COMMON_INFO_FAILED_SH" "COMMON_INFO_SUCCEEDED_SH" "updateLdapLogin"
}
#------------------------------------------------------------------------------------
#Before adding new FP migration, first modify printUsage and FROMVERSION if condition
#------------------------------------------------------------------------------------




FP5()
{
        updateRichSearchResultsScript
        updateLdapLogin
}

FP4()
{
        FP5
}

FP3()
{
        FP4
}

FP2()
{
        FP3
}

FP1()
{
        FP2
}

BASE()
{
        FP1
}

 ${FROMVERSION}

#
# Verification step
#

perl $PERL5LIB/runSQL.pl --dbpassword=${pwd} --sql_file=$_VERIFY_SQL >> $_VERIFY_LOG

${ECHO} "use Carp;" >> $_VERIFY_SCRIPT
${ECHO} "use Pim::Localizer;" >> $_VERIFY_SCRIPT
${ECHO} "my \$localizer = Pim::Localizer->new();" >> $_VERIFY_SCRIPT
${ECHO} "my \$sqlFile = \"$_VERIFY_LOG\";" >> $_VERIFY_SCRIPT
${ECHO} "open SQL, \"<\", \"\$sqlFile\" or croak \"Cannot open \$sqlFile for read: \$!\";" >> $_VERIFY_SCRIPT
${ECHO} "my \$refFile = \"$_REFERENCE\";" >> $_VERIFY_SCRIPT
${ECHO} "open my \$REF, \"<\", \"\$refFile\" or croak \"Cannot open \$refFile for read: \$!\";" >> $_VERIFY_SCRIPT
${ECHO} "my @sqlIn = (<SQL>);" >> $_VERIFY_SCRIPT
${ECHO} "close SQL;" >> $_VERIFY_SCRIPT
${ECHO} "chomp(@sqlIn);" >> $_VERIFY_SCRIPT
${ECHO} "my \$ret=\"1\";" >> $_VERIFY_SCRIPT
${ECHO} "my @out = ();" >> $_VERIFY_SCRIPT
${ECHO} "seek \$REF,0,0;" >> $_VERIFY_SCRIPT
${ECHO} "while (<\$REF>) {" >> $_VERIFY_SCRIPT
${ECHO} "\$_ =~ s/$+\s//;" >> $_VERIFY_SCRIPT
${ECHO} "\$_ =~ s/\s+$//;" >> $_VERIFY_SCRIPT
${ECHO} "my \$str = \$_;" >> $_VERIFY_SCRIPT
${ECHO} "if (!grep {/\$str/} @sqlIn) {" >> $_VERIFY_SCRIPT
${ECHO} "@out=\"\$str\n\";" >> $_VERIFY_SCRIPT
${ECHO} "print \"@out\";" >> $_VERIFY_SCRIPT
${ECHO} "\$ret=\"0\";" >> $_VERIFY_SCRIPT
${ECHO} "last;" >> $_VERIFY_SCRIPT
${ECHO} "}" >> $_VERIFY_SCRIPT
${ECHO} "}" >> $_VERIFY_SCRIPT
${ECHO} "if (\$ret eq \"1\") {" >> $_VERIFY_SCRIPT
${ECHO} "@out=\"\";" >> $_VERIFY_SCRIPT
${ECHO} "print \"@out\";" >> $_VERIFY_SCRIPT
${ECHO} "}" >> $_VERIFY_SCRIPT
${ECHO} "close \$REF;" >> $_VERIFY_SCRIPT

msg=`perl $_VERIFY_SCRIPT`
ERROR_MSG=$ERROR_MSG$msg

${ECHO}
${ECHO}
${ECHO} "-----------------------------------------------------------"
perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_SUMMARY_OF_MIGRATION_SH
${ECHO}
${ECHO} "-----------------------------------------------------------"
if [ "$ERROR_MSG" != "" ]; then
perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_MIGRATION_OF_MODULES_FAILED_SH
${ECHO}
${ECHO} $ERROR_MSG
else
perl $PERL5LIB/getLocalizedMessage.pl --key=COMMON_INFO_MIGRATION_SUCCESS_SH
`${RM} $_VERIFY_SQL `
`${RM} $_REFERENCE `
`${RM} $_VERIFY_SCRIPT `
`${RM} $_TEMP_LOG `
`${RM} $_TEMP_SQL `
`${RM} $_GDS_PERL `
${ECHO}
${ECHO} "Generating database verification report..."
${JAVA_RT} com.ibm.ccd.common.util.SystemDB
fi

