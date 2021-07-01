@echo off

SET 

PACKAGE=sustechthesis
SET THESIS=sustechthesis-example
SET 
SOURCES=$(PACKAGE).ins $(PACKAGE).dtx
SET CLSFILE=dtx-style.sty $(PACKAGE).cls
SET 
LATEXMK=latexmk
SET 	RM=del \Q
SET else
	RM=rm -f

IF /I "%1"=="SHELL  " GOTO SHELL  
IF /I "%1"=="thesis" GOTO thesis
IF /I "%1"=="all" GOTO all
IF /I "%1"=="all-dev" GOTO all-dev
IF /I "%1"=="cls" GOTO cls
IF /I "%1"=="$(CLSFILE)" GOTO $(CLSFILE)
IF /I "%1"=="doc" GOTO doc
IF /I "%1"=="$(PACKAGE).pdf" GOTO $(PACKAGE).pdf
IF /I "%1"=="$(THESIS).pdf" GOTO $(THESIS).pdf
IF /I "%1"=="viewdoc" GOTO viewdoc
IF /I "%1"=="viewthesis" GOTO viewthesis
IF /I "%1"=="test" GOTO test
IF /I "%1"=="clean" GOTO clean
IF /I "%1"=="cleanall" GOTO cleanall
IF /I "%1"=="distclean" GOTO distclean
IF /I "%1"=="wordcount " GOTO wordcount 
IF /I "%1"=="" GOTO all
GOTO error

:SHELL  
	CALL make.bat =
	CALL make.bat /bin/bash
	GOTO :EOF

:thesis
	CALL make.bat $(THESIS).pdf
	GOTO :EOF

:all
	CALL make.bat thesis
	GOTO :EOF

:all-dev
	CALL make.bat doc
	CALL make.bat all
	GOTO :EOF

:cls
	CALL make.bat $(CLSFILE)
	GOTO :EOF

:$(CLSFILE)
	CALL make.bat $(SOURCES)
	xetex %PACKAGE%.ins
	GOTO :EOF

:doc
	CALL make.bat $(PACKAGE).pdf
	GOTO :EOF

:$(PACKAGE).pdf
	CALL make.bat cls
	CALL make.bat FORCE_MAKE
	%LATEXMK% %PACKAGE%.dtx
	GOTO :EOF

:$(THESIS).pdf
	CALL make.bat cls
	CALL make.bat FORCE_MAKE
	%LATEXMK% %THESIS%
	GOTO :EOF

:viewdoc
	CALL make.bat doc
	%LATEXMK% -pv %PACKAGE%.dtx
	GOTO :EOF

:viewthesis
	CALL make.bat thesis
	%LATEXMK% -pv %THESIS%
	GOTO :EOF

:test
	CALL make.bat cls
	CALL make.bat FORCE_MAKE
	bash test/test.sh
	GOTO :EOF

:clean
	%LATEXMK% -c %PACKAGE%.dtx %THESIS%
	-@%RM% -rf *~ main-survey.* main-translation.* _markdown_sustechthesis* sustechthesis.markdown.* _markdown_thuthesis* thuthesis.markdown.*
	GOTO :EOF

:cleanall
	CALL make.bat clean
	-@%RM% -rf public-test
	-@%RM% %PACKAGE%.pdf %THESIS%.pdf
	GOTO :EOF

:distclean
	CALL make.bat cleanall
	-@%RM% %CLSFILE%
	-@%RM% -r dist
	GOTO :EOF

:wordcount 
	CALL make.bat $(THESIS).tex
	@if grep -v ^% $< | grep -q '\\documentclass\[[^\[]*english'; then texcount $< -inc -char-only | awk '/total/ {getline; print "英文字符数\t\t\t:",$$4}'; else texcount $< -inc -ch-only   | awk '/total/ {getline; print "纯中文字数\t\t\t:",$$4}'; fi
	GOTO :EOF

:error
    IF "%1"=="" (
        ECHO make: *** No targets specified and no makefile found.  Stop.
    ) ELSE (
        ECHO make: *** No rule to make target '%1%'. Stop.
    )
    GOTO :EOF
