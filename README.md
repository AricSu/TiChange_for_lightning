
```shell
[tidb@tidb-51-pd lightning]$ ./TiChange_for_uas.sh 
      -i '/home/tidb/lightning/54tr.54tr' \
      -o '/home/tidb/lightning/test' \
      -m 'jan.risk_factor' \
      -n ''
      
---------------------------------------------------------------------------
------------  TiChange starting  ------------------------------------------
---------------------------------------------------------------------------
Option i == /home/tidb/lightning/54tr.54tr
Option o == /home/tidb/lightning/test
Option s == jan.risk_factor
Option n == 
---------------------------------------------------------------------------
------------  using below information for tidb-lightning.toml  ------------
---------------------------------------------------------------------------
Please write the string path to tidb-lightning.toml config file!!!
and ,delete the dealed files by hand after imported data into database!!!


[mydumper]
data-source-dir = "/home/tidb/lightning/test/633dabe_operating_dir"
[mydumper]
no-schema = true
---------------------------------------------------------------------------


tiup tidb-lightning --config ./tidb-lightning.toml
```