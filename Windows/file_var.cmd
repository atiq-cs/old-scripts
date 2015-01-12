@rem source: http://www.computing.net/answers/programming/batch-file-for-comparing-strings-/17507.html
@echo Line Extractor from file
@for /f %%a in (test.txt) do @(
	echo Var is: %%a
)
