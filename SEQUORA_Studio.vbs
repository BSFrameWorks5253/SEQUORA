Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "D:\ON_GOING PROJECT\SEQUORA\SEQUORA_Studio"
WshShell.Run """C:\Users\Burhanuddin\AppData\Local\Python\pythoncore-3.14-64\pythonw.exe""" & " """D:\ON_GOING PROJECT\SEQUORA\SEQUORA_Studio\main.py"""", 0, False
Set WshShell = Nothing
