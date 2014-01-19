import sys,datetime         
print ("argument convention: python log_sum(.py) [-n N] [-h H|-d D] [-c|-2|-r|-F|-t] <filename>")
print ("FOR no limit option give any char after giving -n,for no hour or day give any char after -h or -d and for standard input give '-' or nothing")
       
if len(sys.argv) < 6:
    print ("error in argument...please follow the argument style")
    sys.exit()
    
CLIENT_IP       =0     
CLIENT_USER     =1        
REMOTE_USER     =2        
COMPLETION_TIME =3    
HTTP_REQUEST    =4       
STATUS_CODE     =5
RETURNED_SIZE   =6
REFERRER        =7
USER_AGENT      =8

def getlogfields(s):
    fields = []
    if s.startswith(" "): # error! no leading spaces allowed!
       return fields
 
    state = 0
    quoteds = ""
    n = 0
    for f in s.split():
        if state == 0:
           if f.startswith("\""):
               if f.endswith("\""):
                   fields.append(f[1:-1])
               else:
                   quoteds = f[1:]+ " "
                   state = 2
               continue
           elif f.startswith("'"):
               if f.endswith("\""):
                   fields.append(f[1:-1])
               else:
                   quoteds = f[1:] + " "
                   state = 3
               continue
           elif f.startswith("["):
               if f.endswith("]"):
                   fields.append(f[1:-1])
               else:
                   blockeds = f[1:] + " "
                   state = 4
               continue
           else:
               fields.append(f)
 
        if state == 2 :
            quoteds += (f + " ")
            if f.endswith("\"") :
               quoteds = quoteds[:-2]
               fields.append(quoteds)
               n+= 1
               state = 0
 
        if state == 3 :
            quoteds += (f + " ")
            if f.endswith("'") :
               quoteds = quoteds[:-2]
               fields.append(quoteds)
               n+= 1
               state = 0
 
        if state == 4 :
            blockeds += (f +" ") 
            if f.endswith("]") :
               blockeds = blockeds[:-2]
               fields.append(blockeds)
               n+= 1
               state = 0
 
      
    return fields
 

def logsplittimefield(timefield):
    
    try:
        
        (stime, zone) = timefield.split()
        
        
        caldate, hour, minute, second = stime.split(":")
        day, month, year = caldate.split("/")
        if month=='Jan':
            month='01'
        elif month=='Feb':
            month=='02'
        elif month=='Mar':
            month='03'
        elif month=='Apr':
            month='04'
        elif month=='May':
            month=='05'
        elif month=='Jun':
            month=='06'
        elif month=='Jul':
            month='07'
        elif month=='Aug':
            month='08'
        elif month=='Sep':
            month='09'
        elif month=='Oct':
            month='10'
        elif month=='Nov':
            month='11'
        elif month=='Dec':
            month='12'    
    except:
        return None
    return (day, month, year, hour, minute, second, zone)

def logsplitrequestfield(requestfield):
    
    try:
        # you can avoid the intermediate storing to variables.
        method, resource, protocol = requestfield.split()
    except:
        return None
 
    return method, resource, protocol

def logsplituseragentfield(useragentfield):
    
    return useragentfield.split()
 
def expandedfields(ninefields):
    
    try:
        if len(ninefields)  == 0:
            return None
 
        
        day, month, year, hour, minute, second, zone = logsplittimefield(ninefields[COMPLETION_TIME])    
       
        method, resource, protocol = logsplitrequestfield(ninefields[HTTP_REQUEST])
        status = ninefields[STATUS_CODE]
        size = ninefields[RETURNED_SIZE]
       
 
 
        return day,month,year,hour,minute,second
    except:
        print ("error in processing [%s]" % ninefields)
        return None
   
def scanlogfile(logfile):
    
    rows = []
    nerrorlines = 0

    timearray=[]
    for linenumber, line in enumerate(open(logfile, "r").read().split("\n")):
       if len(line) == 0: #ifnore trailing blank line in log file!
           continue
 
       
       row = getlogfields(line)
       
       timerow=expandedfields(row)
       
       if len(timerow)!=0:
           timearray.append(timerow)
       if len(row) == 9:
           rows.append(row)
       elif len(row) != 0: # an empty line, especially a trailing line,  is not an error!
           nerrorlines += 1
           #print "*******ERROR:**********", len(row)
           #print line, row
           
       
    return (rows, linenumber,timearray)

def scanline():
    
    rows = []
    nerrorlines = 0
    linenumber=0
    timearray=[]

    for  line in sys.stdin:
       if len(line) == 0: #ignore trailing blank line in log file!
           continue
 
       linenumber=linenumber+1
       row = getlogfields(line)
       
       timerow=expandedfields(row)
       
       if len(timerow)!=0:
           timearray.append(timerow)
       if len(row) == 9:
           rows.append(row)
       elif len(row) != 0: # an empty line, especially a trailing line,  is not an error!
           nerrorlines += 1
           #print "*******ERROR:**********", len(row)
           #print line, row
           
    #print rows   
    return (rows,linenumber,timearray)

 
