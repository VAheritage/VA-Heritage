#!/bin/sh
HERE=$(dirname $0)

# path to the schema xsl file:
XSL=$HERE/dtd2schema.vh.xsl

# output files destination path:
OUTBASE=/projects/pub-schema

# path of xalan jar ( for fallback when xsltproc fails. ):
XALAN=/usr/local/java/xalan-j_2_7_1/xalan.jar

# path to xinclude files:
ADD_CON=/projects/vivaead/add_con

# below are the exceptions that use a different include file from the default.
NOTX="lva/vi01901.xml lva/vi01902.xml wm/viw00110.xml"

for XML in $*
do
	XDIR=$(basename $(dirname $XML ))
	XFILE=$(basename $XML)
	OUT=$OUTBASE/$XDIR/$XFILE
	NOXINCL=false
	for X in $NOTX 
	do
	  if [ "$X" == "$XDIR/$XFILE" ] 
	  then
	  	NOXINCL=true
	  	echo "Skipping XInclude on $X" 
	  fi
	done
	if ! $NOXINCL 
	then
	  if [ -e ${ADD_CON}/${XDIR}_contact.xml ]  
	  then INST="--stringparam inst $XDIR "
	  echo "XInclude:  $INST"
	  fi
	fi

		
	if head $XML | grep 'urn:isbn:1-931666-22-9' 
	then

	  # already schema based -- just copy to OUT
	  cp -v $XML $OUT
	
	elif  head $XML | egrep '<!DOCTYPE '
    then
	
      if xsltproc  --output $OUT $INST $XSL  $XML
      then
       	echo "# xsltproc --output $OUT $INST $XSL $XML" 
      else 
         echo "# xsltproc error - fallback xalan: -IN $XML -XSL $XSL -OUT $OUT ${INST/--stringparam/-PARAM} " 
         java -jar $XALAN  -IN $XML -XSL $XSL -OUT $OUT ${INST/--stringparam/-PARAM} 
      fi

	else 
    	echo '# BADERROR: no <!DOCTYPE and no NAMESPACE' 
	fi
done 2>&1 