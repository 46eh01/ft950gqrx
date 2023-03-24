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
Dim SerialPort As String = "/dev/ttyUSB0"
Dim SerialSpeed As String = "38400"
Dim SerialParity As String = "N"
Dim SerialDataBits As String = "8"
Dim SerialStopBits As String = "2"

Dim GQRXHost As String = "localhost"
Dim GQRXPort As UShort = 7356

Dim IFFrequency As Long = 69450000
'###########################################

Dim G_Client_TSNEID As UInteger
Dim cmdStr As String
Dim adat As String * 1
Dim Freq As String
Dim Shared NetID As UInteger

sub TSNE_Disconnected(ByVal V_TSNEID As UInteger)
	Print "Telnet disconnected."
End sub

sub TSNE_Connected(ByVal V_TSNEID As UInteger)
	Print "Telnet connected."
	NetID = V_TSNEID
End sub

sub TSNE_NewData(ByVal V_TSNEID As UInteger, ByRef V_Data As String)
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
