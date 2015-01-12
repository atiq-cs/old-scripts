@rem Get fastest public dns servers list:	http://theos.in/windows-xp/free-fast-public-dns-server-list/
@rem google dns servers http://code.google.com/speed/public-dns/
@rem set tmp=%1
@rem set dns1=116.193.170.6
@rem set dns1=116.193.170.5
@rem set dns2=116.193.170.6
@set dns1=%1
@set dns2=%2
@echo Changing your primary dns to %dns1%
@netsh interface ip set dns "local area connection" static %dns1%
@echo Changing your secondary dns to %dns2%
@netsh interface ip add dns "local area connection" %dns2%
@echo.
@echo Current dns servers in effect
@echo ===================================
@netsh interface ip show dnsservers
@pdns
@set dns1=
@set dns2=