#!/bin/bash

fpc -Mtp funcarea.pas > compile 2>> compile
if [ $? == 0 ]
then
	./funcarea
else
	cat compile
fi
rm compile

