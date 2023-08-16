import irisnative
import os

#ISC_Host=localhost
#ISC_Port=1972
#ISC_Username=_system
#ISC_Password=SYS
#ISC_Namespace=USER
ISC_Host = os.getenv("ISC_Host")
ISC_Port = os.getenv("ISC_Port")
ISC_Username = os.getenv("ISC_Username")
ISC_Password = os.getenv("ISC_Password")
ISC_Namespace = os.getenv("ISC_Namespace")

def runmet(_class,_method, _arg):
    try:
        connection = irisnative.createConnection(ISC_Host, int(ISC_Port), ISC_Namespace, ISC_Username, ISC_Password)
        iris_native = irisnative.createIris(connection)
        appiris = irisnative.createIris(connection)
        _val = str(appiris.classMethodValue(_class, _method, _arg))
        #nodeVal = str(appiris.classMethodValue("apptools.core.telebot", "TS", ""))
        #print(myIris.get("Test"))
    except:
        _val = 'FAIL Iris connection'
    return _val