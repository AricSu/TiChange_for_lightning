
TiChange 是一个能让你快速将csv文件适配 tidb-lightning csv 文件格式要求的工具。遵照 TiDB 官网给出对 CSV 文件的[格式支持](https://docs.pingcap.com/zh/tidb/dev/migrate-from-csv-using-tidb-lightning),本脚本主要功能如下：
1. 将 csv 文件切分得近乎 96MB 大小;
2. 适配 lightning 可识别的文件名;
3. 批量替换当前字段分隔符（separator）为 lightning 默认字段分隔符（','）;
4. 批量替换当前引用定界符（delimiter）为 lightning 默认引用定界符（'"'）;
5. 批量替换当前  null 值字符为 lightning 默认字符（'\N'）;


## 使用简介
```shell
[tidb@tidb-51-pd lightning]$ ./TiChange_for_lightning.sh --help
Auther    : jan su
Introduce : TiChange 是一个能让你快速将csv文件适配 tidb-lightning csv 文件格式要求的工具，如有任何 BUG 请及时反馈，作者将及时修复！
 
Usage: TiChange_for_lightning.sh [option] [parameter]
option: -i --input-file          [input_csv_path]          |               | 需要处理的csv文件路径;
        -o --operate-path        [operate_dir_path]        |               | 需要处理csv文件的，空间足够的文件夹路径;
        -m --schema-meta         [schema_meta]             |               | 需要指定库中 csv 文件所属对象信息，eg: -m schema_name.table_name;
        -s --separator_import    [separator_import_format] |(default: ',' )| 需要指定当前 csv 文件字段分隔符，eg: -s '||' TiChange 自动将其转换为 "," : 'A'||'B'--> 'A','B' ;
        -d --delimiter_import    [delimiter_import_format] |(default: '"' )| 需要指定当前 csv 文件引用定界符，eg: -d  ''' TiChange 自动将其转换为 '"' : 'ABC'   -->  "ABC" ;
        -n --null_import         [null_import_format]      |(default: '\N')| 需要指定解析 csv 文件中字段值为 NULL 的字符， eg: '\N' 导入 TiDB 中会被解析为 NULL ;
        -h --help                                          |               | 获取关于 TiChange.sh 的操作指引，详细 Demo 请参考 ： https://gitee.com/coresu/ti-change ;
```



## Demo 
首先,使用 TiChange_for_lightning.sh 将一整块 csv 文件处理为多个 96MB csv,将 terminal 输出的 data-source-dir 路径填写至 tidb-lightning.toml。随后，便可按 TiDB 官网要求配置好后启动进程，导入数据。
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