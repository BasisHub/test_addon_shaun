[[IVC_TRANCODE.ADIS]]
rem --- Check for Commitment type
	if callpoint!.getColumnData("IVC_TRANCODE.TRANS_TYPE") = "C"
		callpoint!.setColumnData("IVC_TRANCODE.POST_GL","N",1)
		callpoint!.setColumnData("IVC_TRANCODE.GL_ADJ_ACCT","",1)
		callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",0)
	else
		if user_tpl.gl_installed$="Y" then callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",1)
	endif
[[IVC_TRANCODE.AREC]]
	if user_tpl.gl_installed$="Y" then callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",1)
[[IVC_TRANCODE.BDEL]]
rem -- don't allow delete of trans code if it's in use in ive_transhdr

	files=1,begfile=1,endfile=files
	dim files$[files],options$[files],chans$[files],templates$[files]
	files$[1]="IVE_TRANSHDR",options$[1]="OTA"

	call dir_pgm$+"bac_open_tables.bbj",begfile,endfile,files$[all],options$[all],
:                                 chans$[all],templates$[all],table_chans$[all],batch,status$

ive01_dev=num(chans$[1])
k$=""
read (ive01_dev,key=firm_id$+callpoint!.getColumnData("IVC_TRANCODE.TRANS_CODE"),knum="AO_TRANCD_TRNO",dom=*next)
k$=key(ive01_dev,end=*next)
if pos(firm_id$+callpoint!.getColumnData("IVC_TRANCODE.TRANS_CODE")=k$)=1
	dim msg_tokens$[1]
	msg_tokens$[1]=Translate!.getTranslation("AON_THIS_TRANSACTION_CODE_IS_REFERENCED_BY_ONE_OR_MORE_OPEN_TRANSACTION_ENTRIES.")
	msg_id$="IV_NO_DELETE"
	gosub disp_message
	callpoint!.setStatus("ABORT")
endif

rem --- now close trans hdr file to avoid err 0 if someone tries to run register
	files=1,begfile=1,endfile=files
	dim files$[files],options$[files],chans$[files],templates$[files]
	files$[1]="IVE_TRANSHDR",options$[1]="C"

	call dir_pgm$+"bac_open_tables.bbj",begfile,endfile,files$[all],options$[all],
:                                 chans$[all],templates$[all],table_chans$[all],batch,status$


[[IVC_TRANCODE.TRANS_TYPE.AVAL]]
rem --- Check for Commitment type
	if callpoint!.getColumnData("IVC_TRANCODE.TRANS_TYPE") = "C"
		callpoint!.setColumnData("IVC_TRANCODE.POST_GL","N",1)
		callpoint!.setColumnData("IVC_TRANCODE.GL_ADJ_ACCT","",1)
		callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",0)
		callpoint!.setColumnEnabled("IVC_TRANCODE.GL_ADJ_ACCT",0)
	else
		if user_tpl.gl_installed$="Y" then callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",1)
	endif
[[IVC_TRANCODE.BWRI]]
rem --- Check for blank Trans Type
	if cvs(callpoint!.getColumnData("IVC_TRANCODE.TRANS_TYPE"),2) = "" then
		msg_id$="INVALID_TRANS_TYPE"
		gosub disp_message
		callpoint!.setStatus("ABORT")
	endif
rem --- Check for G/L Number if Post to G/L is up
	if callpoint!.getColumnData("IVC_TRANCODE.POST_GL") = "Y" then
		if cvs(callpoint!.getColumnData("IVC_TRANCODE.GL_ADJ_ACCT"),2) = "" then
			msg_id$ = "IV_NEED_GL_ACCT"
			gosub disp_message
			callpoint!.setStatus("ABORT")
		endif
	endif
[[IVC_TRANCODE.<CUSTOM>]]
#include std_missing_params.src
[[IVC_TRANCODE.BSHO]]
rem --- Open/Lock Files
	files=1,begfile=1,endfile=files
	dim files$[files],options$[files],chans$[files],templates$[files]
	files$[1]="IVS_PARAMS",options$[1]="OTA"

	call dir_pgm$+"bac_open_tables.bbj",begfile,endfile,files$[all],options$[all],
:                                 chans$[all],templates$[all],table_chans$[all],batch,status$
	if status$<>"" then
		remove_process_bar:
		bbjAPI!=bbjAPI()
		rdFuncSpace!=bbjAPI!.getGroupNamespace()
		rdFuncSpace!.setValue("+build_task","OFF")
		release
	endif
	ivs01_dev=num(chans$[1])
			
	rem --- Dimension miscellaneous string templates
			
	dim ivs01a$:templates$[1]
			
rem --- init/parameters
			
	ivs01a_key$=firm_id$+"IV00"
	find record (ivs01_dev,key=ivs01a_key$,err=std_missing_params) ivs01a$
rem --- check if GL is installed
	call stbl("+DIR_PGM")+"adc_application.aon","GL",info$[all]
	gl$=info$[20];rem --- gl installed?
	dim user_tpl$:"gl_installed:c(1)"
	user_tpl.gl_installed$=gl$
	if gl$<>"Y" then callpoint!.setColumnEnabled("IVC_TRANCODE.POST_GL",-1)