def converttodate(datetime1):     
    x=datetime.datetime(int(datetime1[2]), int(datetime1[1]),int(datetime1[0]), 23, 59,59)
    return x

def differencetime(datetime1,datetime2):

    difference = datetime1 - datetime2
    weeks, days = divmod(difference.days, 7)
    minutes, seconds = divmod(difference.seconds, 60)
    hours, minutes = divmod(minutes, 60)
    #difference in hour
    totalhourdiff=weeks*7*24+days*24+hours+minutes/60+seconds/3600
    #difference in days
    totaldays=difference.days

    return totalhourdiff,totaldays



if len(sys.argv)!=7 or sys.argv=="" or sys.argv=="-":
    print ("Press Ctrl+D to Exit standard input")
    rows,linenumber,timearray=scanline()

else:
    filename=sys.argv[6]
    print ("processing",filename," file")
    #Get all rows and total lines
    rows, linenumber,timearray = scanlogfile(filename)

#reverse rows
rows=rows[:]
rows.reverse()
#reverse time
timearray=timearray[:]
timearray.reverse()
#last time
lasttime=timearray[0]
#convert last time

lasttime=converttodate(lasttime)


limit=sys.argv[2]
if limit.isdigit():
    limit1=int(limit)
    if limit1<=0:
        limit1=-1
else:
    limit1=-1

if sys.argv[5]=='-c':
       
    visitors = {}
    j=0
    k=0
    for row in rows:
        currentlinetime=timearray[k]
        currentlinetime=converttodate(currentlinetime)
        difftime=differencetime(lasttime,currentlinetime)
        difftimehour=difftime[0]
        difftimedays=difftime[1]
        
        k=k+1
        if sys.argv[3]=='-h':
            if sys.argv[4].isdigit():
                if difftimehour>24 or difftimehour>int(sys.argv[4]):
                    break
        elif sys.argv[3]=='-d':
            if sys.argv[4].isdigit():
                if difftimedays+1>int(sys.argv[4]):
                    break
            
        
        visitor= row[0]
        if visitor in visitors:
            visitors[visitor]+= 1
        
        else:
            visitors[visitor] = 1
        
        
    print ("IP addresses makes the most number of connection attempts: \n")
    tmp = []
    for i in visitors:
        tmp.append((visitors[i], i))
        
    total = 0
    for (i, visitor) in sorted(tmp,reverse=True):
        total += i
        if limit1!=-1:
            
            j=j+1
            if j>limit1:
                break
        print  (visitor,i)
        
    #print "unique addresses=", len(tmp)
    print("\n")

elif sys.argv[5]=='-2':
    visitors_succefull_con={}
    j=0
    k=0
    for row_succefull_con in rows:
        currentlinetime=timearray[k]
        currentlinetime=converttodate(currentlinetime)
        difftime=differencetime(lasttime,currentlinetime)
        difftimehour=difftime[0]
        difftimedays=difftime[1]
        k=k+1
        if sys.argv[3]=='-h':
            if sys.argv[4].isdigit():
                if difftimehour>24 or difftimehour>int(sys.argv[4]):
                    break
        elif sys.argv[3]=='-d':
            if sys.argv[4].isdigit():
                if difftimedays+1>int(sys.argv[4]):
                    break
        
        if row_succefull_con[5]=='200':
            visitor_succefull_con=row_succefull_con[0]
        else:
            continue
        if visitor_succefull_con in visitors_succefull_con:
            visitors_succefull_con[visitor_succefull_con]+= 1
        
        else:
            visitors_succefull_con[visitor_succefull_con] = 1
        
    print ("IP addresses makes the most number of successful connection attempts:\n")
    tmp_succefull_con = []
    for i_succefull_con in visitors_succefull_con:
        tmp_succefull_con.append((visitors_succefull_con[i_succefull_con], i_succefull_con))

        
    total_succefull_con = 0
    for (i_succefull_con, visitor_succefull_con) in sorted(tmp_succefull_con,reverse=True):
        total_succefull_con += i_succefull_con
        if limit1!=-1:
            
            j=j+1
            if j>limit1:
                break
        print  (visitor_succefull_con,i_succefull_con)

        
    print("\n")

