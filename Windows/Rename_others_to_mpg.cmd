@for %%I in (*.*) do @if exist %%~nI.mpg echo %%I cannot be renamed. File %%~nI.mpg already exists. && @if not exist %%~nI.mpg ren %%I %%~nI.mpg && echo %%I renamed to %%~nI.mpg
