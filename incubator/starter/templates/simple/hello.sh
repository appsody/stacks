echo "Hello from Appsody!"

set -e
set -x

ls -l /project /project/userapp /project/userapp/deps
mkdir -p created-in-cwd-when-app-runs
