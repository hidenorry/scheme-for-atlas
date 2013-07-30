#!/bin/sh

echo_warn (){
    local message=$1
    echo -n "#######" "  "
    echo -n ${message}
    echo    "  " "#######"
}

exec_in () {
  local file=${1%.in}
  local input_file=${file}.in
  local output_file=${file}.out

  echo_warn "deckbuild -run -ascii -as ${input_file} -outfile ${output_file}"
  deckbuild -run -ascii -as ${input_file} -outfile ${output_file}
}

exec_scm () {
    local atlas_syntax_file="${HOME}/apl/at/gfora.scm"
    local file=${1%.scm}
    shift
    local options="$@"
    local pre_input_file=${file}.scm
    local input_file=${file}.in

    if [ -f  $atlas_syntax_file ]; then
        gosh -l ${atlas_syntax_file} ${pre_input_file} ${options} > ${input_file}
    else
        echo_warn "${atlas_syntax_file} is not found."
        exit 1
    fi
    
    if [ $? == 0 ]; then
        exec_in ${input_file}
    else
        echo_warn "${pre_input_file} was failed."
        exit 1
    fi
}


file=$1
shift
options="$@"
extension=${file##*.}
if [ ${extension} == "in" ]; then
    exec_in ${file}
elif [ ${extension} == "scm" ]; then
    exec_scm ${file} ${options}
else
    echo_warn "Unkown extension is used in | ${file} |."
    exit 1
fi
