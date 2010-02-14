#!/bin/bash

fpc -D FPC funcarea.pas > compile 2>> compile
if [ $? == 0 ]
then
	./funcarea
else
	cat compile
fi
rm compile

