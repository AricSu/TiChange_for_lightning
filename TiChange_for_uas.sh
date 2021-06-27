# Deal with content of input
if [ $# -le 0 ] || [ $1 = '?' ]; then
   echo "Usage: ${0##*/} [option] [parameter]"
   echo "option: -i --input-file   [input_csv_path]   需要处理的csv文件路径;"
   echo "        -o --operate-path [operate_dir_path] 需要处理csv文件的，空间足够的文件夹路径;"
   echo "        -s --schema-meta  [schema_meta]      需要导入的 csv 文件所属对象信息，eg: schema_name.table_name;"
   exit 1
fi


# Get an hash string for copying file
hash_time=$(date "+%Y%m%d%H%M%S" | tr -d '\n' | md5sum)
perfix_hash_time=${hash_time:0:7}


TEMP=`getopt -o i:o:s: --long input-file:,operate-path:,schema-meta: -- "$@"`

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
        case "$1" in
                -i|--input-file)   echo "Option i == ${2}" ; 
			Source_oper_file=${2}; shift 2;;
                -o|--operate-path) echo "Option o == ${2}" ;
			TiChange_oper_file=${2}/TiChange_operating_csv_$perfix_hash_time;
                        TiChange_oper_dir=${2}/${perfix_hash_time}_operating_dir; shift 2;;
                -s|--schema-meta)  echo "Option s == ${2}" ;
			TiChange_meta_table=${2}; shift 2;;
                --) shift ; break ;;
                *) echo "Internal error!" ; exit 1 ;;
        esac
done

# Change input csv file to "mofidy_dir" for operating
cp ${Source_oper_file} ${TiChange_oper_file}


# Deal with TiChange_oper_file turned into adopted format of lightning
sed -ri 's#^|$#"#g' ${TiChange_oper_file}
sed -ri 's#$#&,"","","","","","",""#g' ${TiChange_oper_file}
sed -i 's#||#","#g' ${TiChange_oper_file}

# Split the file into many small files, which 
# is similer to volume of 96M
mkdir ${TiChange_oper_dir}
cd ${TiChange_oper_dir}
sudo split -l 100 ${TiChange_oper_file}  -d -a 8 ${TiChange_meta_table}.
sudo rm -rf ${TiChange_oper_file}

# Change every files to obey the rule of tidb-lightning
softfiles=$(ls ${TiChange_oper_dir})
for sfile in ${softfiles}
do
    mv ${sfile} ${sfile}.csv
done

echo "------------  using below information for tidb-lightning.toml  ------------"
echo "Please write the string path -- " ${TiChange_oper_dir} " -- to tidb-lightning.toml config file."

# Delete all of tmp splited file
#ls ${2} | grep ${perfix_hash_time} |xargs rm -rf 
