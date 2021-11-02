@echo Saint Linux SCript
ml /c /coff /Cp msgbox.asm
link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib msgbox.obj
