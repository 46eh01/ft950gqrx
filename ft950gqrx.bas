#Include Once "TSNE_V3.bi"

'### Dev-Notes #################################################################
'#
'# GQRX Telnet Commands to implement:
'#  f
'#    Get frequency [Hz]
'#  F <frequency>
'#    Set frequency [Hz]
'#  m
'#    Get demodulator mode and passband
'#  M <mode> [passband]
'#    Set demodulator mode and passband [Hz]
'#    Passing a '?' as the first argument instead of 'mode' will return
'#    a space separated list of radio backend supported modes.
'###############################################################################

'2023 by 46EH01 - Sebastian
'LGPLv2.1
'v0.2.4

'########### User Configuration ############
Dim SerialPort as String = "/dev/ttyUSB0"
Dim SerialSpeed as String = "38400"
Dim SerialParity as String = "N"
Dim SerialDataBits as String = "8"
Dim SerialStopBits as String = "2"

Dim GQRXHost as String = "localhost"
Dim GQRXPort as UShort = 7356

Dim IFFrequency as Long = 69450000
'###########################################

Dim G_Client_TSNEID as UInteger

DIM cmdStr as String
DIM adat as String * 1
Dim Freq as String
Dim Shared NetID as UInteger

Sub TSNE_Disconnected(ByVal V_TSNEID as UInteger)
	Print "Telnet disconnected."
End Sub

Sub TSNE_Connected(ByVal V_TSNEID as UInteger)
	Print "Telnet connected."
	NetID = V_TSNEID
End Sub

Sub TSNE_NewData(ByVal V_TSNEID as UInteger, ByRef V_Data as String)
	' Not used yet.
End Sub


Dim RV as Integer

RV = TSNE_Create_Client(G_Client_TSNEID, GQRXHost, GQRXPort, @TSNE_Disconnected, @TSNE_Connected, @TSNE_NewData)
If RV <> TSNE_Const_NoError Then
    Print "[ERROR] " & TSNE_GetGURUCode(RV)
    End -1
End If

OPEN COM SerialPort & ":" & SerialSpeed & "," & SerialParity & "," & SerialDataBits & "," & SerialStopBits FOR BINARY AS #1

Print "Port " & SerialPort & " opened."
Print #1, "AI1;"
Print "TRX AutoInformation enabled."
Print "Receiving CAT data...."
Sleep 500

DO
	Get #1, , adat
    If adat = ";" Then
    	If Left(cmdStr, 2) = "FA" Then
    		Freq = Str(CLng(Mid(cmdStr, 3)) - IFFrequency)
    		Dim RW as Integer
    		RW = TSNE_Data_Send(NetID, "LNB_LO " + Freq)
    		If RW <> TSNE_Const_NoError Then
    			Print "[ERROR] " & TSNE_GetGURUCode(RV)
    			TSNE_Disconnect(NetID)
    		End If
    	End If
    	cmdStr = ""
    Else
    	cmdStr = cmdStr + adat
    End If
LOOP UNTIL INKEY$ <> ""

Print "User aborted."
Print "Port " & SerialPort & " closed."
Close #1
