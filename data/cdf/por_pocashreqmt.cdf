[[POR_POCASHREQMT.ASVA]]
aging_date$=callpoint!.getColumnData("POR_POCASHREQMT.AGING_DATE")
aging_date=1
			
if cvs(aging_date$,2)<>""
	aging_date=0
	aging_date=jul(num(aging_date$(1,4)),num(aging_date$(5,2)),num(aging_date$(7,2)),err=*next)
endif
			
if len(cvs(aging_date$,2))<>8 or aging_date=0
	msg_id$="INVALID_DATE"
	dim msg_tokens$[1]
	msg_opt$=""
	gosub disp_message
	callpoint!.setStatus("ABORT")
endif
