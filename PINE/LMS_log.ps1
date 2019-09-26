cd D:\Work\LMS_LOgs

#Get-Content server.log.2019-05-29.11 | Select-String -SimpleMatch "Error" >> 11.log

Get-Content server.log.2019-05-29.11 | Select-String -SimpleMatch "Error","Warning"
