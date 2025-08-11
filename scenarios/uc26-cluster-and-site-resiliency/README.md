skupper expose service/galera --port 4567 --target-port 4567 --protocol tcp --namespace galera
skupper expose service/galera --port 4568 --target-port 4568 --protocol tcp --namespace galera
skupper expose service/galera --port 4444 --target-port 4444 --protocol tcp --namespace galera
skupper expose service/galera --port 3306 --target-port 3306 --protocol tcp --namespace galera
