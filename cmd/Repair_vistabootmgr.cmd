@bcdedit /set {bootmgr} device partition=C:
@echo Boot target of bootmgr set.
@bcdedit /set {default} device partition=C:
@echo Boot target of Vista boot entry set.
@bcdedit /set {default} osdevice partition=C:
@echo os target of Vista boot entry set.
@bcdedit