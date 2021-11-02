@if [%1] equ [/t] @(
	echo "First parameter was t"
	move f:\Support\_Links_inactive f:\Videos
)

@if [%1] equ [] @(
	echo "There is no first parameter."
	move f:\Videos f:\Support\_Links_inactive
)

:exit
@echo Job done