@echo off
call git add .
call rake build
:: call gem install ./pkg/erbac-version.gem
