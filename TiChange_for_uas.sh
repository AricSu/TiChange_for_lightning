function TiChange_help(){
   echo "Auther    : jan su"
   echo "Intruduce : TiChange 是一个能让你快速将csv文件适配 tidb-lightning csv 文件格式要求的工具，如有任何 BUG 请及时反馈，作者将及时修复！"
   echo " "
   echo "Usage: ${0##*/} [option] [parameter]"
   echo "option: -i --input-file          [input_csv_path]          |               | 需要处理的csv文件路径;"
   echo "        -o --operate-path        [operate_dir_path]        |               | 需要处理csv文件的，空间足够的文件夹路径;"
   echo "        -m --schema-meta         [schema_meta]             |               | 需要将要导入 csv 文件数据库中所属对象信息，eg: -m schema_name.table_name;"
   echo "        -s --separator_import    [separator_import_format] |(default: ',' )| 需要指定当前 csv 文件字段分隔符，eg: -s '||' TiChange 自动将其转换为 \",\" : 'A'||'B'--> 'A','B' ;"
   echo "        -d --delimiter_import    [delimiter_import_format] |(default: '\"' )| 需要指定当前 csv 文件引用定界符，eg: -d  ''' TiChange 自动将其转换为 '\"' : 'ABC'   -->  \"ABC\" ;"
   echo "        -n --null_import         [null_import_format]      |(default: '\N')| 需要指定解析 csv 文件中字段值为 NULL 的字符， eg: '\\N' 导入 TiDB 中会被解析为 NULL ;"
   echo "        -h --help                                          |               | 获取关于 TiChange.sh 的操作指引，详细 Demo 请参考 ： https://gitee.com/coresu/ti-change ;"
}


# Deal with content of input
if [ $# -le 0 ] || [ $1 = '?' ]; then
   TiChange_help
   exit 1
fi



# Get an hash string for copying file
hash_time=$(date "+%Y%m%d%H%M%S" | tr -d '\n' | md5sum)
perfix_hash_time=${hash_time:0:7}

# Set TiChange options using getopt lib
TEMP=`getopt -o i:o:s:m:d:n:h --long help,input-file:,operate-path:,schema-meta:,separator_import:,delimiter_import:,null_import: -- "$@"`

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"


while true ; do
        case "$1" in
                -i|--input-file)          echo "Option i == ${2}" ; 
			Source_oper_file=${2}; shift 2;;
                -o|--operate-path)        echo "Option o == ${2}" ;
			TiChange_oper_file=${2}/TiChange_operating_csv_$perfix_hash_time;
                        TiChange_oper_dir=${2}/${perfix_hash_time}_operating_dir; shift 2;;
                -m|--schema-meta)         echo "Option s == ${2}" ;
			TiChange_meta_table=${2}; shift 2;;
                -s|--separator_import)    echo "Option s == ${2}" ;
			TiChange_separator=${2}; shift 2;;
                -d|--delimiter_import)    echo "Option d == ${2}" ;
			TiChange_delimiter=${2}; shift 2;;
                -n|--null_import)         echo "Option n == ${2}" ;
			TiChange_null=${2}; shift 2;;
                -h|--help) TiChange_help; exit 1 ;;
                --) shift ; break ;;
                *) echo "Internal error!" ; exit 1 ;;
        esac
done

# Print information on terminal
echo "---------------------------------------------------------------------------"
echo "------------  TiChange starting  ------------------------------------------"
echo "---------------------------------------------------------------------------"

# Change input csv file to "mofidy_dir" for operating
cp ${Source_oper_file} ${TiChange_oper_file}


# Deal with TiChange_oper_file turned into adopted format of lightning
# 如果 delimiter separator 他俩的组合还不知道怎么处理
sed -ri 's#^|$#"#g' ${TiChange_oper_file}
sed -ri 's#$#&,"","","","","","",""#g' ${TiChange_oper_file}
sed -i 's#||#","#g' ${TiChange_oper_file}

# Deal with NULL value using sed Command
# 替换空值还不知道怎么处理
if [ ${TiChange_null} ]; then
        sed -i "s#\"${TiChange_null}\"#\\\\N#g" ${TiChange_oper_file}
fi


# Split the file into many small files, which 
# is similer to volume of 96M
mkdir ${TiChange_oper_dir}
cd ${TiChange_oper_dir}
split -b 96M ${TiChange_oper_file} -d TiChange_96M
TiChange_lines_96M=`cat TiChange_96M00 |wc -l`
rm -rf TiChange_96M*
split -l ${TiChange_lines_96M} ${TiChange_oper_file}  -d -a 8 ${TiChange_meta_table}.
rm -rf ${TiChange_oper_file}

# Change every files to obey the filename named rule of tidb-lightning
softfiles=$(ls ${TiChange_oper_dir})
for sfile in ${softfiles}
do
   mv ${sfile} ${sfile}.csv
done

echo "---------------------------------------------------------------------------"
echo "------------  using below information for tidb-lightning.toml  ------------"
echo "---------------------------------------------------------------------------"
echo "Please write the string path to tidb-lightning.toml config file!!!"
echo "and ,delete the dealed files by hand after imported data into database!!!"
echo -e "\n"
echo "[mydumper]"
echo "data-source-dir = \"${TiChange_oper_dir}\"" 
echo "[mydumper]"
echo "no-schema = true"
echo "---------------------------------------------------------------------------"

# Delete all of tmp splited file
#ls ${2} | grep ${perfix_hash_time} |xargs rm -rf 

