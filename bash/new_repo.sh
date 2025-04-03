
#!/bin/bash

git config pull.rebase false && git pull

echo Enter git commit according to whatever you are doing
read git_commit

git pull && git add ./ && git commit -m "$git_commit" && git push
