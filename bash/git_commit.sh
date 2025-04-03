
#!/bin/bash
git_commit() {
echo Enter git commit according to whatever you are doing
read $1
git pull
git add ./ && git commit -m "$1" && git push
}