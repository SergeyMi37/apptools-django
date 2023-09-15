/// Utilities for working in Telegram
Class apptools.core.telebot [ Abstract ]
{

/// Global Name Store Referens
Parameter GN = "^%apptools.ref";

/// Get base responce
ClassMethod GetResp(arg = "") As %String
{
	set js={}
	set js.status="ok"
	set js.instance = $ZU(86)
	set js.version=$zv
	set:arg'="" js.django={}.%FromJSON(arg)   //"AnonymousUser"
	quit js
}

/// TimeStamp
/// w ##class(apptools.core.telebot).TS(,.json)
ClassMethod TS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	set js.datetime= $ZDT($NOW()+0,3,1,3)_" "_##class(apptools.core.type).GetValidZT($h)
	set js.zts= $zts
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Alerts Systems
/// w ##class(apptools.core.telebot).Alerts(,.json)
ClassMethod Alerts(arg = "", js = "") As %String
{
	set js=..GetResp(arg)
	do ##class(apptools.core.rest).GetAlertsSys(,.js,0)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Status Systems
ClassMethod SS(arg = "", js) As %String
{
	set js=..GetResp(arg)
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Footer
/// w ##class(apptools.core.telebot).GetFooter("")
ClassMethod GetFooter(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		if 'js.django.authenticated quit 
		do ##class(apptools.core.net).GetURI(.prop)
		do ##class(apptools.lte.info).GetTopMenuFavorites(.opt,$lb("1","name"))	
		;set ip=##class(apptools.core.net).GetIP()
		;set js.ip=ip
		set js.host=$zu(110)
		set js.webport=$g(prop("WebServerPort"))
		set js.apps = []
		set uri=js.django.absoluteuri ;request.build_absolute_uri()
		if js.django.irishost="iris",js.django.irisport="1972",##class(apptools.core.files).ReadFile("/irisdev/app/docker-compose.yml",.txt,1) { 	// if we are in the docker, then we will find the port   
			set port=$p($p(txt,":52773")," ",*)
			if port="" set port=52773
			set uri=$p(uri,":",1,2)_":"_port
		}
		elseif js.django.irishost'="iris" {
			set uri="http://"_js.django.irishost_":"_prop("WebServerPort")
		}
		set i=""
		for { set i=$o(opt(i)) quit:i=""
			set app={}
			set app.name=opt(i,"TabName")
			set app.url=uri_opt(i,"InFrameUrl")
			do js.apps.%Push(app)
		}
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// Get Info for Managment Portal
/// w ##class(apptools.core.telebot).GetPortal("",.js)
ClassMethod GetPortal(arg = "", js) As %String
{
	set js=..GetResp(arg)
	try {
		if 'js.django.authenticated quit 
		set gn="^||tmp"
		set %Param=js.django.arg
		if %Param["iditem=" {
			set iditem=$p(%Param,"iditem=",2)
			set data=##class(apptools.core.telebot).AddIdItem(,,iditem)
			set method=$lg(data,1),id=$lg(data,2)
			set js.title=" by "_method_", " _id
			set js.draw="Form for "_%Param
			quit
		}
		set js.prod={}
		set js.prod.count=##class(apptools.core.telebot).GetPortalProd(0,gn)

		set js.proc={}
		set js.proc.count=##class(apptools.core.telebot).GetPortalProc(1,gn)

		set js.lock={}
		set js.lock.count=##class(apptools.core.telebot).GetPortalLock(1,gn)

		set js.db={}
		set js.db.count=##class(apptools.core.telebot).GetPortalNS(1,gn,"Databases")

		set js.ns={}
		set js.ns.count=##class(apptools.core.telebot).GetPortalNS(1,gn,"Namespaces")

		set js.alerts={}
		do ##class(%SYSTEM.Monitor).GetAlerts(,.str,.last)
		set st=$o(str(""),-1)
		set js.alerts.count=+st
		kill @gn
		if %Param["Namespaces" {
			do ##class(apptools.core.telebot).GetPortalNS(0,gn,"Namespaces"," ")
		}
		elseif %Param["Databases" {
			do ##class(apptools.core.telebot).GetPortalNS(0,gn,"Databases"," ")
		}
		elseif %Param["Process" {
			do ##class(apptools.core.telebot).GetPortalProc(0,gn)
		}
		elseif %Param["Products" {
			do ##class(apptools.core.telebot).GetPortalProd(1,gn)
		}
		elseif %Param["Locktab" {
			do ##class(apptools.core.telebot).GetPortalLock(0,gn)
		}
		elseif %Param["Alerts" {
			set i=""
			do ##class(apptools.core.sys).SetTableHeader(gn,"DataTime","PID","Level","Messages")
			for { set i=$o(str(i)) quit:i=""
				do ##class(apptools.core.sys).SetTableRow(gn,i,$p(str(i)," ",1),$p(str(i)," ",2),$p(str(i)," ",3),$p(str(i)," ",4,*))
			}
			do ##class(apptools.core.sys).SetTableFooter(gn)
			set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gn_""",10000,$zu(5),"" "",,,"""")"
			do ##class(apptools.core.sys).Run2Spool(run,gn)
		}
		set out=$g(@gn)
		set js.draw=$p(out,("</table>"),1)_"</table>"
	}
	catch e { 
		set js.status="error "_$ze
	}
	quit ##class(apptools.util.json).ZPretty(js,"","")
}

/// w ##class(apptools.core.telebot).GetPortalLock(1,"^||tmpL")
ClassMethod GetPortalLock(count, gn) As %String
{
	new $namespace
	set $namespace= "%SYS" 
	do ##class(apptools.core.sys).SaveQueryTab("%SYS.LockQuery:List",gn)
	set %AppLogInfoTemp("colomn")="DelKey",%AppLogInfoTemp("method")="Locktab"
	set %exec="##class(apptools.core.telebot).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gn_""",10000,$zu(5),"" "",%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn,,.counts)
	if count {
		quit +$g(counts)
	}
	quit 0
}

/// do ##class(apptools.core.telebot).GetPortalProd(1,"^tmpNSoutpot"," ")
ClassMethod GetPortalProd(count, gn, %Param = " ") As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count=0 {
		quit ..GetPortalProds(0)
	}
	d ..GetPortalProds(1,gn)
	set %AppLogInfoTemp("colomn")="NameSpace____ProductName",%AppLogInfoTemp("method")="Products"
	set %exec="##class(apptools.core.telebot).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(""r "_gn_""",10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// do ##class(apptools.core.telebot).GetPortalProds(1,"^tmpNSoutpot"," ")
ClassMethod GetPortalProds(count, gn, %Param = " ") As %String
{
	new $namespace
	set listns=##class(apptools.core.sys).ListNS(.inf,"NotPref,Ens")
		;do ##class(apptools.core.Production).EnsAction("info",,.out)
		set i="",coun=0
		do:count ##class(apptools.core.sys).SetTableHeader(gn,"NameSpace____ProductName","Status")
		for { set i=$o(inf(i)) quit:i=""
			if $d(inf(i,"Ens")) {
				set $namespace= i
				set p=""
				for { set p=$o(inf(i,"Ens",p)) quit:p=""
					set coun=coun+1
					if count {
						Set sc = ##class(Ens.Director).GetProductionStatus(p,.Stat)
						s stat=$s(Stat=1:"Running",Stat=2:"Stopped",Stat=3:"Suspended",Stat=4:"Troubled",1:"?")
						if stat="Running" set stat="<b>"_stat_"</b>"
						do ##class(apptools.core.sys).SetTableRow(gn,coun,i_"____"_p,stat)
						
					}
				}
			}
		}
		do:count ##class(apptools.core.sys).SetTableFooter(gn)
	quit coun
}

/// do ##class(apptools.core.telebot).GetPortalProc(1,"^tmpNSoutpot","Namespaces"," ")
ClassMethod GetPortalProc(count, gn, SectionHeader = "Namespaces", %Param = " ") As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count {
		set %sql="select count(*) from %SYS.ProcessQuery"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		;set %sql="select Pid,NameSpace, Routine, CPUTime,LinesExecuted,CurrentLineAndRoutine,GlobalReferences,LastGlobalReference, State,PidExternal,UserName,ClientIPAddress,ClientNodeName,CurrentDevice,ClientExecutableName,MemoryAllocated,MemoryUsed,	OpenDevices,CSPSessionID, InTransaction,LicenseUserId,Priority,Roles from %SYS.ProcessQuery"
		set %sql="select Pid,NameSpace, Routine, CPUTime,LinesExecuted,CurrentLineAndRoutine,GlobalReferences, State,UserName from %SYS.ProcessQuery"
	}
	set %AppLogInfoTemp("colomn")="Pid",%AppLogInfoTemp("method")="Process"
	set %exec="##class(apptools.core.telebot).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(%sql,10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// Procedure for ##class(apptools.core.telebot).AddUrl
ClassMethod AddUrl(Val, Col, Head, Temp, Del = 0) As %String
{
	set res=Val
	if $g(Head) {
		i $g(Val)=$g(Temp("colomn")) s Temp($g(Temp("colomn")),Col)=""
	}
	else {
		if $D(Temp($g(Temp("colomn")),Col)) {
			set item=..AddIdItem($g(Temp("method")),Val)
			set res="<a target=mp_item title='Go to Items panel' href='/iris_mp_item?iditem="_item_"' >"_Val_"</a>"
		}
	}
	quit res
}

/// Procedure for ##class(apptools.core.telebot).AddIdItem("temp",123)
ClassMethod AddIdItem(method = "", id = "", iditem = "") As %String
{
	set gn=$na(@..#GN@(+$h))
	set gnn=$na(@..#GN@($h-1))
	if $d(@gnn) KILL @gnn set @gn=+$h
	if '$d(@gn) set @gn=+$h ;init node new day
	if iditem, $d(@gn@(iditem),data) quit data
	set item=$i(@gn)
	set @gn@(item)=$lb(method,id)
	quit item
}

/// do ##class(apptools.core.telebot).GetPortalNS(1,"^tmpNSoutpot","Namespaces"," ")
ClassMethod GetPortalNS(count, gn, SectionHeader = "Namespaces", %Param = "") As %String
{
	new $namespace
	set $namespace= "%SYS" 
	if count {
		set %sql="select count(*) from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
		do ##class(apptools.core.sys).sql2gn(%sql,"",gn)
		quit +$lg($g(@gn@(1)))
	}
	else { 
		set tabs=""
		if SectionHeader = "Namespaces" set tabs=",Routines ,SysGlobals,SysRoutines,TempGlobals"
		set %sql="select Name, Globals"_tabs_" from Config.Namespaces where SectionHeader = '"_SectionHeader_"'"
	}
	set %AppLogInfoTemp("colomn")="Name",%AppLogInfoTemp("method")=SectionHeader
	set %exec="##class(apptools.core.telebot).AddUrl(.%AppLogInfoVal, .%AppLogInfoCol, .%AppLogInfoHead, .%AppLogInfoTemp)"
	set run="set st=##class(apptools.core.LogInfoPane).DrawSQL(%sql,10000,$zu(5),%Param,%exec,,"""")"
	do ##class(apptools.core.sys).Run2Spool(run,gn)
	quit 0
}

/// Get info from telebot
ClassMethod GetMe(botId) As %DynamicObject
{
	s ret=..ExecuteRequest(..GetRequestObj(), "getMe",botId)
	q ret
}

/// $wc($zhex("1F6A8"))	;U+0038 U+20E3 =8;  U+0031 U+20E3 =1 ;* U+2744 snow  X - $wc($zhex("274C"))  ;https://apps.timwhitlock.info/emoji/tables/unicode
/// w ##class(apptools.core.telebot).Send(5111112,"13333333:AHEАWAASDDDpepSSAA","Not recognized !!! Пример кириллицы "_$wc($zhex("1F6A8")))
ClassMethod Send(chatId As %String, botId, text As %String, obj = 0) As %Integer
{
	if (obj'=0) {
		;set obj = {"remove_keyboard":true}
		set res = ..SendMessage(chatId,text,botId,obj)
	} else {
		set res = ..SendMessage(chatId,text,botId)
	}
	
	if (res.ok) {
		return res.result."message_id"
	}
	return $$$ERROR($$$GeneralError, "Error while sending a message")
}

ClassMethod GetRequestObj() As %Net.HttpRequest
{
	#dim request as %Net.HttpRequest
	set request = ##class(%Net.HttpRequest).%New()
	set request.Server = "api.telegram.org"
	set request.SSLConfiguration = ..CheckSSLCertificate("TelegramSSL")
	set request.Https = 1 
	return request
}

ClassMethod ExecuteRequest(request As %Net.HttpRequest, method As %String, botId = "") As %DynamicObject
{
	set st = request.Post("bot"_botId_"/"_method)
	if ($$$ISERR(st)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(st)
	}
	return ##class(%Library.DynamicObject).%FromJSON(request.HttpResponse.Data)
}

ClassMethod SendMessage(chatId As %Integer, text As %String, botId, replyMarkup As %DynamicObject = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	do request.InsertFormData("chat_id",chatId)
	do request.InsertFormData("text",text)
	do request.InsertFormData("parse_mode","HTML") ;HTML ;MarkdownV2 ;Markdown https://core.telegram.org/bots/api#markdownv2-style
	
	if (replyMarkup'=0) {
		do request.InsertFormData("reply_markup",replyMarkup.%ToJSON())
	}
	return ..ExecuteRequest(request, "sendMessage",botId)
}

ClassMethod GetUpdates(botId, offset As %Integer = "", limit As %Integer = 100, timeout As %Integer = 0) As %DynamicObject
{
	#dim request as %Net.HttpRequest
	set request = ..GetRequestObj()
	if (offset'="") {
		do request.InsertFormData("offset",offset)
	}
	do request.InsertFormData("limit",limit)
	do request.InsertFormData("timeout",timeout)
	return ..ExecuteRequest(request, "getUpdates",botId)
}

/// The method checks for the existence of the configured SSL configuration
/// and creates an empty configuration with that name if this yet
/// to connect to a https server, that's enough
ClassMethod CheckSSLCertificate(name) As %String
{
  NEW $NAMESPACE
  SET $NAMESPACE = "%SYS"
  
  IF '##class(Security.SSLConfigs).Exists(name) {
    DO ##class(Security.SSLConfigs).Create(name)
  }
  QUIT name
}

}

