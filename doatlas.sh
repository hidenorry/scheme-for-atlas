#!/bin/sh 

#@doc
# if check_yes; then
#     echo "You enter yes"
# else
#     echo "You enter no"
# fi
echo_warn (){
    message=$1
    echo -n "#######" "  "
    echo -n ${message}
    echo    "  " "#######"
}

check_yes (){
    echo_warn "Please enter y or n"
    echo -n ">>>>>>>"
    read y_or_n
    while (test ${y_or_n} != "y") && (test ${y_or_n} != "n"); do
        echo_warn "Please enter y or n"
        echo -n ">>>>>>>"
        read y_or_n
    done
    if [ ${y_or_n} == "y" ]; then
        return 0 # O.K.
    else
        return 1 # No!
    fi
}

over_write_check() {
    over_write_file=$1
    if [ -f ${over_write_file} ]; then
        echo_warn "| ${over_write_file} | exists. Over write?"
        if check_yes; then
            echo_warn "${input_file} is overwritten."
            return 0 # O.K.
        else
            return 1 # No!
        fi
    else
        return 0 # O.K.
    fi
}

exec_in () {
  file=${1%.in}
  input_file=${file}.in
  output_file=${file}.out

  if over_write_check ${output_file}; then
      echo_warn "deckbuild -run -ascii -as ${input_file} -outfile ${output_file}"
      deckbuild -run -ascii -as ${input_file} -outfile ${output_file}
  else
      echo_warn "job was canceled."
      exit 1
  fi
}

exec_scm () {
    local atlas_syntax_file="${HOME}/apl/at/gfora.scm"
    file=${1%.scm}
    pre_input_file=${file}.scm
    input_file=${file}.in

    if [ -f  $atlas_syntax_file ]; then
        if over_write_check ${input_file}; then
            gosh -l ${atlas_syntax_file} ${pre_input_file} > ${input_file}
        else
            echo_warn "${input_file} was not overwritten."
            echo_warn "job was canceled."
            exit 1
        fi
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
extension=${file##*.}
if [ ${extension} == "in" ]; then
    exec_in $1
elif [ ${extension} == "scm" ]; then
    exec_scm $1
else
    echo_warn "Unkown extension is used in | ${file} |."
    exit 1
fi