elif sys.argv[5]=='-t':
    visitors_byte_sent={}
    j=0
    k=0
    for row_byte_sent in rows:

        currentlinetime=timearray[k]
        currentlinetime=converttodate(currentlinetime)
        difftime=differencetime(lasttime,currentlinetime)
        difftimehour=difftime[0]
        difftimedays=difftime[1]
        k=k+1
        if sys.argv[3]=='-h':
            if sys.argv[4].isdigit():
                if difftimehour>24 or difftimehour>int(sys.argv[4]):
                    break
        elif sys.argv[3]=='-d':
            if sys.argv[4].isdigit():
                if difftimedays+1>int(sys.argv[4]):
                    break
            
        if row_byte_sent[6]!='-':
            visitor_byte_sent=row_byte_sent[0]
            byte_send=int(row_byte_sent[6])
        else:
            continue
        if visitor_byte_sent in visitors_byte_sent:
            visitors_byte_sent[visitor_byte_sent]+= byte_send
        
        else:
            visitors_byte_sent[visitor_byte_sent] = byte_send
        
    print ("IP number get the most bytes sent to them: \n")
    tmp_byte_sent = []
    for i_byte_sent in visitors_byte_sent:
        tmp_byte_sent.append((visitors_byte_sent[i_byte_sent], i_byte_sent))
        
    total_byte_sent = 0
    for (i_byte_sent, visitor_byte_sent) in sorted(tmp_byte_sent,reverse=True):
        total_byte_sent += i_byte_sent
        if limit1!=-1:
            
            j=j+1
            if j>limit1:
                break
        print  (visitor_byte_sent,i_byte_sent)
        

    print("\n")


elif sys.argv[5]=='-r':
    visitors_rs_code={}
    j=0
    k=0
    for row_rs_code in rows:
        currentlinetime=timearray[k]
        currentlinetime=converttodate(currentlinetime)
        difftime=differencetime(lasttime,currentlinetime)
        difftimehour=difftime[0]
        difftimedays=difftime[1]
        k=k+1
        if sys.argv[3]=='-h':
            if sys.argv[4].isdigit():
                if difftimehour>24 or difftimehour>int(sys.argv[4]):
                    break
        elif sys.argv[3]=='-d':
            if sys.argv[4].isdigit():
                if difftimedays+1>int(sys.argv[4]):
                    break
  
        visitor_rs_code=row_rs_code[5],row_rs_code[0]
        
  
        if visitor_rs_code in visitors_rs_code:
            visitors_rs_code[visitor_rs_code]+= 1
            #print row_rs_code[0],row_rs_code[5]
        else:
            visitors_rs_code[visitor_rs_code] = 1
            #print row_rs_code[0],row_rs_code[5]

    print ("the most common result codes and where do they come from: \n")

    tmp_rs_code = []
    for i_rs_code in visitors_rs_code:
        tmp_rs_code.append((visitors_rs_code[i_rs_code], i_rs_code))
        
        
    total_rs_code = 0
    for (i_rs_code, visitor_rs_code) in sorted(tmp_rs_code,reverse=True):
        total_rs_code += i_rs_code
        if limit1!=-1:
            
            j=j+1
            if j>limit1:
                break
        print  (i_rs_code, visitor_rs_code[1])
        

    print("\n")


elif sys.argv[5]=='-F':
    visitors_rs_fail={}
    j=0
    k=0
    for row_rs_fail in rows:
        currentlinetime=timearray[k]
        currentlinetime=converttodate(currentlinetime)
        difftime=differencetime(lasttime,currentlinetime)
        difftimehour=difftime[0]
        difftimedays=difftime[1]
        k=k+1
        if sys.argv[3]=='-h':
            if sys.argv[4].isdigit():
                if difftimehour>24 or difftimehour>int(sys.argv[4]):
                    break
        elif sys.argv[3]=='-d':
            if sys.argv[4].isdigit():
                if difftimedays+1>int(sys.argv[4]):
                    break
            
        if row_rs_fail[5].startswith('4'):
            visitor_rs_fail=row_rs_fail[5],row_rs_fail[0]
        else:
            continue
  
        if visitor_rs_fail in visitors_rs_fail:
            visitors_rs_fail[visitor_rs_fail]+= 1
            #print row_rs_code[0],row_rs_code[5]
        else:
            visitors_rs_fail[visitor_rs_fail] = 1
            #print row_rs_code[0],row_rs_code[5]
    print ("The most common result codes that indicate failure (no auth, not found etc) and where do they come from : \n")

    tmp_rs_fail = []
    for i_rs_fail in visitors_rs_fail:
        tmp_rs_fail.append((visitors_rs_fail[i_rs_fail], i_rs_fail))
        
    total_rs_fail = 0
    for (i_rs_fail, visitor_rs_fail) in sorted(tmp_rs_fail,reverse=True):
        total_rs_fail += i_rs_fail
        if limit1!=-1:
            
            j=j+1
            if j>limit1:
                break
        print  (i_rs_fail, visitor_rs_fail[1])
        

    print("\n")

else:
    print("No type or wrong Type Selected")

 

     
