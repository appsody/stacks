#!/bin/bash
set -e

# first argument of this script must be the base dir of the repository
if [ -z "$1" ]
then
    echo "One argument is required and must be the base directory of the repository."
    exit 1
fi

base_dir="$(cd "$1" && pwd)"

# directory to store packaged contents which will be published as a release
package_dir=$base_dir/ci/package

# base download url for downloading released assets
download_url="https://github.com/appsody/stacks/releases/download"

# list of repositories to build indexes for
repo_list="experimental incubator stable"

mkdir -p $package_dir

for repo_name in $repo_list
do
    repo_dir=$base_dir/$repo_name
    if [ -d $repo_dir ]
    then
        echo -e "\nProcessing repo: $repo_name"

        index_file=$package_dir/$repo_name-index.yaml
        echo "Creating index: $index_file"

        echo "apiVersion: v2" > $index_file
        echo "stacks:" >> $index_file

        for stack in $repo_dir/*/stack.yaml
        do
            stack_dir=$(dirname $stack)
            if [ -d $stack_dir ]
            then
                stack_id=$(basename $stack_dir)
                echo "  - id: $stack_id" >> $index_file

                sed 's/^/    /' $stack >> $index_file
                echo "    templates:"  >> $index_file

                for template_dir in $stack_dir/templates/*/
                do
                    if [ -d $template_dir ]
                    then
                        cd $template_dir
                        template_id=$(basename $template_dir)
                        template_archive=$repo_name.$stack_id.$template_id.tar.gz
                        tar -cz --exclude-from=$base_dir/.gitignore -f $package_dir/$template_archive .

                        echo "Created template archive: $template_archive"

                        echo "      - id: $template_id" >> $index_file
                        echo "        url: \"$download_url/$stack_id-vstack_version/$template_archive\"" >> $index_file
                    fi
                done
            fi
        done
    else
        echo "SKIPPING: $repo_dir"
    fi
done