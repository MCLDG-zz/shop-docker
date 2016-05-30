@echo off
echo Set Docker envs
FOR /f "tokens=*" %%i IN ('docker-machine env dev') DO %%i
echo Done!