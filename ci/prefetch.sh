#!/bin/bash
#
# If provided with a URL for an existing index.yaml file, pre-fetch
# all referenced template archives.
#

# setup environment
. $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/env.sh

create="1>/dev/null echo"
verify="1>/dev/null echo"
if which md5sum > /dev/null
then
    create="md5sum -b"
    verify="md5sum --status -c -"
elif which shasum > /dev/null
then
    create="shasum -b"
    verify="shasum --status -c -"
fi

pushd $build_dir/prefetch

if [ -n "${INDEX_LIST}" ]
then
    for url in ${INDEX_LIST}
    do
        echo "== $url"
        index=$(curl -s -L ${url})

        # Determine and fetch all the template tar.gz and source tar.gz files
        for x in $(echo "$index" | grep -E 'url:|src:' )
        do
            if [ $x != 'url:' ] && [ $x != 'src:' ] && [ $x != '""' ]
            then
                echo "   $x"
                curl -s -L -O $x
                filename=$(basename $x)
                if ! [[ "$filename" =~  v[0-9]+\.[0-9]+\.[0-9]+ ]]
                then
                    # the stack version is in the directory name
                    release=$(basename $(dirname $x))
                    split=$(echo $release | awk '{split($0,a,"-v"); print a[1],a[2]}')
                    declare -a stack=($split)

                    # The template id is in the filename: incubator.nodejs-loopback.templates.scaffold.tar.gz
                    template_id=$(echo $filename | sed -E 's|.*templates\.(.*)\.tar\.gz|\1|')
                    repo=$(echo $filename | cut -d'.' -f1)

                    # Create a script that can compare a pre-fetched template version
                    # to the current stack version (read from stack.yaml), e.g.:
                    # ./ci/build/prefetch-stack_id-template_id 0.3.2
                    echo '#!/bin/bash

dir=$(pwd)
cd "'${build_dir}'/prefetch"
# Fetched from '${url}' on '$(date)'
# '${x}'
checksum="'$($create $filename)'"
if echo "$checksum" | '$verify'
then
    if [ "$1" == "'${stack[1]}'" ]
    then
        echo ok
    else
        echo "'${stack[1]}'"
    fi
else
    echo nomatch
fi
cd $dir
' > ${build_dir}/prefetch-"${repo}-${stack[0]}-${template_id}"
                    chmod +x ${build_dir}/prefetch-"${repo}-${stack[0]}-${template_id}"
                fi
            fi
        done
    done
fi
popd
